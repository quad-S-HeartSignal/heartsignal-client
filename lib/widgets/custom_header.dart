import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomHeader extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showBackButton;
  final VoidCallback? onBackData;
  final Widget? leadingIcon;
  final List<Widget>? actions;

  const CustomHeader({
    super.key,
    this.title = 'HeartSignal',
    this.showBackButton = true,
    this.onBackData,
    this.actions,
    this.leadingIcon,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: const Color(0xFFFFF5F5),
      scrolledUnderElevation: 0, // Disable color change on scroll
      elevation: 0,
      centerTitle: true,
      leading:
          leadingIcon ??
          (showBackButton
              ? IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.black),
                  onPressed: onBackData ?? () => Navigator.of(context).pop(),
                )
              : null),
      title: Text(
        title,
        style: GoogleFonts.notoSans(
          color: Colors.black,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      actions: actions,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
