import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/chat_history_drawer.dart';
import '../widgets/custom_header.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _textController = TextEditingController();
  final List<String> _messages = [];
  bool _showRecommendations = true;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) _animationController.forward();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _textController.dispose();
    super.dispose();
  }

  void _handleSubmitted(String text) {
    if (text.isEmpty) return;
    _textController.clear();
    setState(() {
      _messages.insert(0, text);
      _showRecommendations = false;
    });
  }

  void _hideRecommendations() {
    if (_showRecommendations) {
      setState(() {
        _showRecommendations = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      appBar: CustomHeader(
        showBackButton: false,
        leadingIcon: IconButton(
          icon: const Icon(Icons.menu, color: Colors.black),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
      ),
      drawer: const ChatHistoryDrawer(),
      body: Column(
        children: [
          Expanded(
            child: _messages.isEmpty && _showRecommendations
                ? _buildRecommendations()
                : _buildMessageList(),
          ),
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildRecommendations() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 40),
          Consumer<AuthService>(
            builder: (context, authService, child) {
              final nickname = authService.currentUser?.nickname ?? '사용자';
              return Text(
                '안녕하세요, $nickname님!',
                style: GoogleFonts.notoSans(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              );
            },
          ),
          const SizedBox(height: 8),
          Text(
            '어떻게 도와드릴까요?',
            style: GoogleFonts.notoSans(fontSize: 16, color: Colors.grey[600]),
          ),
          const SizedBox(height: 40),
          _buildAnimatedButton('추천 1', 0),
          const SizedBox(height: 12),
          _buildAnimatedButton('추천 2', 1),
          const SizedBox(height: 12),
          _buildAnimatedButton('추천 3', 2),
        ],
      ),
    );
  }

  Widget _buildAnimatedButton(String text, int index) {
    final double start = index * 0.2;
    final double end = start + 0.6;

    final Animation<double> fadeAnimation = Tween<double>(begin: 0.0, end: 1.0)
        .animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Interval(start, end, curve: Curves.easeOut),
          ),
        );

    final Animation<Offset> slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Interval(start, end, curve: Curves.easeOut),
          ),
        );

    return FadeTransition(
      opacity: fadeAnimation,
      child: SlideTransition(
        position: slideAnimation,
        child: _buildRecommendationButton(text),
      ),
    );
  }

  Widget _buildRecommendationButton(String text) {
    return OutlinedButton(
      onPressed: () => _handleSubmitted(text),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        side: const BorderSide(color: Colors.grey),
        alignment: Alignment.centerLeft,
      ),
      child: Text(
        text,
        style: GoogleFonts.notoSans(color: Colors.black, fontSize: 16),
      ),
    );
  }

  Widget _buildMessageList() {
    if (_messages.isEmpty) {
      return Center(
        child: Text(
          '대화를 시작해보세요!',
          style: GoogleFonts.notoSans(color: Colors.grey),
        ),
      );
    }
    return ListView.builder(
      reverse: true,
      padding: const EdgeInsets.all(16.0),
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        return Align(
          alignment: Alignment.centerRight,
          child: Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              _messages[index],
              style: GoogleFonts.notoSans(color: Colors.white),
            ),
          ),
        );
      },
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: const Color(0xFFE0E0E0),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.black),
            onPressed: () {},
          ),
          Expanded(
            child: TextField(
              controller: _textController,
              onTap: _hideRecommendations,
              decoration: InputDecoration(
                hintText: '메시지를 입력하세요..',
                hintStyle: GoogleFonts.notoSans(color: Colors.grey[600]),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 8),
              ),
              onSubmitted: _handleSubmitted,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.mic, color: Colors.black),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.send, color: Colors.black),
            onPressed: () => _handleSubmitted(_textController.text),
          ),
        ],
      ),
    );
  }
}
