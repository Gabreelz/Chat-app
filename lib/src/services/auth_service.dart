import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final SupabaseClient _client = Supabase.instance.client;

  Future<bool> signUp(String email, String password) async {
    final response = await _client.auth.signUp(
      email: email,
      password: password,
    );

    // Retorna true se o usuário foi criado (mesmo que precise confirmar email)
    return response.user != null;
  }

  Future<bool> signIn(String email, String password) async {
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
}
