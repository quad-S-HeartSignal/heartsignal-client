import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../widgets/custom_bottom_nav_bar.dart';
import 'chat_screen.dart';
import 'hospital_search_screen.dart';
import 'profile_screen.dart';

class RootScreen extends StatefulWidget {
  const RootScreen({super.key});

  @override
  State<RootScreen> createState() => _RootScreenState();
}

class _RootScreenState extends State<RootScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final bool isKeyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [
          ChatScreen(isActive: _currentIndex == 0),
          const HospitalSearchScreen(),
          const Scaffold(body: SafeArea(child: ProfileScreen())),
        ],
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        onEmergencyTap: () {
          context.push('/emergency');
        },
        isKeyboardOpen: isKeyboardOpen && _currentIndex == 0,
      ),
    );
  }
}
