import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/chat_history_drawer.dart';
import '../widgets/custom_header.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import '../models/chat_message.dart';
import '../services/auth_service.dart';

class ChatScreen extends StatefulWidget {
  final bool isActive;

  const ChatScreen({super.key, this.isActive = true});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _textController = TextEditingController();
  final List<ChatMessage> _messages = [];
  bool _showRecommendations = true;
  bool _isTyping = false;
  bool _isBotTyping = false;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _textController.addListener(_onTextChanged);
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted && widget.isActive) _animationController.forward();
    });
  }

  @override
  void didUpdateWidget(ChatScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !oldWidget.isActive) {
      if (_showRecommendations && _messages.isEmpty) {
        _animationController.reset();
        _animationController.forward();
      }
    }
  }

  void _onTextChanged() {
    setState(() {
      _isTyping = _textController.text.isNotEmpty;
    });
  }

  @override
  void dispose() {
    _textController.removeListener(_onTextChanged);
    _animationController.dispose();
    _textController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmitted(String text) async {
    if (text.isEmpty) return;
    _textController.clear();
    setState(() {
      _messages.insert(0, ChatMessage(text: text, isUser: true));
      _showRecommendations = false;
      _isBotTyping = true;
    });

    try {
      final authService = context.read<AuthService>();
      final backendUrl = authService.backendUrl;

      final response = await http.post(
        Uri.parse('$backendUrl/api/chat'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'userMessage': text}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final botReply = data['reply'] ?? '응답을 받지 못했습니다.';

        if (mounted) {
          setState(() {
            _messages.insert(0, ChatMessage(text: botReply, isUser: false));
          });
        }
      } else {
        throw Exception('Failed to load response: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Chat API Error: $e');
      if (mounted) {
        setState(() {
          _messages.insert(
            0,
            ChatMessage(text: '앗, 오류가 발생했어요. 잠시 후 다시 시도해주세요.', isUser: false),
          );
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isBotTyping = false;
        });
      }
    }
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
    final double start = (index * 0.4).clamp(0.0, 1.0);
    final double end = (start + 0.6).clamp(0.0, 1.0);

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
    return ElevatedButton(
      onPressed: () => _handleSubmitted(text),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFEF5350),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 0,
        alignment: Alignment.centerLeft,
      ),
      child: Text(
        text,
        style: GoogleFonts.notoSans(fontSize: 16, fontWeight: FontWeight.bold),
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
      itemCount: _messages.length + (_isBotTyping ? 1 : 0),
      itemBuilder: (context, index) {
        if (_isBotTyping && index == 0) {
          return Align(
            alignment: Alignment.centerLeft,
            child: Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                  bottomLeft: Radius.circular(4),
                  bottomRight: Radius.circular(16),
                ),
              ),
              child: const SizedBox(
                width: 40,
                height: 20,
                child: Center(
                  child: LinearProgressIndicator(
                    backgroundColor: Colors.transparent,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.grey),
                  ),
                ),
              ),
            ),
          );
        }

        final messageIndex = _isBotTyping ? index - 1 : index;
        final message = _messages[messageIndex];
        final isUser = message.isUser;

        return Align(
          alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            margin: const EdgeInsets.only(bottom: 8),
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.75,
            ),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isUser ? const Color(0xFFFA7B7B) : Colors.grey[200],
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(16),
                topRight: const Radius.circular(16),
                bottomLeft: Radius.circular(isUser ? 16 : 4),
                bottomRight: Radius.circular(isUser ? 4 : 16),
              ),
            ),
            child: isUser
                ? Text(
                    message.text,
                    style: GoogleFonts.notoSans(
                      color: Colors.white,
                      height: 1.4,
                    ),
                  )
                : _buildBotMessageWithDisclaimer(message.text),
          ),
        );
      },
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: const Color(0xFFFDE8E8),
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
          if (!_isTyping)
            IconButton(
              icon: const Icon(Icons.mic, color: Colors.black),
              onPressed: () {},
            ),
          if (_isTyping)
            GestureDetector(
              onTap: () => _handleSubmitted(_textController.text),
              child: Container(
                margin: const EdgeInsets.only(left: 8),
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: Colors.black,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.arrow_upward,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            )
          else
            IconButton(
              icon: const Icon(Icons.send, color: Colors.black),
              onPressed: () => _handleSubmitted(_textController.text),
            ),
        ],
      ),
    );
  }

  Widget _buildBotMessageWithDisclaimer(String text) {
    const disclaimer = '이 정보는 참고용이며, 정확한 진단은 전문의와 상담해야 합니다.';
    if (text.contains(disclaimer)) {
      final parts = text.split(disclaimer);
      final mainText = parts[0].trimRight();

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (mainText.isNotEmpty)
            Text(
              mainText,
              style: GoogleFonts.notoSans(color: Colors.black87, height: 1.4),
            ),
          if (mainText.isNotEmpty) const SizedBox(height: 8),
          Text(
            disclaimer,
            style: GoogleFonts.notoSans(color: Colors.grey[500], fontSize: 12),
          ),
        ],
      );
    }

    return Text(
      text,
      style: GoogleFonts.notoSans(color: Colors.black87, height: 1.4),
    );
  }
}
