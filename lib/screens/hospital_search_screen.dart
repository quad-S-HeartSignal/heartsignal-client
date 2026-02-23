import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:geolocator/geolocator.dart';
import '../models/hospital_model.dart';
import '../widgets/hospital_card.dart';
import '../widgets/custom_header.dart';
import '../widgets/hospital_detail_view.dart';
import '../services/places_service.dart';
import '../utils/marker_generator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class HospitalSearchScreen extends StatefulWidget {
  const HospitalSearchScreen({super.key});

  @override
  State<HospitalSearchScreen> createState() => _HospitalSearchScreenState();
}

class _HospitalSearchScreenState extends State<HospitalSearchScreen> {
  List<Hospital> _hospitals = [];
  bool _isLoading = true;
  String? _errorMessage;
  String _selectedFilter = '모든 병원 보기';
  final PlacesService _placesService = PlacesService();

  final Set<Marker> _markers = {};
  LatLng? _currentPosition;
  Hospital? _selectedHospital;
  GoogleMapController? _mapController;
  final DraggableScrollableController _sheetController =
      DraggableScrollableController();
  final GlobalKey<SliverAnimatedListState> _listKey =
      GlobalKey<SliverAnimatedListState>();

  List<Hospital> get _filteredHospitals {
    if (_selectedFilter == '영업중인 병원만 보기') {
      return _hospitals.where((h) => h.isOpen).toList();
    } else if (_selectedFilter == '응급실만 보기') {
      return _hospitals.where((h) => h.isEmergencyRoom).toList();
    }
    return _hospitals;
  }

  Future<void> _updateMarkers() async {
    final BitmapDescriptor customIconOpen =
        await MarkerGenerator.createCustomMarkerBitmap(isOpen: true);
    final BitmapDescriptor customIconClosed =
        await MarkerGenerator.createCustomMarkerBitmap(isOpen: false);

    final Set<Marker> newMarkers = {};
    for (final hospital in _filteredHospitals) {
      newMarkers.add(
        Marker(
          markerId: MarkerId(hospital.placeId),
          position: LatLng(hospital.lat, hospital.lng),
          icon: hospital.isOpen ? customIconOpen : customIconClosed,
          onTap: () {
            if (mounted) {
              final index = _filteredHospitals.indexOf(hospital);
              if (index > 0) {
                final removedHospital = _filteredHospitals[index];

                _listKey.currentState?.removeItem(
                  index,
                  (context, animation) => _buildHospitalItem(
                    context,
                    removedHospital,
                    animation: animation,
                    isRemoving: true,
                  ),
                  duration: const Duration(milliseconds: 300),
                );

                setState(() {
                  _hospitals.remove(removedHospital);
                  _hospitals.insert(0, removedHospital);
                });

                _listKey.currentState?.insertItem(
                  0,
                  duration: const Duration(milliseconds: 300),
                );
              }

              if (_sheetController.isAttached) {
                _sheetController.animateTo(
                  0.5,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              }

              if (_mapController != null) {
                try {
                  final offsetLat = hospital.lat - 0.009;
                  _mapController!.animateCamera(
                    CameraUpdate.newLatLng(LatLng(offsetLat, hospital.lng)),
                  );
                } catch (e) {
                  debugPrint('Map animation ignored (marker tap): $e');
                }
              }
            }
          },
        ),
      );
    }

    setState(() {
      _markers.clear();
      _markers.addAll(newMarkers);
    });
  }

  void _fitCameraToBounds() {
    if (_filteredHospitals.isNotEmpty && _mapController != null) {
      Future.delayed(const Duration(milliseconds: 300), () {
        if (!mounted) return;
        try {
          if (_filteredHospitals.length == 1) {
            final first = _filteredHospitals.first;
            _mapController!.animateCamera(
              CameraUpdate.newLatLngZoom(
                LatLng(first.lat - 0.009, first.lng),
                14.0,
              ),
            );
          } else {
            double minLat = _filteredHospitals.first.lat;
            double maxLat = _filteredHospitals.first.lat;
            double minLng = _filteredHospitals.first.lng;
            double maxLng = _filteredHospitals.first.lng;

            for (final h in _filteredHospitals) {
              if (h.lat < minLat) minLat = h.lat;
              if (h.lat > maxLat) maxLat = h.lat;
              if (h.lng < minLng) minLng = h.lng;
              if (h.lng > maxLng) maxLng = h.lng;
            }

            final bounds = LatLngBounds(
              southwest: LatLng(minLat, minLng),
              northeast: LatLng(maxLat, maxLng),
            );

            _mapController!.animateCamera(
              CameraUpdate.newLatLngBounds(bounds, 50.0),
            );
          }
        } catch (e) {
          debugPrint('Map animation ignored: $e');
        }
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchNearbyHospitals();
  }

  Future<void> _fetchNearbyHospitals() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      _currentPosition = LatLng(position.latitude, position.longitude);

      final fetchedHospitals = await _placesService.fetchNearbyHospitals(
        _currentPosition!,
      );

      await _updateHospitalsOnMap(fetchedHospitals);
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = '병원 정보를 불러오는 데 실패했습니다.';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _updateHospitalsOnMap(List<Hospital> fetchedHospitals) async {
    // 프론트단에서 거리순 정렬(임시)
    fetchedHospitals.sort((a, b) {
      final distA = Geolocator.distanceBetween(
        _currentPosition!.latitude,
        _currentPosition!.longitude,
        a.lat,
        a.lng,
      );
      final distB = Geolocator.distanceBetween(
        _currentPosition!.latitude,
        _currentPosition!.longitude,
        b.lat,
        b.lng,
      );
      return distA.compareTo(distB);
    });

    if (_filteredHospitals.isNotEmpty && _listKey.currentState != null) {
      for (int i = _filteredHospitals.length - 1; i >= 0; i--) {
        _listKey.currentState!.removeItem(
          i,
          (context, animation) => const SizedBox(),
          duration: const Duration(milliseconds: 100),
        );
      }
    }

    await Future.delayed(const Duration(milliseconds: 150));

    setState(() {
      _hospitals = fetchedHospitals;
      _isLoading = false;
    });

    if (_filteredHospitals.isNotEmpty && _listKey.currentState != null) {
      for (int i = 0; i < _filteredHospitals.length; i++) {
        _listKey.currentState!.insertItem(
          i,
          duration: const Duration(milliseconds: 300),
        );
      }
    }

    await _updateMarkers();
    _fitCameraToBounds();
  }

  Future<void> _searchHospitals(String keyword) async {
    if (_currentPosition == null) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final fetchedHospitals = await _placesService.searchHospitalsByKeyword(
        keyword: keyword,
        location: _currentPosition!,
      );

      await _updateHospitalsOnMap(fetchedHospitals);
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = '병원 검색에 실패했습니다.';
          _isLoading = false;
        });
      }
    }
  }

