import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:chat_app/src/models/ConversationModel.dart';

class ChatListService {
  final SupabaseClient supabase = Supabase.instance.client;

  /// Carregar conversas do usuário atual
  Future<List<ConversationModel>> loadConversations() async {
    try {
      final currentUserId = supabase.auth.currentUser?.id ?? '';
      
      if (currentUserId.isEmpty) {
        throw Exception('Usuário não autenticado');
      }

      // Query direta em vez de usar função RPC
      final response = await supabase
          .from('conversations')
          .select('''
            id,
            user_id1,
            user_id2,
            created_at,
            updated_at,
            last_message_at
          ''')
          .or('user_id1.eq.$currentUserId,user_id2.eq.$currentUserId')
          .order('updated_at', ascending: false);

      final conversations = (response as List)
          .map((conv) => ConversationModel.fromMap(conv))
          .toList();

      return conversations;
    } catch (e) {
      print('Erro ao carregar conversas: $e');
      return [];
    }
  }

  /// Obter detalhes de uma conversa
  Future<ConversationModel?> getConversation(String conversationId) async {
    try {
      final response = await supabase
          .from('conversations')
          .select()
          .eq('id', conversationId)
          .maybeSingle();

      if (response == null) return null;
      return ConversationModel.fromMap(response);
    } catch (e) {
      print('Erro ao obter conversa: $e');
      return null;
    }
  }

  /// Deletar conversa
  Future<bool> deleteConversation(String conversationId) async {
    try {
      await supabase
          .from('conversations')
          .delete()
          .eq('id', conversationId);

      return true;
    } catch (e) {
      print('Erro ao deletar conversa: $e');
      return false;
    }
  }

  /// Atualizar timestamp da última mensagem
  Future<void> updateLastMessageAt(String conversationId) async {
    try {
      await supabase
          .from('conversations')
          .update({'updated_at': DateTime.now().toIso8601String()})
          .eq('id', conversationId);
    } catch (e) {
      print('Erro ao atualizar última mensagem: $e');
    }
  }
}