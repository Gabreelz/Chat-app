import 'package:chat_app/src/models/UserModel.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Busca o perfil de um usuário específico
  Future<UserModel> getUserProfile(String userId) async {
    try {
      final response =
          await _supabase.from('users').select().eq('id', userId).single();
      return UserModel.fromMap(response as Map<String, dynamic>);
    } catch (e) {
      print('Erro ao buscar perfil: $e');
      rethrow;
    }
  }

  /// Busca todos os usuários, exceto o logado
  Future<List<UserModel>> getAllUsers() async {
    final currentUserId = _supabase.auth.currentUser?.id;
    if (currentUserId == null) {
      return [];
    }
    try {
      final response = await _supabase
          .from('users')
          .select()
          .neq('id', currentUserId); // Exclui o usuário logado

      final users = (response as List)
          .map((u) => UserModel.fromMap(u as Map<String, dynamic>))
          .toList();

      return users;
    } catch (e) {
      print('Erro ao buscar usuários: $e');
      return [];
    }
  }

  /// Atualiza o perfil do usuário
  Future<void> updateProfile({
    required String userId,
    required String name,
    String? avatarUrl,
  }) async {
    try {
      await _supabase.from('users').update({
        'name': name,
        'avatar_url': avatarUrl,
      }).eq('id', userId);
    } catch (e) {
      print('Erro ao atualizar perfil: $e');
      rethrow;
    }
  }
}