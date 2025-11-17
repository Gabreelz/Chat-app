// ...existing code...
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:chat_app/src/models/ConversationModel.dart';

class ChatListService {
  final SupabaseClient supabase = Supabase.instance.client;

  /// Carregar conversas do usuário atual, incluindo dados do outro usuário
  Future<List<ConversationModel>> loadConversations() async {
    try {
      final currentUserId = supabase.auth.currentUser?.id ?? '';
      if (currentUserId.isEmpty) return [];

      final response = await supabase
          .from('conversations')
          .select('''
            id,
            user_id1,
            user_id2,
            created_at,
            updated_at,
            last_message_at,
            last_message_text,
            last_message_author_id,
            user1:users(id,name,avatar_url),
            user2:users(id,name,avatar_url)
          ''')
          .or('user_id1.eq.$currentUserId,user_id2.eq.$currentUserId')
          .order('updated_at', ascending: false);

      if (response == null) return [];

      final list = (response as List).map((e) {
        final Map<String, dynamic> map = Map<String, dynamic>.from(e as Map);
        final user1 = map['user1'] as Map<String, dynamic>?;
        final user2 = map['user2'] as Map<String, dynamic>?;

        Map<String, dynamic>? other;
        if (user1 != null && user1['id']?.toString() == currentUserId) {
          other = user2;
        } else if (user2 != null && user2['id']?.toString() == currentUserId) {
          other = user1;
        } else if (map['user_id1']?.toString() == currentUserId) {
          other = user2;
        } else if (map['user_id2']?.toString() == currentUserId) {
          other = user1;
        }

        if (other != null) {
          map['other_user_id'] = other['id'];
          map['other_user_name'] = other['name'];
          map['other_user_avatar_url'] = other['avatar_url'];
        } else {
          map['other_user_id'] = null;
          map['other_user_name'] = null;
          map['other_user_avatar_url'] = null;
        }

        return map;
      }).toList();

      return list.map((conv) => ConversationModel.fromJson(conv)).toList();
    } catch (e) {
      if (kDebugMode) print('Erro ao carregar conversas: $e');
      return [];
    }
  }

  Future<ConversationModel?> getConversation(String conversationId) async {
    try {
      final response = await supabase.from('conversations').select().eq('id', conversationId).maybeSingle();
      if (response == null) return null;
      return ConversationModel.fromJson(Map<String, dynamic>.from(response));
    } catch (e) {
      if (kDebugMode) print('Erro ao obter conversa: $e');
      return null;
    }
  }

  Future<bool> deleteConversation(String conversationId) async {
    try {
      await supabase.from('conversations').delete().eq('id', conversationId);
      return true;
    } catch (e) {
      if (kDebugMode) print('Erro ao deletar conversa: $e');
      return false;
    }
  }

  Future<void> updateLastMessageAt(String conversationId) async {
    try {
      await supabase.from('conversations').update({'updated_at': DateTime.now().toIso8601String()}).eq('id', conversationId);
    } catch (e) {
      if (kDebugMode) print('Erro ao atualizar última mensagem: $e');
    }
  }
}