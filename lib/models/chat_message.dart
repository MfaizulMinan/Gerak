class ChatMessage {
  final String id;
  final String role; // 'user' atau 'assistant'
  final String content;
  final DateTime timestamp;

  ChatMessage({
    required this.id,
    required this.role,
    required this.content,
    required this.timestamp,
  });

  bool get isUser => role == 'user';

  factory ChatMessage.fromMap(Map<String, dynamic> data, String docId) {
    return ChatMessage(
      id: docId,
      role: data['role'] ?? 'user',
      content: data['content'] ?? '',
      timestamp: data['timestamp'] != null
          ? (data['timestamp'] as dynamic).toDate()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'role': role,
      'content': content,
      'timestamp': timestamp,
    };
  }
}
