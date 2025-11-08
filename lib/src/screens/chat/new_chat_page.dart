import 'package:chat_app/src/widgets/custom_avatar.dart';
import 'package:chat_app/src/widgets/custom_input.dart';
import 'package:flutter/material.dart';

class NewChatScreen extends StatefulWidget {
  const NewChatScreen({super.key});

  @override
  State<NewChatScreen> createState() => _NewChatScreenState();
}

class _NewChatScreenState extends State<NewChatScreen> {
  final TextEditingController _searchController = TextEditingController();
  static final _mockUsers = [
    {'name': 'Ana Clara', 'email': 'ana@example.com', 'avatarUrl': 'https://i.pravatar.cc/150?img=32'},
    {'name': 'Ricardo (Backend)', 'email': 'ricardo@example.com', 'avatarUrl': null},
    {'name': 'Debug User', 'email': 'debug@example.com', 'avatarUrl': null},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nova Conversa'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: CustomInput(
              label: 'Buscar',
              hint: 'Buscar por nome ou email...',
              controller: _searchController,
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _mockUsers.length, 
              itemBuilder: (context, index) {
                final user = _mockUsers[index];
                return ListTile(
                  leading: CustomAvatar(
                    name: user['name']!,
                    imageUrl: user['avatarUrl'],
                    radius: 22,
                  ),
                  title: Text(user['name']!),
                  subtitle: Text(user['email']!),
                  onTap: () {
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}