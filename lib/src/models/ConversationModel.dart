// lista de participantes, últimas mensagens, etc.

import 'UserModel.dart';
import 'messageModel.dart';

class ConversationModel {
    final String id;
    final String title;
    final DateTime createAt;
    final List<String> participanteId;
    final List<UserModel>? participantes;
    final List<MessageModel>? message;

  ConversationModel({
    required this.id,
    required this.title,
    required this.createAt,
    required this.participanteId,
    this.participantes,
    this.message,
  });   

  factory ConversationModel.fromMap(Map<String, dynamic> map) {
    return ConversationModel(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      createAt: DateTime.parse(map['created_at']),
      participanteId: List<String>.from(map['participant_ids'] ?? []),
      participantes: map['participantes'] != null
          ? List<UserModel>.from(
              map['participantes'].map((u) => UserModel.fromMap(u)))
          : null,
      message: map['message'] != null
          ? List<MessageModel>.from(
              map['message'].map((m) => MessageModel.fromMap(m)))
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'created_at': createAt.toIso8601String(),
      'participant_ids': participanteId,
      'participants': participantes?.map((u) => u.toMap()).toList(),
      'messages': message?.map((m) => m.toMap()).toList(),
    };
  }

  @override
  String toString() {
    return 'ConversationModel(id: $id, title: $title, createdAt: $createAt, participantIds: $participanteId, participants: $participantes, messages: $message)';
  }
}