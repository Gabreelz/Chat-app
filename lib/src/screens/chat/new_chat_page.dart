import 'package:chat_app/src/models/UserModel.dart';
import 'package:chat_app/src/utils/routes_enum.dart';
import 'package:chat_app/src/widgets/custom_avatar.dart';
import 'package:chat_app/src/widgets/custom_input.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class NewChatScreen extends StatefulWidget {
  const NewChatScreen({super.key});

  @override
  State<NewChatScreen> createState() => _NewChatScreenState();
}

class _NewChatScreenState extends State<NewChatScreen> {
  final TextEditingController _searchController = TextEditingController();
  final _supabase = Supabase.instance.client;
  late Future<List<UserModel>> _usersFuture;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _usersFuture = _fetchUsers();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<List<UserModel>> _fetchUsers() async {
    try {
      final currentUserId = _supabase.auth.currentUser?.id;
      if (currentUserId == null) throw Exception('Não autenticado');

      final response = await _supabase
          .from('users')
          .select()
          .neq('id', currentUserId);

      return (response as List)
          .map((data) => UserModel.fromMap(data))
          .toList();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao buscar usuários: $e')),
        );
      }
      return [];
    }
  }

  Future<void> _navigateToChat(UserModel user) async {
    if (!mounted) return;

    final navigator = Navigator.of(context);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final String conversationId = await _supabase.rpc(
        'find_or_create_conversation',
        params: {'other_user_id': user.id},
      );

      navigator.pop(); // Remove o loading

      if (mounted) {
        navigator.pushReplacementNamed(
          RoutesEnum.chatPage.route,
          arguments: {
            'conversationId': conversationId,
            'otherUserId': user.id,
            'otherUserName': user.name,
            'otherUserAvatarUrl': user.avatarUrl,
          },
        );
      }
    } catch (e) {
      navigator.pop(); // Remove o loading em caso de erro
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao iniciar conversa: $e')),
        );
      }
    }
  }

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
            child: FutureBuilder<List<UserModel>>(
              future: _usersFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Erro: ${snapshot.error}'));
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('Nenhum usuário encontrado'));
                }

                final users = snapshot.data!.where((user) {
                  final nameMatch =
                      user.name.toLowerCase().contains(_searchQuery);
                  final emailMatch =
                      user.email.toLowerCase().contains(_searchQuery);
                  return nameMatch || emailMatch;
                }).toList();

                return ListView.builder(
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    final user = users[index];
                    return ListTile(
                      leading: CustomAvatar(
                        name: user.name,
                        imageUrl: user.avatarUrl,
                        radius: 22,
                      ),
                      title: Text(user.name),
                      subtitle: Text(user.email),
                      onTap: () => _navigateToChat(user),
                    );
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