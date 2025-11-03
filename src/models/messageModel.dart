// texto, autor, timestamp.

class messageModel {
  final String id;
  final String userId;        
  final String chatId;        
  final String content;       
  final String? mediaUrl;     
  final DateTime createdAt;   

  messageModel({
    required this.id, 
    required this.userId, 
    required this.chatId, 
    required this.content, 
    this.mediaUrl, 
    required this.createdAt,
  });

  factory messageModel.fromMap(Map<String, dynamic> map) {
    return messageModel(
      id: map['id'] ?? '',
      userId: map['user_id'] ?? '',
      chatId: map['chat_id'] ?? '',
      content: map['content'] ?? '',
      mediaUrl: map['media_url'],
      createdAt: DateTime.parse(map['created_at']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'chat_id': chatId,
      'content': content,
      'media_url': mediaUrl,
      'created_at': createdAt.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'MessageModel(id: $id, userId: $userId, chatId: $chatId, content: $content, mediaUrl: $mediaUrl, createdAt: $createdAt)';
  }

}