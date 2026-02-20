import 'package:go_router/go_router.dart';
import 'screens/intro_screen.dart';
import 'screens/login_screen.dart';
import 'screens/signup_step1_guardian_screen.dart';
import 'screens/signup_step2_birthdate_screen.dart';
import 'screens/completion_screen.dart';
import 'screens/onboarding_step1_screen.dart';
import 'screens/onboarding_step2_screen.dart';
import 'screens/chat_screen.dart';
import 'screens/emergency_screen.dart';
import 'screens/hospital_map_screen.dart';

final router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (context, state) => const IntroScreen()),
    GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
    GoRoute(
      path: '/signup/guardian', // Adjusted to match my implementation
      builder: (context, state) => const SignupStep1GuardianScreen(),
    ),
    GoRoute(
      path: '/signup/birthdate',
      builder: (context, state) => const SignupStep2BirthdateScreen(),
    ),
    GoRoute(
      path: '/completion',
      builder: (context, state) => const CompletionScreen(),
    ),
    GoRoute(path: '/chat', builder: (context, state) => const ChatScreen()),
    GoRoute(
      path: '/emergency',
      builder: (context, state) => const EmergencyScreen(),
    ),
    GoRoute(
      path: '/hospitals',
      builder: (context, state) => const HospitalMapScreen(),
    ),
    GoRoute(
      path: '/onboarding',
      builder: (context, state) => const OnboardingStep1Screen(),
      routes: [
        GoRoute(
          path: 'step2',
          builder: (context, state) {
            final guardianContact = state.extra as String;
            return OnboardingStep2Screen(guardianContact: guardianContact);
          },
        ),
      ],
    ),
  ],
);
