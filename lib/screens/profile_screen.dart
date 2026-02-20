import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../services/auth_service.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          Text(
            '내 프로필',
            style: GoogleFonts.notoSans(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF191F83), // Dark Blue color from design
            ),
          ),
          const SizedBox(height: 30),
          // User Card
          Consumer<AuthService>(
            builder: (context, authService, child) {
              final user = authService.currentUser;
              final nickname = user?.nickname ?? '사용자';
              final profileImage = user?.profileImage;

              return Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: const Color(0xFFE0E0E0),
                    backgroundImage:
                        profileImage != null && profileImage.isNotEmpty
                        ? NetworkImage(profileImage)
                        : null,
                    child: profileImage == null || profileImage.isEmpty
                        ? const Icon(Icons.person, size: 40, color: Colors.grey)
                        : null,
                  ),
                  const SizedBox(width: 16),
                  Text(
                    '안녕하세요, $nickname님.',
                    style: GoogleFonts.notoSans(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF757575),
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 40),
          // Accordion Menu
          Theme(
            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
              initiallyExpanded: true,
              tilePadding: EdgeInsets.zero,
              leading: const Icon(
                Icons.article_outlined,
                color: Color(0xFF191F83),
              ),
              title: Text(
                '프로필 수정',
                style: GoogleFonts.notoSans(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              children: [
                const SizedBox(height: 10),
                _buildProfileItem(label: 'A', title: '이름', value: 'OOO'),
                _buildProfileItem(
                  icon: Icons.calendar_today_outlined,
                  title: '생년월일',
                  value: '2000.01.01',
                ),
                _buildProfileItem(
                  icon: Icons.location_on_outlined,
                  title: '위치',
                  value: '서울시 강남구',
                ),
                _buildProfileItem(
                  icon: Icons.phone_in_talk_outlined,
                  title: '보호자 연락처',
                  value: '010-0000-0000',
                ),
                _buildProfileItem(
                  icon: Icons.phone_iphone_outlined,
                  title: '사용자 연락처',
                  value: '010-1234-5678',
                ),
              ],
            ),
          ),
          const SizedBox(height: 8), // Consistent spacing
          // Account Management
          Column(
            children: [
              ListTile(
                contentPadding: EdgeInsets.zero,
                dense: true,
                visualDensity: VisualDensity.compact,
                leading: const Icon(Icons.logout, color: Color(0xFF191F83)),
                title: Text(
                  '로그아웃',
                  style: GoogleFonts.notoSans(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                onTap: () async {
                  await context.read<AuthService>().logout();
                  if (context.mounted) {
                    context.go('/login');
                  }
                },
              ),
              const SizedBox(height: 8), // Consistent spacing
              ListTile(
                contentPadding: EdgeInsets.zero,
                dense: true,
                visualDensity: VisualDensity.compact,
                leading: const Icon(
                  Icons.delete_outline,
                  color: Color(0xFFD32F2F),
                ),
                title: Text(
                  '회원 탈퇴',
                  style: GoogleFonts.notoSans(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFFD32F2F),
                  ),
                ),
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('회원 탈퇴'),
                      content: const Text(
                        '정말로 탈퇴하시겠습니까?\n모든 데이터가 삭제되며 복구할 수 없습니다.',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('취소'),
                        ),
                        TextButton(
                          onPressed: () async {
                            Navigator.pop(context); // Close dialog
                            try {
                              await context.read<AuthService>().deleteAccount();
                              if (context.mounted) {
                                context.go('/login');
                              }
                            } catch (e) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('탈퇴 실패: $e'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            }
                          },
                          child: const Text(
                            '탈퇴',
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 100), // Spacer for CustomBottomNavBar
        ],
      ),
    );
  }

  Widget _buildProfileItem({
    String? label,
    IconData? icon,
    required String title,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        children: [
          SizedBox(
            width: 40,
            child: Center(
              child: label != null
                  ? Text(
                      label,
                      style: GoogleFonts.notoSans(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.black,
                      ),
                    )
                  : Icon(icon, size: 20, color: Colors.black),
            ),
          ),
          const SizedBox(width: 16),
          Text(
            title,
            style: GoogleFonts.notoSans(
              fontSize: 16,
              color: Colors.black,
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
        ],
      ),
    );
  }
}
