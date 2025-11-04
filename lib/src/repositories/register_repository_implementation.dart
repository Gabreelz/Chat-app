import 'package:chat_app/src/repositories/register_repository.dart';
import 'package:chat_app/src/services/auth_service.dart';

/// Implementação do repositório de registro de usuários
class RegisterRepositoryImplementation implements RegisterRepository {
  /// Construtor da classe [RegisterRepositoryImplementation]
  RegisterRepositoryImplementation({required this.registerService});

  /// Serviço de registro de usuários
  final AuthService registerService;

  @override
  Future<void> sendRegister(
    String fullName,
    String email,
    String password,
  ) async {
    await registerService.signUp(
        fullName: fullName, email: email, password: password);
  }
}
