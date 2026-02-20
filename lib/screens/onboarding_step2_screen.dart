import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../widgets/custom_button.dart';

class OnboardingStep2Screen extends StatefulWidget {
  final String guardianContact;

  const OnboardingStep2Screen({super.key, required this.guardianContact});

  @override
  State<OnboardingStep2Screen> createState() => _OnboardingStep2ScreenState();
}

class _OnboardingStep2ScreenState extends State<OnboardingStep2Screen> {
  final _controller = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      try {
        // Convert YYYY.MM.DD to YYYY-MM-DD for backend
        final birthdate = _controller.text.replaceAll('.', '-');

        await context.read<AuthService>().completeOnboarding(
          widget.guardianContact,
          birthdate,
        );

        if (mounted) {
          context.go('/completion');
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Onboarding failed: $e')));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFFFF0F0), // Light pink top
              Color(0xFFFFC0C0), // Darker pink bottom
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 20),
                  // Logo Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.favorite, color: Colors.red, size: 24),
                      const SizedBox(width: 8),
                      Text(
                        'HeartSignal',
                        style: GoogleFonts.notoSans(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 60),
                  // Welcome Text
                  Text(
                    '마지막으로',
                    style: GoogleFonts.notoSans(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Consumer<AuthService>(
                    builder: (context, authService, child) {
                      final nickname =
                          authService.currentUser?.nickname ?? 'OO';
                      return Text(
                        '$nickname님의 생년월일을 부탁드립니다!',
                        style: GoogleFonts.notoSans(
                          fontSize: 14,
                          color: Colors.black54,
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 60),
                  // Date Input
                  Text(
                    '생년월일',
                    style: GoogleFonts.notoSans(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _controller,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      _DateFormatter(),
                    ],
                    decoration: InputDecoration(
                      hintText: '0000.00.00',
                      hintStyle: GoogleFonts.notoSans(color: Colors.black26),
                      enabledBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.black),
                      ),
                      focusedBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.red, width: 2),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '생년월일을 입력해주세요';
                      }
                      if (value.length != 10) {
                        return '올바른 날짜를 입력해주세요 (YYYY.MM.DD)';
                      }
                      return null;
                    },
                  ),
                  const Spacer(),
                  // Step Indicator
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildDot(false),
                      const SizedBox(width: 8),
                      _buildDot(false),
                      const SizedBox(width: 8),
                      _buildDot(false),
                      const SizedBox(width: 8),
                      _buildDot(true), // Active
                      const SizedBox(width: 8),
                      _buildDot(false),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Consumer<AuthService>(
                    builder: (context, auth, _) {
                      return CustomButton(
                        text: auth.isLoading ? '처리중...' : '다음',
                        backgroundColor: const Color(0xFFD32F2F), // Red
                        textColor: Colors.white,
                        onPressed: auth.isLoading ? () {} : _submit,
                      );
                    },
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDot(bool isActive) {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFFD32F2F) : Colors.black12,
        shape: BoxShape.circle,
      ),
    );
  }
}

class _DateFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    var digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    var formatted = '';

    // YYYY.MM.DD
    if (digits.length <= 4) {
      formatted = digits;
    } else if (digits.length <= 6) {
      formatted = '${digits.substring(0, 4)}.${digits.substring(4)}';
    } else {
      if (digits.length > 8) digits = digits.substring(0, 8);
      formatted =
          '${digits.substring(0, 4)}.${digits.substring(4, 6)}.${digits.substring(6)}';
    }

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
