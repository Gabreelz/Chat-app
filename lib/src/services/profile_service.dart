import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:chat_app/src/models/UserModel.dart';

class ProfileService {
  final SupabaseClient supabase = Supabase.instance.client;


  /// Listar todos os usuários (exceto o próprio usuário logado)
  Future<List<UserModel>> getAllUsers() async {
    try {
      final currentUserId = supabase.auth.currentUser?.id ?? '';
      
      final response = await supabase
          .from('users')
          .select()
          .neq('id', currentUserId)
          .order('name', ascending: true);

      final users = (response as List)
          .map((u) => UserModel.fromJson(u))
          .toList();
      
      return users;
    } catch (e) {
      print('Erro ao listar usuários: $e');
      return [];
    }
  }

}