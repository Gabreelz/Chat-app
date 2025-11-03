
import 'src/models/UserModel.dart';

void main() {
  // Simulando dados que viriam do Supabase
  Map<String, dynamic> supabaseData = {
    'id': 'abc123',
    'email': 'teste@exemplo.com',
    'name': 'Maria Silva',
    'avatar_url': 'https://exemplo.com/avatar.png',
    'created_at': '2025-11-03T12:00:00Z',
  };

  // Criando o usuário a partir do mapa
  UserModel user = UserModel.fromMap(supabaseData);

  // Imprimindo para verificar se tudo foi convertido corretamente
  print('Usuário criado a partir do mapa:');
  print(user);

  // Verificando consistência
  print('\nEmail correto? ${user.email == supabaseData['email']}');
  print('Nome correto? ${user.name == supabaseData['name']}');
  print('ID correto? ${user.id == supabaseData['id']}');
}
