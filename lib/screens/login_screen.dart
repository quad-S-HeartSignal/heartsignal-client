import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/custom_button.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../widgets/step_indicator.dart';
import '../widgets/custom_header.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomHeader(showBackButton: false),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFFF5F5), Color(0xFFFFE0E0), Color(0xFFFFC6C6)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),
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
                Center(
                  child: Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.login,
                      size: 100,
                      color: Colors.blue,
                    ),
                  ),
                ),
                const Spacer(),
                const StepIndicator(
                  totalSteps: 5,
                  currentStep: 1,
                  activeColor: Color(0xFFD32F2F),
                  inactiveColor: Colors.white54,
                ),
                const SizedBox(height: 40),
                CustomButton(
                  text: '카카오 로그인',
                  backgroundColor: const Color(0xFFFFE812),
                  textColor: Colors.black,
                  onPressed: () async {
                    try {
                      final authService = context.read<AuthService>();
                      await authService.loginWithKakao();
                      if (context.mounted && authService.isLoggedIn) {
                        if (authService.currentUser?.isOnboarded ?? false) {
                          context.go('/chat');
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
      ),
    );
  }
}
