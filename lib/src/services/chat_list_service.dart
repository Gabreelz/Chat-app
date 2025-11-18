import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:chat_app/src/models/conversation_list_item.dart';

class ChatListService {
  final SupabaseClient supabase = Supabase.instance.client;

  Future<List<ConversationListItemModel>> getConversations() async {
    try {
      final userId = supabase.auth.currentUser?.id ?? '';

      if (userId.isEmpty) {
        return [];
      }

      final response = await supabase
          .rpc('get_conversations_for_user', params: {'current_user_id_input': userId});

      return (response as List)
          .map((json) => ConversationListItemModel.fromMap(json))
          .toList();
    } catch (e) {
      print(e);
      return [];
    }
  }
}
