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
  String _selectedRegion = '현재 위치 주변';
  final PlacesService _placesService = PlacesService();

  final Set<Marker> _markers = {};
  LatLng? _currentPosition;
  Hospital? _selectedHospital;

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

      final BitmapDescriptor customIcon =
          await MarkerGenerator.createCustomMarkerBitmap();

      final Set<Marker> newMarkers = {};
      for (final hospital in fetchedHospitals) {
        newMarkers.add(
          Marker(
            markerId: MarkerId(hospital.placeId),
            position: LatLng(hospital.lat, hospital.lng),
            icon: customIcon,
            onTap: () {
              // Scroll to card or show details
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
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = '병원 정보를 불러오는 데 실패했습니다.';
          _isLoading = false;
        });
      }
    }
  }

  // 논의 후 이중 드롭다운으로 변경하면 좋을 것 같아요
  // 시군구 - 동읍면
  void _showRegionFilter() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        final regions = ['강남역', '서울역', '수원역', '잠실역', '홍대입구역'];
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '지역 선택',
                style: GoogleFonts.notoSans(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: ListView.builder(
                  itemCount: regions.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(
                        regions[index],
                        style: GoogleFonts.notoSans(fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                      onTap: () {
                        setState(() {
                          _selectedRegion = regions[index];
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

  @override
  Widget build(BuildContext context) {
    if (_selectedHospital != null) {
      return HospitalDetailView(
        hospital: _selectedHospital!,
        totalCount: _hospitals.length,
        selectedRegion: _selectedRegion,
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
                // 1. Background Map
                if (_currentPosition != null)
                  Positioned.fill(
                    child: Padding(
                      // Leave top space for header padding visually
                      padding: const EdgeInsets.only(top: 100),
                      child: GoogleMap(
                        initialCameraPosition: CameraPosition(
                          target: _currentPosition!,
                          zoom: 14.0,
                        ),
                        myLocationEnabled: true,
                        myLocationButtonEnabled: false,
                        zoomControlsEnabled: false,
                        markers: _markers,
                      ),
                    ),
                  )
                else
                  const Center(child: Text('Location permission needed')),

                // 2. Custom Header at the top
                const Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: CustomHeader(showBackButton: false),
                ),

                // 3. Draggable Scrollable Sheet for Hospitals List
                DraggableScrollableSheet(
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
                                // Drag Handle
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
                                // Top Filter Bar
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
                                        onTap: _showRegionFilter,
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
                                                Icons.location_on_outlined,
                                                size: 16,
                                                color: Colors.black54,
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                _selectedRegion,
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

                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Column(
                              children: [
                                if (hospitalIndex > 0) const Divider(),
                                HospitalCard(
                                  hospital: hospital,
                                  userLocation: _currentPosition,
                                  onTap: () {
                                    setState(() {
                                      _selectedHospital = hospital;
                                    });
                                  },
                                ),
                                if (hospitalIndex == _hospitals.length - 1)
                                  const SizedBox(
                                    height: 120,
                                  ), // Bottom navigation bar space
                              ],
                            ),
                          );
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
