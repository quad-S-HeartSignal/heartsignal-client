import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../widgets/custom_button.dart';
import '../widgets/step_indicator.dart';

class CompletionScreen extends StatelessWidget {
  const CompletionScreen({super.key});

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
                const Spacer(flex: 2),
                // Character Placeholder
                Center(
                  child: Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(127),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.favorite,
                      size: 100,
                      color: Colors.red,
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                // Welcome Text
                Consumer<AuthService>(
                  builder: (context, authService, child) {
                    final nickname = authService.currentUser?.nickname ?? 'OO';
                    return Column(
                      children: [
                        Text(
                          '다시 환영합니다,\n$nickname님!!',
                          style: GoogleFonts.notoSans(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                            height: 1.3,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          '이제 들어가실 수 있습니다!',
                          style: GoogleFonts.notoSans(
                            fontSize: 18,
                            color: Colors.black87,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    );
                  },
                ),
                const Spacer(flex: 3),
                // Step Indicator
                const StepIndicator(
                  totalSteps: 4,
                  currentStep: 4,
                  activeColor: Color(0xFFD32F2F), // Darker red for active
                  inactiveColor: Colors.white,
                ),
                const SizedBox(height: 40),
                // Enter Button
                CustomButton(
                  text: '들어가기',
                  backgroundColor: const Color(0xFFD32F2F), // Red color
                  textColor: Colors.white,
                  onPressed: () {
                    context.go('/chat');
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