  // 필터 기능 (추후 확장 예정)
  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        final filters = ['모든 병원 보기', '영업중인 병원만 보기', '응급실만 보기'];
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '필터 선택',
                style: GoogleFonts.notoSans(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: ListView.builder(
                  itemCount: filters.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(
                        filters[index],
                        style: GoogleFonts.notoSans(fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                      onTap: () async {
                        if (_filteredHospitals.isNotEmpty &&
                            _listKey.currentState != null) {
                          for (
                            int i = _filteredHospitals.length - 1;
                            i >= 0;
                            i--
                          ) {
                            _listKey.currentState!.removeItem(
                              i,
                              (context, animation) => const SizedBox(),
                              duration: const Duration(milliseconds: 100),
                            );
                          }
                        }

                        await Future.delayed(const Duration(milliseconds: 150));

                        setState(() {
                          _selectedFilter = filters[index];
                        });
                        if (mounted) Navigator.pop(context);

                        if (_filteredHospitals.isNotEmpty &&
                            _listKey.currentState != null) {
                          for (int i = 0; i < _filteredHospitals.length; i++) {
                            _listKey.currentState!.insertItem(
                              i,
                              duration: const Duration(milliseconds: 300),
                            );
                          }
                        }

                        await _updateMarkers();
                        _fitCameraToBounds();
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHospitalItem(
    BuildContext context,
    Hospital hospital, {
    Animation<double>? animation,
    bool isRemoving = false,
  }) {
    final child = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          if (!isRemoving && _filteredHospitals.indexOf(hospital) > 0)
            const Divider(),
          HospitalCard(
            hospital: hospital,
            userLocation: _currentPosition,
            onTap: () {
              setState(() {
                _selectedHospital = hospital;
              });
            },
          ),
          if (_filteredHospitals.isNotEmpty &&
              _filteredHospitals.last == hospital)
            const SizedBox(height: 120),
        ],
      ),
    );

    if (animation != null) {
      return SizeTransition(
        sizeFactor: animation,
        child: FadeTransition(opacity: animation, child: child),
      );
    }
    return child;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                if (_currentPosition != null)
                  Positioned.fill(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 100),
                      child: GoogleMap(
                        initialCameraPosition: CameraPosition(
                          target: _currentPosition!,
                          zoom: 14.0,
                        ),
                        onMapCreated: (controller) {
                          _mapController = controller;
                        },
                        myLocationEnabled: true,
                        myLocationButtonEnabled: false,
                        zoomControlsEnabled: true,
                        markers: _markers,
                        padding: EdgeInsets.only(
                          bottom: MediaQuery.of(context).size.height * 0.25,
                        ),
                      ),
                    ),
                  )
                else
                  const Center(child: Text('Location permission needed')),

                const Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: CustomHeader(showBackButton: false),
                ),

