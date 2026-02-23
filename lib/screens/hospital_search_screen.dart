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

    final BitmapDescriptor customIconOpen =
        await MarkerGenerator.createCustomMarkerBitmap(isOpen: true);
    final BitmapDescriptor customIconClosed =
        await MarkerGenerator.createCustomMarkerBitmap(isOpen: false);

    final Set<Marker> newMarkers = {};
    for (final hospital in fetchedHospitals) {
      newMarkers.add(
        Marker(
          markerId: MarkerId(hospital.placeId),
          position: LatLng(hospital.lat, hospital.lng),
          icon: hospital.isOpen ? customIconOpen : customIconClosed,
          onTap: () {
            if (mounted) {
              final index = _hospitals.indexOf(hospital);
              if (index > 0) {
                setState(() {
                  final removedHospital = _hospitals.removeAt(index);
                  _hospitals.insert(0, removedHospital);
                });
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

    if (mounted) {
      setState(() {
        _hospitals = fetchedHospitals;
        _markers.clear();
        _markers.addAll(newMarkers);
        _isLoading = false;
      });

      if (fetchedHospitals.isNotEmpty && _mapController != null) {
        Future.delayed(const Duration(milliseconds: 300), () {
          if (!mounted) return;
          try {
            if (fetchedHospitals.length == 1) {
              final first = fetchedHospitals.first;
              _mapController!.animateCamera(
                CameraUpdate.newLatLngZoom(
                  LatLng(first.lat - 0.009, first.lng),
                  14.0,
                ),
              );
            } else {
              double minLat = fetchedHospitals.first.lat;
              double maxLat = fetchedHospitals.first.lat;
              double minLng = fetchedHospitals.first.lng;
              double maxLng = fetchedHospitals.first.lng;

              for (final h in fetchedHospitals) {
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
  }

  Future<void> _searchHospitals(String keyword) async {
    if (_currentPosition == null) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _selectedHospital = null;
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
                      onTap: () {
                        setState(() {
                          _selectedFilter = filters[index];
                        });
                        Navigator.pop(context);
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
    bool isRemoving = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          if (!isRemoving && _hospitals.indexOf(hospital) > 0) const Divider(),
          HospitalCard(
            hospital: hospital,
            userLocation: _currentPosition,
            onTap: () {
              setState(() {
                _selectedHospital = hospital;
              });
            },
          ),
          if (_hospitals.isNotEmpty && _hospitals.last == hospital)
            const SizedBox(height: 120),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_selectedHospital != null) {
      return HospitalDetailView(
        hospital: _selectedHospital!,
        totalCount: _hospitals.length,
        selectedRegion: '현재 위치 주변',
        userLocation: _currentPosition,
        onClose: () {
          setState(() {
            _selectedHospital = null;
          });
        },
      );
    }

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
                      child: ListView.builder(
                        controller: scrollController,
                        padding: EdgeInsets.zero,
                        itemCount: _hospitals.isEmpty && _errorMessage == null
                            ? 2
                            : _hospitals.length + 1,
                        itemBuilder: (context, index) {
                          if (index == 0) {
                            return Column(
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
                                        '${_hospitals.length}개',
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
                            );
                          }

                          if (_errorMessage != null) {
                            return Container(
                              height: 300,
                              alignment: Alignment.center,
                              child: Text(_errorMessage!),
                            );
                          }

                          if (_hospitals.isEmpty) {
                            return Container(
                              height: 300,
                              alignment: Alignment.center,
                              child: const Text('주변에 병원이 없습니다.'),
                            );
                          }

                          final hospitalIndex = index - 1;
                          final hospital = _hospitals[hospitalIndex];

                          return _buildHospitalItem(context, hospital);
                        },
                      ),
                    );
                  },
                ),
              ],
            ),
    );
  }
}
