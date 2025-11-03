import 'supabase_client.dart';

class AuthService {
  final _client = SupabaseClientService.client;

  Future<bool> signUp(String email, String password) async {
    final res = await _client.auth.signUp(email: email, password: password);
    return res.user != null;
  }

  Future<bool> signIn(String email, String password) async {
    final res = await _client.auth.signInWithPassword(email: email, password: password);
    return res.user != null;
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  String? getCurrentUserId() {
    return _client.auth.currentUser?.id;
  }
}