                Positioned(
                  top: 110,
                  left: 16,
                  right: 16,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(20),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: '병원 이름, 지역 등을 검색해보세요',
                        hintStyle: GoogleFonts.notoSans(
                          color: Colors.grey[500],
                        ),
                        prefixIcon: const Icon(
                          Icons.search,
                          color: Color(0xFFFF5252),
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                      ),
                      onSubmitted: (value) {
                        if (value.isNotEmpty) {
                          _searchHospitals(value);
                        }
                      },
                    ),
                  ),
                ),

                DraggableScrollableSheet(
                  controller: _sheetController,
                  initialChildSize: 0.5,
                  minChildSize: 0.2,
                  maxChildSize: 0.85,
                  builder: (context, scrollController) {
                    return Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(24),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(25),
                            blurRadius: 10,
                            offset: const Offset(0, -2),
                          ),
                        ],
                      ),
                      child: CustomScrollView(
                        controller: scrollController,
                        slivers: [
                          SliverToBoxAdapter(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Center(
                                  child: Container(
                                    margin: const EdgeInsets.only(
                                      top: 12,
                                      bottom: 8,
                                    ),
                                    width: 40,
                                    height: 4,
                                    decoration: BoxDecoration(
                                      color: Colors.grey[300],
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 24,
                                    vertical: 8,
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        '${_filteredHospitals.length}개',
                                        style: GoogleFonts.notoSans(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: _showFilterSheet,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 8,
                                          ),
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                              color: Colors.grey[300]!,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              20,
                                            ),
                                            color: Colors.white,
                                          ),
                                          child: Row(
                                            children: [
                                              const Icon(
                                                Icons.filter_list,
                                                size: 16,
                                                color: Colors.black54,
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                _selectedFilter,
                                                style: GoogleFonts.notoSans(
                                                  fontSize: 14,
                                                  color: Colors.black87,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                              const SizedBox(width: 4),
                                              const Icon(
                                                Icons.arrow_drop_down,
                                                size: 20,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (_errorMessage != null)
                            SliverToBoxAdapter(
                              child: Container(
                                height: 300,
                                alignment: Alignment.center,
                                child: Text(_errorMessage!),
                              ),
                            )
                          else if (_filteredHospitals.isEmpty && !_isLoading)
                            SliverToBoxAdapter(
                              child: Container(
                                height: 300,
                                alignment: Alignment.center,
                                child: Text(
                                  _selectedFilter == '모든 병원 보기'
                                      ? '주변에 병원이 없습니다.'
                                      : '해당 조건에 맞는 병원이 없습니다.',
                                  style: GoogleFonts.notoSans(
                                    fontSize: 15,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ),
                            )
                          else
                            SliverAnimatedList(
                              key: _listKey,
                              initialItemCount: _filteredHospitals.length,
                              itemBuilder: (context, index, animation) {
                                if (index >= _filteredHospitals.length) {
                                  return const SizedBox();
                                }
                                final hospital = _filteredHospitals[index];
                                return _buildHospitalItem(
                                  context,
                                  hospital,
                                  animation: animation,
                                );
                              },
                            ),
                        ],
                      ),
                    );
                  },
                ),

                if (_selectedHospital != null)
                  Positioned.fill(
                    child: HospitalDetailView(
                      hospital: _selectedHospital!,
                      onClose: () {
                        setState(() {
                          _selectedHospital = null;
                        });
                      },
                      totalCount: _filteredHospitals.length,
                      selectedRegion: _selectedFilter,
                      userLocation: _currentPosition,
                    ),
                  ),
              ],
            ),
    );
  }
}
