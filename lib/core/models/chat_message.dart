/// مدل پیام چت - Chat message model
class ChatMessage {
  final String id;
  final String content;
  final ChatMessageType type;
  final DateTime timestamp;
  final bool isLoading;

  ChatMessage({
    required this.id,
    required this.content,
    required this.type,
    required this.timestamp,
    this.isLoading = false,
  });

  /// ایجاد پیام کاربر - Create user message
  factory ChatMessage.user(String content) {
    return ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: content,
      type: ChatMessageType.user,
      timestamp: DateTime.now(),
    );
  }

  /// ایجاد پیام ربات - Create bot message
  factory ChatMessage.bot(String content) {
    return ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: content,
      type: ChatMessageType.bot,
      timestamp: DateTime.now(),
    );
  }

  /// ایجاد پیام در حال بارگذاری - Create loading message
  factory ChatMessage.loading() {
    return ChatMessage(
      id: 'loading_${DateTime.now().millisecondsSinceEpoch}',
      content: 'در حال پردازش...',
      type: ChatMessageType.bot,
      timestamp: DateTime.now(),
      isLoading: true,
    );
  }

  /// ایجاد کپی با تغییرات - Create copy with changes
  ChatMessage copyWith({
    String? id,
    String? content,
    ChatMessageType? type,
    DateTime? timestamp,
    bool? isLoading,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      content: content ?? this.content,
      type: type ?? this.type,
      timestamp: timestamp ?? this.timestamp,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

/// نوع پیام چت - Chat message type
enum ChatMessageType {
  user,
  bot,
}
