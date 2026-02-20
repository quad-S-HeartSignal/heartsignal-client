import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../models/hospital_model.dart';

class PlacesService {
  String get _backendUrl {
    if (kReleaseMode) {
      return 'http://your-production-url.com';
    }
    if (Platform.isAndroid) {
      return 'http://10.0.2.2:3000';
    }
    return 'http://localhost:3000';
  }

  Future<List<Hospital>> fetchNearbyHospitals(
    LatLng location, {
    int radius = 1500,
    String? category,
  }) async {
    final queryParameters = {
      'lat': location.latitude.toString(),
      'lng': location.longitude.toString(),
      'radius': radius.toString(),
    };
    if (category != null) {
      queryParameters['category'] = category;
    }

    final uri = Uri.parse(
      '$_backendUrl/api/hospitals/nearby',
    ).replace(queryParameters: queryParameters);

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);

      if (jsonResponse['success'] == true) {
        final List<dynamic> results = jsonResponse['data'];
        return results.map((e) => Hospital.fromJson(e)).toList();
      } else {
        print('Backend API Error: ${jsonResponse['message']}');
        return [];
      }
    } else {
      throw Exception('Failed to fetch nearby hospitals');
    }
  }
}
