import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../services/auth_service.dart';
import '../widgets/custom_header.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthService>(
      builder: (context, authService, child) {
        final user = authService.currentUser;
        final nickname = user?.nickname ?? '사용자';
        final profileImage = user?.profileImage;

        return Scaffold(
          backgroundColor: const Color(0xFFFFF5F5),
          appBar: const CustomHeader(showBackButton: false),
          body: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
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
                          color: const Color(0xFF191F83),
                        ),
                      ),
                      const SizedBox(height: 30),
                      // User Card
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 30,
                            backgroundColor: const Color(0xFFE0E0E0),
                            backgroundImage:
                                profileImage != null && profileImage.isNotEmpty
                                ? NetworkImage(profileImage)
                                : null,
                            child: profileImage == null || profileImage.isEmpty
                                ? const Icon(
                                    Icons.person,
                                    size: 40,
                                    color: Colors.grey,
                                  )
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
                      ),
                      const SizedBox(height: 40),
                      // Menus
                      Theme(
                        data: Theme.of(
                          context,
                        ).copyWith(dividerColor: Colors.transparent),
                        child: ExpansionTile(
                          initiallyExpanded: true,
                          tilePadding: EdgeInsets.zero,
                          leading: const Icon(
                            Icons.article_outlined,
                            color: Color(0xFF191F83),
                          ),
                          title: Text(
                            '프로필 정보',
                            style: GoogleFonts.notoSans(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          children: [
                            const SizedBox(height: 10),
                            _ReadOnlyExpandableProfileItem(
                              label: 'A',
                              title: '이름',
                              value: user?.nickname ?? '',
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16.0),
                              child: Divider(
                                color: Color(0xFFF0F0F0),
                                height: 1,
                              ),
                            ),
                            _ReadOnlyExpandableProfileItem(
                              icon: Icons.calendar_today_outlined,
                              title: '생년월일',
                              value: user?.birthdate ?? '',
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16.0),
                              child: Divider(
                                color: Color(0xFFF0F0F0),
                                height: 1,
                              ),
                            ),
                            _ReadOnlyExpandableProfileItem(
                              icon: Icons.location_on_outlined,
                              title: '위치',
                              value: user?.location ?? '',
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16.0),
                              child: Divider(
                                color: Color(0xFFF0F0F0),
                                height: 1,
                              ),
                            ),
                            _ReadOnlyExpandableProfileItem(
                              icon: Icons.phone_in_talk_outlined,
                              title: '보호자 연락처',
                              value: user?.guardianContact ?? '',
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16.0),
                              child: Divider(
                                color: Color(0xFFF0F0F0),
                                height: 1,
                              ),
                            ),
                            _ReadOnlyExpandableProfileItem(
                              icon: Icons.phone_iphone_outlined,
                              title: '사용자 연락처',
                              value: user?.userContact ?? '',
                            ),
                          ],
                        ),
                      ),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(
                          Icons.logout,
                          color: Color(0xFF191F83),
                        ),
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
                      ListTile(
                        contentPadding: EdgeInsets.zero,
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
                                    Navigator.pop(context);
                                    try {
                                      await context
                                          .read<AuthService>()
                                          .deleteAccount();
                                      if (context.mounted) {
                                        context.go('/login');
                                      }
                                    } catch (e) {
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
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
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                  left: 24.0,
                  right: 24.0,
                  bottom: 24.0,
                  top: 16.0,
                ),
                child: SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () {
                      context.push('/edit-profile');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFEF5350),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      '프로필 수정하기',
                      style: GoogleFonts.notoSans(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ReadOnlyExpandableProfileItem extends StatefulWidget {
  final String? label;
  final IconData? icon;
  final String title;
  final String value;

  const _ReadOnlyExpandableProfileItem({
    this.label,
    this.icon,
    required this.title,
    required this.value,
  });

  @override
  State<_ReadOnlyExpandableProfileItem> createState() =>
      _ReadOnlyExpandableProfileItemState();
}

class _ReadOnlyExpandableProfileItemState
    extends State<_ReadOnlyExpandableProfileItem> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: () {
            setState(() {
              _isExpanded = !_isExpanded;
            });
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 16.0,
              horizontal: 16.0,
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 32,
                  child: Center(
                    child: widget.label != null
                        ? Text(
                            widget.label!,
                            style: GoogleFonts.notoSans(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: Colors.black,
                            ),
                          )
                        : Icon(widget.icon, size: 20, color: Colors.black),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  widget.title,
                  style: GoogleFonts.notoSans(
                    fontSize: 16,
                    color: Colors.black,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                Icon(
                  _isExpanded
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  color: Colors.grey,
                  size: 20,
                ),
                if (!_isExpanded) const SizedBox(width: 8),
              ],
            ),
          ),
        ),
        if (_isExpanded)
          Padding(
            padding: const EdgeInsets.only(
              left: 56.0,
              right: 24.0,
              bottom: 16.0,
            ),
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: Colors.black87)),
              ),
              child: Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Text(
                  widget.value,
                  style: GoogleFonts.notoSans(
                    fontSize: 16,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
