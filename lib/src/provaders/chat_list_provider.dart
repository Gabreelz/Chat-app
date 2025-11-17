import 'package:flutter/foundation.dart';
import 'package:chat_app/src/models/conversation_list_item.dart';
import 'package:chat_app/src/services/chat_list_service.dart';

class ChatListProvider extends ChangeNotifier {
  final ChatListService _chatListService = ChatListService();

  List<ConversationListItemModel> _conversations = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<ConversationListItemModel> get conversations => _conversations;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadConversations() async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      _conversations = await _chatListService.getConversations();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Erro ao carregar conversas: $e';
      _isLoading = false;
      notifyListeners();
      if (kDebugMode) {
        print(_errorMessage);
      }
    }
  }
}