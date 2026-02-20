import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import '../models/hospital_model.dart';
import '../services/places_service.dart';

class HospitalMapScreen extends StatefulWidget {
  const HospitalMapScreen({super.key});

  @override
  State<HospitalMapScreen> createState() => _HospitalMapScreenState();
}

class _HospitalMapScreenState extends State<HospitalMapScreen> {
  GoogleMapController? _mapController;
  final Set<Marker> _markers = {};
  final PlacesService _placesService = PlacesService(
    'AIzaSyCf5_TrDbWy4S3wmP5R4PR1uf3ZjYHiqIg',
  );
  LatLng? _currentPosition;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return;
    }

    final position = await Geolocator.getCurrentPosition();
    setState(() {
      _currentPosition = LatLng(position.latitude, position.longitude);
      _isLoading = false;
    });

    _fetchNearbyHospitals();
  }

  Future<void> _fetchNearbyHospitals() async {
    if (_currentPosition == null) return;

    try {
      final hospitals = await _placesService.fetchNearbyHospitals(
        _currentPosition!,
      );
      setState(() {
        _markers.clear();
        for (final hospital in hospitals) {
          _markers.add(
            Marker(
              markerId: MarkerId(hospital.placeId),
              position: LatLng(hospital.lat, hospital.lng),
              infoWindow: InfoWindow(
                title: hospital.name,
                snippet: hospital.address,
              ),
            ),
          );
        }
      });
    } catch (e) {
      print('Error fetching hospitals: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to load hospitals')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nearby Hospitals'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _currentPosition == null
          ? const Center(child: Text('Location permission needed'))
          : GoogleMap(
              initialCameraPosition: CameraPosition(
                target: _currentPosition!,
                zoom: 14.0,
              ),
              onMapCreated: (controller) => _mapController = controller,
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
              markers: _markers,
            ),
    );
  }
}
