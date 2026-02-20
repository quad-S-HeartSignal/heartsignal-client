class Hospital {
  final String placeId;
  final String name;
  final String address;
  final double lat;
  final double lng;
  final double? rating;
  final int? userRatingsTotal;

  Hospital({
    required this.placeId,
    required this.name,
    required this.address,
    required this.lat,
    required this.lng,
    this.rating,
    this.userRatingsTotal,
  });

  factory Hospital.fromJson(Map<String, dynamic> json) {
    final geometry = json['geometry']['location'];
    return Hospital(
      placeId: json['place_id'],
      name: json['name'],
      address: json['vicinity'] ?? json['formatted_address'] ?? '',
      lat: geometry['lat'],
      lng: geometry['lng'],
      rating: json['rating']?.toDouble(),
      userRatingsTotal: json['user_ratings_total'],
    );
  }
}
