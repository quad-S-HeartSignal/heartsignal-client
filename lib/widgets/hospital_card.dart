import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import '../models/hospital_model.dart';

class HospitalCard extends StatelessWidget {
  final Hospital hospital;
  final VoidCallback onTap;
  final LatLng? userLocation;

  const HospitalCard({
    super.key,
    required this.hospital,
    required this.onTap,
    this.userLocation,
  });

  @override
  Widget build(BuildContext context) {
    String distanceText = '? km';
    if (userLocation != null) {
      double distanceInMeters = Geolocator.distanceBetween(
        userLocation!.latitude,
        userLocation!.longitude,
        hospital.lat,
        hospital.lng,
      );
      double distanceInKm = distanceInMeters / 1000;
      distanceText = '${distanceInKm.toStringAsFixed(1)} km';
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 24.0),
        color: Colors.white,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.location_on,
                        size: 24,
                        color: Color(0xFFFF5252),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          hospital.name,
                          style: GoogleFonts.notoSans(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      _buildTag('심장 검사 가능'),
                      const SizedBox(width: 4),
                      _buildTag('응급 진료 가능'),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // 2. Rating Row
                  Row(
                    children: [
                      _buildStarRating(hospital.rating ?? 0.0),
                      const SizedBox(width: 4),
                      Text(
                        '(${hospital.userRatingCount})',
                        style: GoogleFonts.notoSans(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFFFF5252)),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      distanceText,
                      style: GoogleFonts.notoSans(
                        fontSize: 12,
                        color: const Color(0xFFFF5252),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),

                  Text(
                    hospital.address,
                    style: GoogleFonts.notoSans(
                      fontSize: 14,
                      color: Colors.black87,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),

                  if (hospital.phoneNumber.isNotEmpty)
                    Row(
                      children: [
                        const Icon(
                          Icons.phone,
                          size: 16,
                          color: Color(0xFFFF5252),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          hospital.phoneNumber,
                          style: GoogleFonts.notoSans(
                            fontSize: 14,
                            color: Colors.grey[800],
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Container(
              width: 90,
              height: 90,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[400]!, width: 2),
              ),
              child:
                  (hospital.photoUrl != null && hospital.photoUrl!.isNotEmpty)
                  ? Image.network(
                      hospital.photoUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        // Fallback if image fails to load
                        return const Center(
                          child: Icon(
                            Icons.broken_image,
                            size: 40,
                            color: Colors.black26,
                          ),
                        );
                      },
                    )
                  : const Center(
                      child: Icon(Icons.image, size: 40, color: Colors.black26),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: const Color(0xFFFFEAEA),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFF5252).withAlpha(100)),
      ),
      child: Text(
        text,
        style: GoogleFonts.notoSans(
          fontSize: 10,
          color: const Color(0xFFFF5252),
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildStarRating(double rating) {
    int fullStars = rating.floor();
    bool hasHalfStar = (rating - fullStars) >= 0.5;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        if (index < fullStars) {
          return const Icon(Icons.star, size: 16, color: Color(0xFFFF5252));
        } else if (index == fullStars && hasHalfStar) {
          return const Icon(
            Icons.star_half,
            size: 16,
            color: Color(0xFFFF5252),
          );
        } else {
          return Icon(Icons.star_border, size: 16, color: Colors.grey[400]);
        }
      }),
    );
  }
}
