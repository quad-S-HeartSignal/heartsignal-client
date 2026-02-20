import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final VoidCallback onEmergencyTap;

  const CustomBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.onEmergencyTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100, // Keep height for the big button
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).padding.bottom,
      ), // Respect Safe Area
      decoration: BoxDecoration(
        color: const Color(0xFFD9D9D9), // Light grey background
        borderRadius: currentIndex == 1
            ? BorderRadius.zero
            : const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
      ),
      // Margin removed to attach to bottom
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Emergency Button
          GestureDetector(
            onTap: onEmergencyTap,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF222222), // Dark pill
                borderRadius: BorderRadius.circular(30),
              ),
              child: Text(
                '응급 모드',
                textAlign: TextAlign.center,
                style: GoogleFonts.notoSans(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          // Navigation Items
          _buildNavItem(icon: Icons.home_outlined, label: 'Home', index: 0),
          _buildNavItem(
            icon: Icons.chat_bubble_outline,
            label: 'Chat',
            index: 1,
          ),
          _buildNavItem(
            icon: Icons.location_on_outlined,
            label: '병원 찾기',
            index: 2,
          ),
          _buildNavItem(icon: Icons.person_outline, label: 'Profile', index: 3),

          // profile
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
  }) {
    final isSelected = currentIndex == index;
    return GestureDetector(
      onTap: () => onTap(index),
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 24,
            color: isSelected ? Colors.white : Colors.black87,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.notoSans(
              fontSize: 12,
              fontWeight: FontWeight.normal,
              color: isSelected ? Colors.white : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
