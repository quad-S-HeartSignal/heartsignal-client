import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import '../models/hospital_model.dart';
import 'custom_header.dart'; // Already exists

class HospitalDetailView extends StatelessWidget {
  final Hospital hospital;
  final VoidCallback onClose;
  final int totalCount;
  final String selectedRegion;
  final LatLng? userLocation;

  const HospitalDetailView({
    super.key,
    required this.hospital,
    required this.onClose,
    required this.totalCount,
    required this.selectedRegion,
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

    return Container(
      color: const Color(0xFFFFF5F5),
      child: Stack(
        children: [
          // Content
          Positioned.fill(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(
                top: 120,
                left: 24,
                right: 24,
                bottom: 120,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    height: 200,
                    clipBehavior: Clip.antiAlias,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey[400]!, width: 2),
                    ),
                    child:
                        (hospital.photoUrl != null &&
                            hospital.photoUrl!.isNotEmpty)
                        ? Image.network(
                            hospital.photoUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return const Center(
                                child: Icon(
                                  Icons.broken_image,
                                  size: 80,
                                  color: Colors.black26,
                                ),
                              );
                            },
                          )
                        : const Center(
                            child: Icon(
                              Icons.image,
                              size: 80,
                              color: Colors.black26,
                            ),
                          ),
                  ),
                  const SizedBox(height: 24),

                  Row(
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
                                  size: 28,
                                  color: Color(0xFFFF5252),
                                ),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    hospital.name,
                                    style: GoogleFonts.notoSans(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                _buildTag('심장 검사 가능'),
                                const SizedBox(width: 8),
                                _buildTag('응급 진료 가능'),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                _buildStarRating(hospital.rating ?? 0.0),
                                const SizedBox(width: 6),
                                Text(
                                  '(${hospital.userRatingCount})',
                                  style: GoogleFonts.notoSans(
                                    fontSize: 14,
                                    color: Colors.grey[700],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: const Color(0xFFFF5252),
                                ),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Text(
                                distanceText,
                                style: GoogleFonts.notoSans(
                                  fontSize: 12,
                                  color: const Color(0xFFFF5252),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              hospital.address,
                              style: GoogleFonts.notoSans(
                                fontSize: 14,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 8),
                            if (hospital.phoneNumber.isNotEmpty)
                              Row(
                                children: [
                                  const Icon(
                                    Icons.phone,
                                    size: 18,
                                    color: Color(0xFFFF5252),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    hospital.phoneNumber,
                                    style: GoogleFonts.notoSans(
                                      fontSize: 15,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Container(
                        width: 80,
                        height: 80,
                        margin: const EdgeInsets.only(top: 16),
                        clipBehavior: Clip.antiAlias,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.grey[400]!,
                            width: 2,
                          ),
                        ),
                        child:
                            (hospital.photoUrl != null &&
                                hospital.photoUrl!.isNotEmpty)
                            ? Image.network(
                                hospital.photoUrl!,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return const Center(
                                    child: Icon(
                                      Icons.broken_image,
                                      size: 36,
                                      color: Colors.black26,
                                    ),
                                  );
                                },
                              )
                            : const Center(
                                child: Icon(
                                  Icons.image,
                                  size: 36,
                                  color: Colors.black26,
                                ),
                              ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),

                  Center(
                    child: Column(
                      children: [
                        SizedBox(
                          width: 180,
                          height: 50,
                          child: ElevatedButton.icon(
                            onPressed: () {},
                            icon: const Icon(
                              Icons.map_outlined,
                              color: Colors.white,
                            ),
                            label: Text(
                              '길 찾기',
                              style: GoogleFonts.notoSans(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFF24E4E),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: 150,
                          height: 45,
                          child: ElevatedButton(
                            onPressed: onClose,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFF24E4E),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25),
                              ),
                            ),
                            child: Text(
                              '다른 병원 찾기',
                              style: GoogleFonts.notoSans(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: CustomHeader(showBackButton: false),
          ),
        ],
      ),
    );
  }

  Widget _buildTag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFFFEAEA),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFF5252).withAlpha(100)),
      ),
      child: Text(
        text,
        style: GoogleFonts.notoSans(
          fontSize: 11,
          color: const Color(0xFFFF5252),
          fontWeight: FontWeight.w600,
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
          return const Icon(Icons.star, size: 18, color: Color(0xFFFF5252));
        } else if (index == fullStars && hasHalfStar) {
          return const Icon(
            Icons.star_half,
            size: 18,
            color: Color(0xFFFF5252),
          );
        } else {
          return Icon(Icons.star_border, size: 18, color: Colors.grey[400]);
        }
      }),
    );
  }
}
