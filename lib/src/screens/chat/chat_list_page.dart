import 'package:chat_app/src/utils/routes_enum.dart';
import 'package:chat_app/src/widgets/custom_avatar.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Usando intl (definido no pubspec.yaml) para formatar a data

/// Tela de lista de conversas (Deliverable 3 - Felipe UI/UX)
/// Layout limpo com preview de mensagens e uso de componentes.
class ChatListPage extends StatelessWidget {
  const ChatListPage({super.key});

  // TODO: Esta tela deve ser alimentada por dados reais (ViewModel/Service)
  // Estes são dados mocados (mock data) para implementar a UI/UX
  static final _mockConversations = [
    {
      'name': 'Grupo da Equipe',
      'lastMessage': 'Felipe: Ótimo, vou implementar o dark mode.',
      'time': DateTime.now().subtract(const Duration(minutes: 5)),
      'avatarUrl': null, // Usará a inicial 'G'
    },
    {
      'name': 'Ana Clara',
      'lastMessage': 'Vamos testar o envio de imagens.',
      'time': DateTime.now().subtract(const Duration(hours: 1)),
      'avatarUrl': 'https://i.pravatar.cc/150?img=32', 
    },
    {
      'name': 'Ricardo (Backend)',
      'lastMessage': 'A RLS do Supabase está configurada.',
      'time': DateTime.now().subtract(const Duration(days: 1)),
      'avatarUrl': null, 
    },
    {
      'name': 'Bug Reports',
      'lastMessage': 'Usuário: O botão de login não funciona.',
      'time': DateTime.now().subtract(const Duration(days: 2)),
      'avatarUrl': 'https://i.pravatar.cc/150?img=12', 
    }
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Conversas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Navigator.pushReplacementNamed(context, RoutesEnum.login.route);
            },
          )
        ],
      ),
      body: ListView.builder(
        itemCount: _mockConversations.length, 
        itemBuilder: (context, index) {
          final conversation = _mockConversations[index];
          final time = conversation['time'] as DateTime;

          return ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: CustomAvatar(
              name: conversation['name'] as String,
              imageUrl: conversation['avatarUrl'] as String?,
              radius: 26,
            ),
            title: Text(
              conversation['name'] as String,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
            ),
            subtitle: Text(
              conversation['lastMessage'] as String,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.7)),
            ),
            trailing: Text(
              _formatTimestamp(time), 
              style: TextStyle(
                fontSize: 12,
                color: theme.colorScheme.onSurface.withOpacity(0.5),
              ),
            ),
            onTap: () {

            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, RoutesEnum.newChat.route);
        },
        backgroundColor: theme.primaryColor,
        tooltip: 'Nova Conversa',
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  String _formatTimestamp(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inDays == 0) {
      return DateFormat.Hm().format(time); 
    } else if (difference.inDays == 1) {
      return 'Ontem';
    } else {
      return DateFormat('dd/MM/yy').format(time); 
    }
  }
}