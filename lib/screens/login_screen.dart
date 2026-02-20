import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/custom_header.dart';
import '../widgets/custom_button.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../widgets/step_indicator.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const CustomHeader(),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              Text(
                'HeartSignal',
                style: GoogleFonts.notoSans(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Text(
                '계속 하려면\n로그인 해주세요!',
                style: GoogleFonts.notoSans(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
              const Spacer(),
              // Placeholder for the 3D Robot Image
              Center(
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.login, size: 100, color: Colors.blue),
                ),
              ),
              const Spacer(),
              const StepIndicator(
                totalSteps: 4,
                currentStep: 1, // Assume step 1
                activeColor: Colors.black,
                inactiveColor: Color(0xFFE0E0E0),
              ),
              const SizedBox(height: 40),
              CustomButton(
                text: '카카오 로그인',
                backgroundColor: const Color(0xFFFFE812), // Kakao Yellow
                textColor: Colors.black,
                onPressed: () async {
                  try {
                    final authService = context.read<AuthService>();
                    await authService.loginWithKakao();
                    if (context.mounted && authService.isLoggedIn) {
                      if (authService.currentUser?.isOnboarded ?? false) {
                        context.go('/home');
                      } else {
                        context.go('/onboarding');
                      }
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Login Failed: $e')),
                      );
                    }
                  }
                },
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
