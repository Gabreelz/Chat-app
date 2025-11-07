// lib/src/models/messageModel.dart
class MessageModel {
  final String id;
  final String conversationId;
  final String authorId;
  final String? text;
  final String? fileUrl;
  final DateTime createdAt;

  MessageModel({
    required this.id,
    required this.conversationId,
    required this.authorId,
    this.text,
    this.fileUrl,
    required this.createdAt,
  });

  factory MessageModel.fromMap(Map<String, dynamic> m) {
    return MessageModel(
      id: m['id'],
      conversationId: m['conversation_id'],
      authorId: m['author_id'],
      text: m['text'],
      fileUrl: m['file_url'],
      createdAt: DateTime.parse(m['created_at']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'conversation_id': conversationId,
      'author_id': authorId,
      'text': text,
      'file_url': fileUrl,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
