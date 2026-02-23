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
  bool _isChatFocused = false;

  void _onChatFocusChanged(bool isFocused) {
    if (_isChatFocused != isFocused) {
      setState(() {
        _isChatFocused = isFocused;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [
          ChatScreen(
            isActive: _currentIndex == 0,
            onFocusChange: _onChatFocusChanged,
          ),
          const HospitalSearchScreen(),
          const ProfileScreen(),
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
        isKeyboardOpen: _isChatFocused && _currentIndex == 0,
      ),
    );
  }
}
