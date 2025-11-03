import 'src/models/messageModel.dart';

void main() {
  Map<String, dynamic> data = {
    'id': 'msg123',
    'user_id': 'user456',
    'chat_id': 'chat789',
    'content': 'Olá, tudo bem?',
    'media_url': null,
    'created_at': '2025-11-03T12:30:00Z',
  };

  messageModel message = messageModel.fromMap(data);
  print(message);
  print(message.toMap());
}