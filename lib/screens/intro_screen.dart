import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/custom_button.dart';
import '../widgets/step_indicator.dart';
import '../widgets/custom_header.dart';

class IntroScreen extends StatelessWidget {
  const IntroScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const CustomHeader(showBackButton: false),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              Text(
                '지금 혼자 고민하지\n않아도 괜찮아요',
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
                    color: Colors.blue[50], // Light blue placeholder
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.security, // Placeholder icon
                    size: 100,
                    color: Colors.blue,
                  ),
                ),
              ),
              const Spacer(),
              const StepIndicator(
                totalSteps: 4,
                currentStep: 0,
                activeColor: Colors.black,
                inactiveColor: Color(0xFFE0E0E0),
              ),
              const SizedBox(height: 40),
              CustomButton(
                text: '시작하기',
                onPressed: () {
                  context.push('/login');
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
