class Hospital {
  final String name;
  final double rating;
  final int reviewCount;
  final double distance; // in km
  final String address;
  final String phoneNumber;
  final List<String> tags;
  final double latitude;
  final double longitude;
  final String imageAsset; // Placeholder for now

  Hospital({
    required this.name,
    required this.rating,
    required this.reviewCount,
    required this.distance,
    required this.address,
    required this.phoneNumber,
    required this.tags,
    required this.latitude,
    required this.longitude,
    this.imageAsset = '', // Default empty if not provided
  });
}
