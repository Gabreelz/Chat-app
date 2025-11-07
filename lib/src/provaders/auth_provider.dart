// controla o usuário logado.// lib/src/provaders/auth_provider.dart
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:chat_app/src/models/UserModel.dart';

class AuthProvider extends ChangeNotifier {
  final _supabase = Supabase.instance.client;
  UserModel? currentUser;

  Future<AuthResponse> signUp(
    String email,
    String password,
    String name,
  ) async {
    // Cria o usuário com email e senha
    final res = await _supabase.auth.signUp(
      email: email,
      password: password,
      data: {
        'name': name, // dados extras do perfil
      },
    );

    // Cria linha na tabela 'users' (caso use uma tabela separada)
    if (res.user != null) {
      final userId = res.user!.id;
      await _supabase.from('users').insert({
        'id': userId,
        'email': email,
        'name': name,
      });
    }

    return res;
  }
}
