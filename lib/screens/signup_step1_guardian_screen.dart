import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/step_indicator.dart';
import '../widgets/custom_header.dart';

class SignupStep1GuardianScreen extends StatefulWidget {
  const SignupStep1GuardianScreen({super.key});

  @override
  State<SignupStep1GuardianScreen> createState() =>
      _SignupStep1GuardianScreenState();
}

class _SignupStep1GuardianScreenState extends State<SignupStep1GuardianScreen> {
  final TextEditingController _controller = TextEditingController();

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
                '환영합니다, OO님!',
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
                '위급 상황에 대비해 보호자 연락처를 등록해주세요',
                style: GoogleFonts.notoSans(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              CustomTextField(
                label: '보호자 연락처 등록',
                hintText: '010-0000-0000',
                controller: _controller,
                keyboardType: TextInputType.phone,
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
                    Icons.contact_phone,
                    size: 80,
                    color: Colors.blue,
                  ),
                ),
              ),
              const Spacer(),
              const StepIndicator(
                totalSteps: 4,
                currentStep: 2,
                activeColor: Colors.black,
                inactiveColor: Color(0xFFE0E0E0),
              ),
              const SizedBox(height: 40),
              CustomButton(
                text: '다음',
                backgroundColor: Colors.grey[800]!, // Example dark grey
                onPressed: () {
                  context.push('/signup/birthdate');
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
