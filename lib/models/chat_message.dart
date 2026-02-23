class ChatMessage {
  final String text;
  final bool isUser;
  bool isAnimating;

  ChatMessage({
    required this.text,
    required this.isUser,
    this.isAnimating = true,
  });
}
