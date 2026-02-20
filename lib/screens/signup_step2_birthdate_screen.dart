import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/step_indicator.dart';
import '../widgets/custom_header.dart';

class SignupStep2BirthdateScreen extends StatefulWidget {
  const SignupStep2BirthdateScreen({super.key});

  @override
  State<SignupStep2BirthdateScreen> createState() =>
      _SignupStep2BirthdateScreenState();
}

class _SignupStep2BirthdateScreenState
    extends State<SignupStep2BirthdateScreen> {
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const CustomHeader(), // Changed this line
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
                '마지막으로',
                style: GoogleFonts.notoSans(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'OO님의 생년월일을 부탁드립니다',
                style: GoogleFonts.notoSans(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              CustomTextField(
                label: '생년월일',
                hintText: 'YYYY.MM.DD',
                controller: _controller,
                keyboardType: TextInputType.datetime,
              ),
              const Spacer(),
              // Placeholder for the 3D Robot Image
              Center(
                child: Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    color: Colors.blue[50], // Light blue placeholder
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.calendar_today,
                    size: 80,
                    color: Colors.blue,
                  ),
                ),
              ),
              const Spacer(),
              const StepIndicator(
                totalSteps: 4,
                currentStep: 3,
                activeColor: Colors.black,
                inactiveColor: Color(0xFFE0E0E0),
              ),
              const SizedBox(height: 40),
              CustomButton(
                text: '다음',
                backgroundColor: Colors.grey[800]!,
                onPressed: () {
                  context.push('/completion');
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
