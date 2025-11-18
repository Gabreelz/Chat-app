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
      data: {'full_name': fullName}, // O SQL trigger vai usar isto
    );

    // O insert manual foi REMOVIDO daqui.
    // O SQL trigger 'handle_new_user' que você criou no "Passo 1"
    // vai fazer a inserção na tabela 'public.users' automaticamente.

    return response.user != null;
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