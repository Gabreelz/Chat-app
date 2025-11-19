// lib/src/models/messageModel.dart

class MessageModel {
  final String id;
  final String conversationId;
  final String authorId;
  final String? text;
  final String? fileUrl;
  final DateTime createdAt;
  final bool isRead;
  final DateTime? editedAt;
  final DateTime? deletedAt;

  MessageModel({
    required this.id,
    required this.conversationId,
    required this.authorId,
    this.text,
    this.fileUrl,
    required this.createdAt,
    this.isRead = false,
    this.editedAt,
    this.deletedAt,
  });

  factory MessageModel.fromMap(Map<String, dynamic> m) {
    return MessageModel(
      id: m['id'] as String? ?? '',
      conversationId: m['conversation_id'] as String? ?? '',
      authorId: m['author_id'] as String? ?? '',
      text: m['text'],
      fileUrl: m['file_url'],
      createdAt: m['created_at'] != null
          ? DateTime.parse(m['created_at'])
          : DateTime.now(),
      isRead: m['is_read'] as bool? ?? false,
      editedAt: m['edited_at'] != null ? DateTime.parse(m['edited_at']) : null,
      deletedAt: m['deleted_at'] != null ? DateTime.parse(m['deleted_at']) : null,
    );
  }

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel.fromMap(json);
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'conversation_id': conversationId,
      'author_id': authorId,
      'text': text,
      'file_url': fileUrl,
      'created_at': createdAt.toIso8601String(),
      'is_read': isRead,
      'edited_at': editedAt?.toIso8601String(),
      'deleted_at': deletedAt?.toIso8601String(),
    };
  }

  Map<String, dynamic> toJson() => toMap();

  // Pode editar até 15 minutos e se não foi deletada
  bool canBeEdited() {
    final diffMinutes = DateTime.now().difference(createdAt).inMinutes;
    return diffMinutes <= 15 && deletedAt == null;
  }

  // Pode apagar até 15 minutos e se não foi deletada
  bool canBeDeleted() {
    final diffMinutes = DateTime.now().difference(createdAt).inMinutes;
    return diffMinutes <= 15 && deletedAt == null;
  }

  // Foi editada?
  bool get wasEdited => editedAt != null;

  // Foi apagada? (CORRIGIDO)
  bool get wasDeleted => deletedAt != null;

  // CopyWith
  MessageModel copyWith({
    String? id,
    String? conversationId,
    String? authorId,
    String? text,
    String? fileUrl,
    DateTime? createdAt,
    bool? isRead,
    DateTime? editedAt,
    DateTime? deletedAt,
  }) {
    return MessageModel(
      id: id ?? this.id,
      conversationId: conversationId ?? this.conversationId,
      authorId: authorId ?? this.authorId,
      text: text ?? this.text,
      fileUrl: fileUrl ?? this.fileUrl,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
      editedAt: editedAt ?? this.editedAt,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }
}
