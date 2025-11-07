import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:chat_app/src/models/messageModel.dart';

class ChatProvider extends ChangeNotifier {
  final _supabase = Supabase.instance.client;
  final List<MessageModel> messages = [];

  RealtimeChannel? _sub;
  StreamSubscription? _messagesStreamSub;

  /// Carrega as últimas mensagens da conversa
  Future<List<MessageModel>> loadMessages(String conversationId) async {
    final res = await _supabase
        .from('messages')
        .select()
        .eq('conversation_id', conversationId)
        .order('created_at', ascending: true);

    final data = res as List<dynamic>;
    messages
      ..clear()
      ..addAll(
        data.map((m) => MessageModel.fromMap(Map<String, dynamic>.from(m))),
      );

    notifyListeners();
    _subscribeToMessages(conversationId);
    return messages;
  }

  /// Envia mensagem de texto
  Future<void> sendText(
      String conversationId, String authorId, String text) async {
    await _supabase.from('messages').insert({
      'conversation_id': conversationId,
      'author_id': authorId,
      'text': text,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  /// Envia mensagem com arquivo (imagem, vídeo, etc.)
  Future<void> sendFile(
      String conversationId, String authorId, String fileUrl) async {
    await _supabase.from('messages').insert({
      'conversation_id': conversationId,
      'author_id': authorId,
      'file_url': fileUrl,
      'created_at': DateTime.now().toIso8601String(),
    });

    // Adiciona localmente (opcional, o realtime vai sincronizar depois)
    messages.add(MessageModel(
      id: '',
      conversationId: conversationId,
      authorId: authorId,
      text: null,
      fileUrl: fileUrl,
      createdAt: DateTime.now(),
    ));
    notifyListeners();
  }

  /// Cancela inscrição no canal realtime
  void disposeSubscription() {
    if (_sub != null) {
      _supabase.removeChannel(_sub!);
      _sub = null;
    }
    _messagesStreamSub?.cancel();
    _messagesStreamSub = null;
  }

  /// Inscreve-se em mensagens novas via Supabase Realtime
  void _subscribeToMessages(String conversationId) {
    _sub = _supabase.channel('public:messages');

    _sub!.onPostgresChanges(
      event: PostgresChangeEvent.insert,
      schema: 'public',
      table: 'messages',
      filter: PostgresChangeFilter(
        type: PostgresChangeFilterType.eq,
        column: 'conversation_id',
        value: conversationId,
      ),
      callback: (payload) {
        final newRecord = payload.newRecord;
        if (newRecord != null) {
          final msg =
              MessageModel.fromMap(Map<String, dynamic>.from(newRecord));
          messages.add(msg);
          notifyListeners();
        }
      },
    );

    _sub!.subscribe();
  }
}
