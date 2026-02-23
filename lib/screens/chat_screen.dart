import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/chat_history_drawer.dart';
import '../widgets/custom_header.dart';
import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import '../models/chat_message.dart';
import '../services/auth_service.dart';

class ChatScreen extends StatefulWidget {
  final bool isActive;
  final ValueChanged<bool>? onFocusChange;

  const ChatScreen({super.key, this.isActive = true, this.onFocusChange});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
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
    _focusNode.addListener(_onFocusChanged);
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted && widget.isActive) _animationController.forward();
    });
  }

  void _onFocusChanged() {
    setState(() {});
    widget.onFocusChange?.call(_focusNode.hasFocus);
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
    _focusNode.removeListener(_onFocusChanged);
    _focusNode.dispose();
    _textController.removeListener(_onTextChanged);
    _animationController.dispose();
    _textController.dispose();
    super.dispose();
  }

  void _startNewChat() {
    setState(() {
      _messages.clear();
      _showRecommendations = true;
      _textController.clear();
      _isTyping = false;
      _isBotTyping = false;
    });
    _animationController.reset();
    if (widget.isActive) {
      _animationController.forward();
    }
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
            _messages.insert(
              0,
              ChatMessage(text: botReply, isUser: false, isAnimating: true),
            );
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
            ChatMessage(
              text: '앗, 오류가 발생했어요. 잠시 후 다시 시도해주세요.',
              isUser: false,
              isAnimating: true,
            ),
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
      drawer: ChatHistoryDrawer(onNewChat: _startNewChat),
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
          _buildAnimatedButton('최근 가슴이 답답한데 어떻게 해야 하나요?', 0),
          const SizedBox(height: 12),
          _buildAnimatedButton('협심증의 주요 증상이 궁금해요.', 1),
          const SizedBox(height: 12),
          _buildAnimatedButton('심장 건강에 좋은 운동 추천해주세요.', 2),
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
                : _buildBotMessageWithDisclaimer(message),
          ),
        );
      },
    );
  }

  Widget _buildInputArea() {
    final isFocused = _focusNode.hasFocus;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      decoration: BoxDecoration(
        color: isFocused ? const Color(0xFFFBA9A9) : const Color(0xFFFDE8E8),
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
            child: Container(
              constraints: const BoxConstraints(maxHeight: 120),
              child: Scrollbar(
                child: TextField(
                  controller: _textController,
                  focusNode: _focusNode,
                  onTap: _hideRecommendations,
                  style: GoogleFonts.notoSans(color: Colors.black),
                  cursorColor: Colors.white,
                  minLines: 1,
                  maxLines: 5,
                  keyboardType: TextInputType.multiline,
                  textInputAction: TextInputAction.newline,
                  decoration: InputDecoration(
                    hintText: isFocused ? '' : '메시지를 입력하세요..',
                    hintStyle: GoogleFonts.notoSans(
                      color: isFocused ? Colors.transparent : Colors.grey[600],
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 8,
                    ),
                  ),
                  onSubmitted: _handleSubmitted,
                ),
              ),
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
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.arrow_upward,
                  color: Colors.black,
                  size: 20,
                ),
              ),
            )
          else
            GestureDetector(
              onTap: () => _handleSubmitted(_textController.text),
              child: Container(
                margin: const EdgeInsets.only(left: 8),
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.arrow_upward,
                  color: Colors.black,
                  size: 20,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBotMessageWithDisclaimer(ChatMessage message) {
    const disclaimer = '이 정보는 참고용이며, 정확한 진단은 전문의와 상담해야 합니다.';
    final text = message.text;

    if (message.isAnimating) {
      return TypewriterText(
        text: text,
        disclaimer: text.contains(disclaimer) ? disclaimer : null,
        onComplete: () {
          message.isAnimating = false;
        },
      );
    }

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

class TypewriterText extends StatefulWidget {
  final String text;
  final String? disclaimer;
  final VoidCallback onComplete;

  const TypewriterText({
    super.key,
    required this.text,
    this.disclaimer,
    required this.onComplete,
  });

  @override
  State<TypewriterText> createState() => _TypewriterTextState();
}

class _TypewriterTextState extends State<TypewriterText> {
  String _displayedText = '';
  Timer? _timer;
  int _currentIndex = 0;
  bool _showDisclaimer = false;
  late String _mainText;

  @override
  void initState() {
    super.initState();
    if (widget.disclaimer != null && widget.text.contains(widget.disclaimer!)) {
      _mainText = widget.text.split(widget.disclaimer!)[0].trimRight();
    } else {
      _mainText = widget.text;
    }
    _startTyping();
  }

  void _startTyping() {
    _timer = Timer.periodic(const Duration(milliseconds: 30), (timer) {
      if (_currentIndex < _mainText.length) {
        setState(() {
          _currentIndex++;
          _displayedText = _mainText.substring(0, _currentIndex);
        });
      } else {
        _timer?.cancel();
        if (widget.disclaimer != null) {
          setState(() {
            _showDisclaimer = true;
          });
        }
        widget.onComplete();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (_displayedText.isNotEmpty)
          Text(
            _displayedText,
            style: GoogleFonts.notoSans(color: Colors.black87, height: 1.4),
          ),
        if (_showDisclaimer) ...[
          const SizedBox(height: 8),
          Text(
            widget.disclaimer!,
            style: GoogleFonts.notoSans(color: Colors.grey[500], fontSize: 12),
          ),
        ],
      ],
    );
  }
}
