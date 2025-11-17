// ...existing code...
import 'package:flutter/foundation.dart';

class ConversationModel {
  final String id;
  final String? userId1;
  final String? userId2;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? lastMessageAt;
  final String? lastMessageText;
  final String? lastMessageAuthorId;

  // Campos derivados / preenchidos pela query (outro usuário)
  final String? otherUserId;
  final String? otherUserName;
  final String? otherUserAvatarUrl;

  ConversationModel({
    required this.id,
    this.userId1,
    this.userId2,
    this.createdAt,
    this.updatedAt,
    this.lastMessageAt,
    this.lastMessageText,
    this.lastMessageAuthorId,
    this.otherUserId,
    this.otherUserName,
    this.otherUserAvatarUrl,
  });

  factory ConversationModel.fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(dynamic v) {
      if (v == null) return null;
      try {
        return DateTime.parse(v.toString());
      } catch (_) {
        return null;
      }
    }

    // Support nested user objects returned by Supabase (user1, user2)
    String? getNested(Map<String, dynamic> m, String key) {
      if (m.containsKey(key) && m[key] != null) return m[key].toString();
      return null;
    }

    // If the response included user1/user2 objects, map them to other_user_* later
    return ConversationModel(
      id: json['id']?.toString() ?? '',
      userId1: json['user_id1']?.toString(),
      userId2: json['user_id2']?.toString(),
      createdAt: parseDate(json['created_at'] ?? json['createdAt']),
      updatedAt: parseDate(json['updated_at'] ?? json['updatedAt']),
      lastMessageAt: parseDate(json['last_message_at'] ?? json['lastMessageAt']),
      lastMessageText: json['last_message_text']?.toString() ?? json['lastMessageText']?.toString(),
      lastMessageAuthorId: json['last_message_author_id']?.toString() ?? json['lastMessageAuthorId']?.toString(),
      otherUserId: json['other_user_id']?.toString() ?? json['otherUserId']?.toString(),
      otherUserName: json['other_user_name']?.toString() ?? json['otherUserName']?.toString(),
      otherUserAvatarUrl: json['other_user_avatar_url']?.toString() ?? json['otherUserAvatarUrl']?.toString(),
    );
  }

  // Compatibility getters used by UI
  String get conversationId => id;
  DateTime? get lastMessageTimestamp => lastMessageAt ?? updatedAt ?? createdAt;

  // Nullable fields — UI uses ?? so keep them nullable
  String? get lastMessageTextSafe => lastMessageText;
  String? get lastMessageAuthorIdSafe => lastMessageAuthorId;

  String? get otherUserIdSafe => otherUserId;
  String? get otherUserNameSafe => otherUserName;
  String? get otherUserAvatarUrlSafe => otherUserAvatarUrl;
}