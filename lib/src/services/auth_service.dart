

import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final SupabaseClient _client = Supabase.instance.client;

  Future<bool> signUp({
    required String fullName,
    required String email,
    required String password,
  }) async {
    
    final response = await _client.auth.signUp(
      email: email,
      password: password,
      data: {'full_name': fullName},
    );

    if (response.user == null) {
      return false;
    }

    try {
      await _client.from('users').insert({
        'id': response.user!.id,
        'name': fullName,
        'email': email, 
      });
      return true;

    } catch (e) {
      print('Erro ao inserir perfil em public.users: $e');
      return false;
    }
  }

  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    final response = await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );

    return response.user != null;
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  String? getCurrentUserId() {
    return _client.auth.currentUser?.id;
  }

  User? get currentUser => _client.auth.currentUser;
}