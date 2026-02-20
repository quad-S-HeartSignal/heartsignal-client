import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../models/hospital_model.dart';

class PlacesService {
  final String apiKey;

  PlacesService(this.apiKey);

  Future<List<Hospital>> fetchNearbyHospitals(
    LatLng location, {
    int radius = 1500,
    String type = 'hospital',
  }) async {
    final String url =
        'https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=${location.latitude},${location.longitude}&radius=$radius&type=$type&key=$apiKey';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      if (data['status'] == 'OK') {
        final List<dynamic> results = data['results'];
        return results.map((e) => Hospital.fromJson(e)).toList();
      } else {
        // Handle other statuses (ZERO_RESULTS, OVER_QUERY_LIMIT, REQUEST_DENIED, etc.)
        print('Places API Error: ${data['status']}');
        if (data['error_message'] != null) {
          print('Error Message: ${data['error_message']}');
        }
        return [];
      }
    } else {
      throw Exception('Failed to fetch nearby hospitals');
    }
  }
}
