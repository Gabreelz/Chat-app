class ConversationListItemModel {
  final String conversationId;
  final String otherUserId;
  final String otherUserName;
  final String? otherUserAvatarUrl;
  final String? lastMessageText;
  final DateTime? lastMessageTimestamp;
  final String? lastMessageAuthorId;
  final bool isLastMessageRead;

  ConversationListItemModel({
    required this.conversationId,
    required this.otherUserId,
    required this.otherUserName,
    this.otherUserAvatarUrl,
    this.lastMessageText,
    this.lastMessageTimestamp,
    this.lastMessageAuthorId,
    this.isLastMessageRead = false,
  });

  factory ConversationListItemModel.fromMap(Map<String, dynamic> json) {
    return ConversationListItemModel(
      conversationId: json['conversation_id'] as String? ?? '', // CORRIGIDO
      otherUserId: json['other_user_id'] as String? ?? '', // CORRIGIDO
      otherUserName: json['other_user_name'] as String? ?? 'Usuário', // CORRIGIDO
      otherUserAvatarUrl: json['other_user_avatar_url'],
      lastMessageText: json['last_message_text'],
      lastMessageTimestamp: json['last_message_timestamp'] != null
          ? DateTime.parse(json['last_message_timestamp'])
          : null,
      lastMessageAuthorId: json['last_message_author_id'],
      isLastMessageRead: json['is_last_message_read'] ?? false,
    );
  }
}