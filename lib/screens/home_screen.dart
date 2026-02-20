import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../widgets/custom_bottom_nav_bar.dart';
import 'chat_screen.dart';
import 'hospital_search_screen.dart';
import 'profile_screen.dart';
import '../widgets/custom_header.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0; // 0: Home, 1: Chat, 2: Hospital, 3: Profile

  final GlobalKey<_CalendarWidgetState> _calendarKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: (_currentIndex == 0 || _currentIndex == 3)
          ? const CustomHeader(showBackButton: false)
          : null,
      body: SafeArea(
        bottom: false,
        child: Stack(
          fit: StackFit.expand, // Ensure stack fills the screen
          children: [
            // Body content logic
            if (_currentIndex == 1)
              const ChatScreen()
            else if (_currentIndex == 2)
              const HospitalSearchScreen()
            else if (_currentIndex == 3)
              const ProfileScreen()
            else
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 20),
                    // Header removed
                    const SizedBox(height: 40),
                    Consumer<AuthService>(
                      builder: (context, authService, child) {
                        final nickname =
                            authService.currentUser?.nickname ?? '사용자';
                        return Text(
                          '안녕하세요, $nickname님!',
                          style: GoogleFonts.notoSans(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        );
                      },
                    ),
                    const SizedBox(height: 40),

                    // Calendar Strip
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.calendar_today,
                              size: 16,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              // Simple formatting without intl just to be safe/quick
                              '${DateTime.now().year}년 ${DateTime.now().month.toString().padLeft(2, '0')}월 ${DateTime.now().day.toString().padLeft(2, '0')}일',
                              style: GoogleFonts.notoSans(
                                fontSize: 14,
                                color: Colors.grey[700],
                              ),
                            ),
                          ],
                        ),
                        GestureDetector(
                          onTap: () {
                            _calendarKey.currentState?.goToToday();
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              '오늘',
                              style: GoogleFonts.notoSans(fontSize: 12),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _CalendarWidget(key: _calendarKey),
                    const SizedBox(height: 40),

                    // Dashboard Cards
                    Expanded(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Left: Today's Guide (Tall)
                          Expanded(
                            flex: 1,
                            child: Container(
                              height: 280,
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: const Color(0xFF9E9E9E), // Darker Grey
                                borderRadius: BorderRadius.circular(24),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Center(
                                    child: Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: const BoxDecoration(
                                        color: Colors.white,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.description_outlined,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    '오늘의 가이드',
                                    style: GoogleFonts.notoSans(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    '1. 문장\n2. 문장\n3. 문장',
                                    style: GoogleFonts.notoSans(
                                      fontSize: 14,
                                      color: Colors.black87,
                                      height: 1.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          // Right Column
                          Expanded(
                            flex: 1,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                // Top Right: Heart Condition
                                Container(
                                  height: 132,
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: const Color(
                                      0xFFE0E0E0,
                                    ), // Light Grey
                                    borderRadius: BorderRadius.circular(24),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(6),
                                            decoration: const BoxDecoration(
                                              color: Colors.white,
                                              shape: BoxShape.circle,
                                            ),
                                            child: const Icon(
                                              Icons.monitor_heart_outlined,
                                              size: 16,
                                              color: Colors.black,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              '오늘 심장 상태\n관련 영역',
                                              style: GoogleFonts.notoSans(
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                                height: 1.2,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const Spacer(),
                                      Center(
                                        child: Text(
                                          '문장',
                                          style: GoogleFonts.notoSans(
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                      const Spacer(),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8, height: 16),
                                // Bottom Right: Check Status
                                Container(
                                  height: 132,
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: const Color(
                                      0xFFEEEEEE,
                                    ), // Very Light Grey
                                    borderRadius: BorderRadius.circular(24),
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: const BoxDecoration(
                                          color: Colors.white,
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.chat_bubble_outline,
                                          color: Colors.black,
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      Text(
                                        '지금 상태 체크하기',
                                        style: GoogleFonts.notoSans(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 120), // Spacer for BottomNavBar
                  ],
                ),
              ),

            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: CustomBottomNavBar(
                currentIndex: _currentIndex,
                onTap: (index) {
                  setState(() {
                    _currentIndex = index;
                  });
                },
                onEmergencyTap: () {
                  context.push('/emergency');
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CalendarWidget extends StatefulWidget {
  const _CalendarWidget({super.key});

  @override
  State<_CalendarWidget> createState() => _CalendarWidgetState();
}

class _CalendarWidgetState extends State<_CalendarWidget> {
  late PageController _pageController;
  final int _initialPage = 5000;
  late DateTime _initialMonday;

  void goToToday() {
    _pageController.animateToPage(
      _initialPage,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _initialPage);

    // Calculate the Monday of the current week to use as a baseline
    final now = DateTime.now();
    _initialMonday = now.subtract(Duration(days: now.weekday - 1));
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 80,
      child: PageView.builder(
        controller: _pageController,
        itemBuilder: (context, index) {
          final weekOffset = index - _initialPage;
          final monday = _initialMonday.add(Duration(days: weekOffset * 7));

          final weekDates = List.generate(7, (i) {
            return monday.add(Duration(days: i));
          });

          final days = ['월', '화', '수', '목', '금', '토', '일'];
          final now = DateTime.now();

          return Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
            ), // Gap between weeks
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(7, (i) {
                final date = weekDates[i];
                final isToday =
                    date.year == now.year &&
                    date.month == now.month &&
                    date.day == now.day;

                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      days[i],
                      style: GoogleFonts.notoSans(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      date.day.toString(),
                      style: GoogleFonts.notoSans(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: isToday ? Colors.black : Colors.grey[300],
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                );
              }),
            ),
          );
        },
      ),
    );
  }
}
