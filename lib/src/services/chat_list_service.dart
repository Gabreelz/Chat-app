import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:chat_app/src/models/conversation_list_item.dart'; 

class ChatListService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<List<ConversationListItemModel>> getConversations() async {
    try {
      final currentUserId = _supabase.auth.currentUser?.id;
      if (currentUserId == null) {
        throw Exception("Usuário não está logado.");
      }

      // Chama a função RPC
      final response = await _supabase
          .rpc('get_conversations_for_user', params: {
        'current_user_id_input': currentUserId,
      });

      if (response is List) {
        final conversations = response
            .map((item) => ConversationListItemModel.fromMap(
                Map<String, dynamic>.from(item)))
            .toList();
        return conversations;
      }

      return [];
    } catch (e) {
      print('Erro em ChatListService.getConversations: $e');
      rethrow;
    }
  }
}