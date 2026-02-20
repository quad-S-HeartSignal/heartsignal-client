class Hospital {
  final String placeId;
  final String name;
  final String address;
  final double lat;
  final double lng;
  final bool isOpen;

  Hospital({
    required this.placeId,
    required this.name,
    required this.address,
    required this.lat,
    required this.lng,
    this.isOpen = false,
  });

  factory Hospital.fromJson(Map<String, dynamic> json) {
    final location = json['location'] ?? {};
    return Hospital(
      placeId: json['placeId'] ?? '',
      name: json['name'] ?? '',
      address: json['address'] ?? '',
      lat: (location['lat'] as num?)?.toDouble() ?? 0.0,
      lng: (location['lng'] as num?)?.toDouble() ?? 0.0,
      isOpen: json['isOpen'] as bool? ?? false,
    );
  }
}
