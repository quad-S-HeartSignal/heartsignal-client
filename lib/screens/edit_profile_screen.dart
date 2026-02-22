import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../services/auth_service.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController _nameController;
  late TextEditingController _birthdateController;
  late TextEditingController _locationController;
  late TextEditingController _guardianContactController;
  late TextEditingController _userContactController;

  bool _isModified = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthService>().currentUser;

    _nameController = TextEditingController(text: user?.nickname ?? '');
    _birthdateController = TextEditingController(text: user?.birthdate ?? '');
    _locationController = TextEditingController(text: user?.location ?? '');
    _guardianContactController = TextEditingController(
      text: user?.guardianContact ?? '',
    );
    _userContactController = TextEditingController(
      text: user?.userContact ?? '',
    );

    _nameController.addListener(_checkIfModified);
    _birthdateController.addListener(_checkIfModified);
    _locationController.addListener(_checkIfModified);
    _guardianContactController.addListener(_checkIfModified);
    _userContactController.addListener(_checkIfModified);
  }

  void _checkIfModified() {
    final user = context.read<AuthService>().currentUser;
    final isModified =
        _nameController.text != (user?.nickname ?? '') ||
        _birthdateController.text != (user?.birthdate ?? '') ||
        _locationController.text != (user?.location ?? '') ||
        _guardianContactController.text != (user?.guardianContact ?? '') ||
        _userContactController.text != (user?.userContact ?? '');

    if (_isModified != isModified) {
      setState(() {
        _isModified = isModified;
      });
    }
  }

  Future<void> _saveProfile() async {
    if (!_isModified || _isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await context.read<AuthService>().updateProfile(
        nickname: _nameController.text,
        birthdate: _birthdateController.text,
        location: _locationController.text,
        guardianContact: _guardianContactController.text,
        userContact: _userContactController.text,
      );
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('프로필이 성공적으로 저장되었습니다.')));
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('프로필 저장 실패: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _birthdateController.dispose();
    _locationController.dispose();
    _guardianContactController.dispose();
    _userContactController.dispose();
    super.dispose();
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    Widget? suffixIcon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4.0, bottom: 8.0),
          child: Text(
            label,
            style: GoogleFonts.notoSans(
              fontSize: 12,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: TextField(
            controller: controller,
            style: GoogleFonts.notoSans(fontSize: 16, color: Colors.black),
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
              border: InputBorder.none,
              // Add red suffix icon conditionally if provided
              suffixIcon: suffixIcon,
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthService>().currentUser;
    final nickname = user?.nickname ?? '사용자';
    final profileImage = user?.profileImage;

    return Scaffold(
      backgroundColor: const Color(0xFFFFF5F5), // Light pink background
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => context.pop(),
        ),
        title: Text(
          '내 프로필',
          style: GoogleFonts.notoSans(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF191F83),
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              // Profile Image
              CircleAvatar(
                radius: 40,
                backgroundColor: const Color(0xFFE0E0E0),
                backgroundImage: profileImage != null && profileImage.isNotEmpty
                    ? NetworkImage(profileImage)
                    : null,
                child: profileImage == null || profileImage.isEmpty
                    ? const Icon(Icons.person, size: 50, color: Colors.grey)
                    : null,
              ),
              const SizedBox(height: 16),
              // Nickname
              Text(
                '$nickname님',
                style: GoogleFonts.notoSans(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 40),

              // Input Fields
              _buildTextField('이름', _nameController),
              _buildTextField(
                '생년월일',
                _birthdateController,
                suffixIcon: const Icon(
                  Icons.calendar_today_outlined,
                  color: Color(0xFFEF5350), // Reddish icon
                  size: 20,
                ),
              ),
              _buildTextField('위치', _locationController),
              _buildTextField('보호자 연락처', _guardianContactController),
              _buildTextField('사용자 연락처', _userContactController),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _isModified && !_isLoading ? _saveProfile : null,
              style: ElevatedButton.styleFrom(
                disabledBackgroundColor: Colors.grey[350],
                backgroundColor: const Color(0xFFEF5350), // Red color
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : Text(
                      '저장',
                      style: GoogleFonts.notoSans(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: _isModified ? Colors.white : Colors.grey[600],
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
