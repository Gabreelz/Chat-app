import 'package:flutter/foundation.dart';
import 'package:chat_app/src/models/ConversationModel.dart';
import 'package:chat_app/src/services/chat_list_service.dart';

class ChatListProvider extends ChangeNotifier {
  final ChatListService _chatListService = ChatListService();

  List<ConversationModel> _conversations = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<ConversationModel> get conversations => _conversations;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadConversations() async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final list = await _chatListService.loadConversations();
      _conversations = List<ConversationModel>.from(list);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Erro ao carregar conversas: $e';
      if (kDebugMode) print(_errorMessage);
      notifyListeners();
    }
  }

  Future<bool> deleteConversation(String conversationId) async {
    try {
      final success = await _chatListService.deleteConversation(conversationId);
      if (success) {
        _conversations.removeWhere((c) => c.conversationId == conversationId);
        notifyListeners();
      }
      return success;
    } catch (e) {
      _errorMessage = 'Erro ao deletar conversa: $e';
      if (kDebugMode) print(_errorMessage);
      return false;
    }
  }

  Future<void> updateLastMessage(String conversationId) async {
    try {
      await _chatListService.updateLastMessageAt(conversationId);
      await loadConversations();
    } catch (e) {
      _errorMessage = 'Erro ao atualizar mensagem: $e';
      if (kDebugMode) print(_errorMessage);
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}