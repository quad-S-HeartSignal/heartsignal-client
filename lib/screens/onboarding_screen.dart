import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_header.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _guardianContactController = TextEditingController();
  final _birthdateController = TextEditingController();

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      try {
        await context.read<AuthService>().completeOnboarding(
          _guardianContactController.text,
          _birthdateController.text,
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
  void dispose() {
    _guardianContactController.dispose();
    _birthdateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),
                const CustomHeader(title: '추가 정보 입력'),
                const SizedBox(height: 8),
                Text(
                  '서비스 이용을 위해\n추가 정보를 입력해주세요.',
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
                TextFormField(
                  controller: _guardianContactController,
                  decoration: const InputDecoration(
                    labelText: '보호자 연락처',
                    hintText: '010-1234-5678',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '보호자 연락처를 입력해주세요';
                    }
                    if (!RegExp(r'^\d{3}-\d{3,4}-\d{4}$').hasMatch(value)) {
                      return '올바른 전화번호 형식이 아닙니다 (010-XXXX-XXXX)';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _birthdateController,
                  decoration: const InputDecoration(
                    labelText: '생년월일',
                    hintText: 'YYYY-MM-DD',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.datetime,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '생년월일을 입력해주세요';
                    }
                    if (!RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(value)) {
                      return '올바른 날짜 형식이 아닙니다 (YYYY-MM-DD)';
                    }
                    return null;
                  },
                ),
                const Spacer(),
                Consumer<AuthService>(
                  builder: (context, auth, _) {
                    return CustomButton(
                      text: auth.isLoading ? '처리중...' : '완료',
                      onPressed: auth.isLoading ? () {} : _submit,
                      backgroundColor: Colors.black,
                      textColor: Colors.white,
                    );
                  },
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
