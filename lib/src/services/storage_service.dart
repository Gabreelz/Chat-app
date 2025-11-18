import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:path/path.dart' as p;

class StorageService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<String> uploadAvatar(File file, String userId) async {
    try {
      const bucket = 'avatars';
      final fileExt = p.extension(file.path);
      final fileName = '$userId$fileExt'; // Ex: 'uuid_do_usuario.png'
      final filePath = fileName;

      // Faz o upload, substituindo se já existir (upsert: true)
      await _supabase.storage.from(bucket).upload(
            filePath,
            file,
            fileOptions: const FileOptions(cacheControl: '3600', upsert: true),
          );

      // Limpa o cache para garantir que a nova imagem seja exibida
      await _supabase.storage.from(bucket).update(
            filePath,
            file,
            fileOptions: const FileOptions(cacheControl: '0', upsert: true),
          );

      // Obtém a URL pública
      final publicUrl = _supabase.storage
          .from(bucket)
          .getPublicUrl(filePath);

      return publicUrl;
    } catch (e) {
      print('Erro no upload de avatar: $e');
      rethrow;
    }
  }
}