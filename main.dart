import 'src/models/ConversationModel.dart';

void main() {
  Map<String, dynamic> data = {
    'id': 'conv123',
    'title': 'Grupo de Amigos',
    'created_at': '2025-11-03T13:00:00Z',
    'participant_ids': ['user1', 'user2'],
    'participants': [
      {
        'id': 'user1',
        'name': 'Maria',
        'email': 'maria@exemplo.com',
        'avatar_url': null,
        'created_at': '2025-11-01T10:00:00Z',
      },
      {
        'id': 'user2',
        'name': 'João',
        'email': 'joao@exemplo.com',
        'avatar_url': null,
        'created_at': '2025-11-02T11:00:00Z',
      }
    ],
    'messages': [
      {
        'id': 'msg1',
        'user_id': 'user1',
        'chat_id': 'conv123',
        'content': 'Oi João!',
        'media_url': null,
        'created_at': '2025-11-03T13:05:00Z',
      }
    ],
  };

  ConversationModel conv = ConversationModel.fromMap(data);
  print(conv);
  print(conv.toMap());
}
