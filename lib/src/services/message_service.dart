import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:chat_app/src/models/messageModel.dart';

class MessageService {
  final SupabaseClient supabase = Supabase.instance.client;

  // Enviar mensagem de texto
  Future<MessageModel?> sendTextMessage(
    String conversationId,
    String authorId,
    String text,
  ) async {
    try {
      final response = await supabase.from('messages').insert({
        'conversation_id': conversationId,
        'author_id': authorId,
        'text': text,
        'file_url': null,
        'is_read': false,
      }).select().single();

      return MessageModel.fromJson(Map<String, dynamic>.from(response));
    } catch (e) {
      print('Erro ao enviar mensagem: $e');
      return null;
    }
  }

  // Enviar mensagem com arquivo/imagem
  Future<MessageModel?> sendFileMessage(
    String conversationId,
    String authorId,
    String fileUrl,
  ) async {
    try {
      final response = await supabase.from('messages').insert({
        'conversation_id': conversationId,
        'author_id': authorId,
        'text': null,
        'file_url': fileUrl,
        'is_read': false,
      }).select().single();

      return MessageModel.fromJson(Map<String, dynamic>.from(response));
    } catch (e) {
      print('Erro ao enviar arquivo: $e');
      return null;
    }
  }

  // Carregar mensagens da conversa
  Future<List<MessageModel>> loadMessages(String conversationId) async {
    try {
      final response = await supabase
          .from('messages')
          .select()
          .eq('conversation_id', conversationId)
          .isFilter('deleted_at', null)
          .order('created_at', ascending: true);

      final list = (response as List).cast<Map<String, dynamic>>();
      return list.map((m) => MessageModel.fromJson(m)).toList();
    } catch (e) {
      print('Erro ao carregar mensagens: $e');
      return [];
    }
  }

  // Marcar mensagem como lida
  Future<bool> markAsRead(String messageId) async {
    try {
      await supabase.from('messages').update({'is_read': true}).eq('id', messageId);
      return true;
    } catch (e) {
      print('Erro ao marcar como lida: $e');
      return false;
    }
  }

  // Editar mensagem se <= 15 minutos
  Future<MessageModel?> editMessage(String messageId, String newText) async {
    try {
      final message = await supabase.from('messages').select().eq('id', messageId).single();
      final createdAt = DateTime.parse(message['created_at']);
      final diffMinutes = DateTime.now().difference(createdAt).inMinutes;

      if (diffMinutes > 15) {
        throw Exception('Mensagem não pode ser editada após 15 minutos');
      }

      final response = await supabase
          .from('messages')
          .update({
            'text': newText,
            'edited_at': DateTime.now().toIso8601String(),
          })
          .eq('id', messageId)
          .select()
          .single();

      return MessageModel.fromJson(Map<String, dynamic>.from(response));
    } catch (e) {
      print('Erro ao editar mensagem: $e');
      return null;
    }
  }

  // Soft delete: marcar deleted_at
  Future<bool> deleteMessage(String messageId) async {
    try {
      final message = await supabase.from('messages').select().eq('id', messageId).single();
      final createdAt = DateTime.parse(message['created_at']);
      final diffMinutes = DateTime.now().difference(createdAt).inMinutes;

      if (diffMinutes > 15) {
        throw Exception('Mensagem não pode ser apagada após 15 minutos');
      }

      await supabase.from('messages').update({
        'deleted_at': DateTime.now().toIso8601String(),
      }).eq('id', messageId);

      return true;
    } catch (e) {
      print('Erro ao apagar mensagem: $e');
      return false;
    }
  }

  // Marcar todas as mensagens como lidas
  Future<bool> markAllAsRead(String conversationId, String userId) async {
    try {
      await supabase
          .from('messages')
          .update({'is_read': true})
          .eq('conversation_id', conversationId)
          .neq('author_id', userId)
          .isFilter('deleted_at', null);

      return true;
    } catch (e) {
      print('Erro ao marcar todas como lidas: $e');
      return false;
    }
  }
}
