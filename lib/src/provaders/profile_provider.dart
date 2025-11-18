// lib/src/provaders/profile_provider.dart

import 'dart:io';
import 'package:chat_app/src/models/UserModel.dart';
import 'package:chat_app/src/services/profile_service.dart';
import 'package:chat_app/src/services/storage_service.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileProvider extends ChangeNotifier {
  final _profileService = ProfileService();
  final _storageService = StorageService();
  final _supabase = Supabase.instance.client;

  UserModel? _user;
  UserModel? get user => _user;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  File? _pickedImage;
  File? get pickedImage => _pickedImage;

  Future<void> loadUserProfile() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw Exception("Usuário não encontrado");
      
      _user = await _profileService.getUserProfile(userId);

    } catch (e) {
      _errorMessage = "Erro ao carregar perfil: $e";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> pickImage() async {
    try {
      final picker = ImagePicker();
      final XFile? file = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        imageQuality: 80,
      );
      if (file != null) {
        _pickedImage = File(file.path);
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = "Erro ao selecionar imagem: $e";
      notifyListeners();
    }
  }

  Future<bool> saveProfile(String name) async {
    if (_user == null) return false;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      String? avatarUrl = _user!.avatarUrl; // Mantém a URL antiga por padrão

      // 1. Se uma nova imagem foi escolhida, faça o upload
      if (_pickedImage != null) {
        // AQUI ESTÁ A CORREÇÃO:
        // O método chama-se "uploadAvatar", não "uploadFile"
        avatarUrl = await _storageService.uploadAvatar(_pickedImage!, _user!.id);
      }

      // 2. Atualize os dados do usuário no banco
      await _profileService.updateProfile(
        userId: _user!.id,
        name: name,
        avatarUrl: avatarUrl,
      );

      // 3. Atualize o estado local
      _user = _user!.copyWith(name: name, avatarUrl: avatarUrl);
      _pickedImage = null; // Limpa a imagem escolhida

      _isLoading = false;
      notifyListeners();
      return true;

    } catch (e) {
      _errorMessage = "Erro ao salvar perfil: $e";
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}