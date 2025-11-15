import 'package:flutter/foundation.dart';
import 'package:chat_app/src/models/UserModel.dart';
import 'package:chat_app/src/services/profile_service.dart';

class NewChatProvider extends ChangeNotifier {
  final ProfileService _profileService = ProfileService();

  List<UserModel> allUsers = [];
  List<UserModel> filteredUsers = [];
  bool isLoading = false;
  String searchQuery = '';

  /// Carregar todos os usuários
  Future<void> loadAllUsers() async {
    try {
      isLoading = true;
      notifyListeners();

      allUsers = await _profileService.getAllUsers();
      filteredUsers = List.from(allUsers);

      isLoading = false;
      notifyListeners();
    } catch (e) {
      if (kDebugMode) print('NewChatProvider.loadAllUsers erro: $e');
      isLoading = false;
      notifyListeners();
    }
  }

  /// Filtrar usuários por nome
  void searchUsers(String query) {
    searchQuery = query;
    
    if (query.isEmpty) {
      filteredUsers = List.from(allUsers);
    } else {
      filteredUsers = allUsers
          .where((user) =>
              user.name.toLowerCase().contains(query.toLowerCase()) ||
              user.email.toLowerCase().contains(query.toLowerCase()))
          .toList();
    }

    notifyListeners();
  }

  /// Limpar busca
  void clearSearch() {
    searchQuery = '';
    filteredUsers = List.from(allUsers);
    notifyListeners();
  }
}