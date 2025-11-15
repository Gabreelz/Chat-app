import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:chat_app/src/provaders/new_chat_provider.dart';
import 'package:chat_app/src/models/UserModel.dart';
import 'package:chat_app/src/widgets/custom_avatar.dart';

class NewChatPage extends StatefulWidget {
  const NewChatPage({super.key});

  @override
  State<NewChatPage> createState() => _NewChatPageState();
}

class _NewChatPageState extends State<NewChatPage> {
  final searchCtrl = TextEditingController();
  late NewChatProvider newChatProvider;

  @override
  void initState() {
    super.initState();
    newChatProvider = Provider.of<NewChatProvider>(context, listen: false);
    newChatProvider.loadAllUsers();
  }

  @override
  void dispose() {
    searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _startNewChat(UserModel otherUser) async {
    final supabase = Supabase.instance.client;
    final currentUserId = supabase.auth.currentUser?.id ?? '';

    try {
      // Criar ou obter conversa existente
      final conversationResponse = await supabase
          .from('conversations')
          .select()
          .or('(user_id1.eq.$currentUserId,user_id2.eq.${otherUser.id}),(user_id1.eq.${otherUser.id},user_id2.eq.$currentUserId)')
          .maybeSingle();

      String conversationId;

      if (conversationResponse == null) {
        // Criar nova conversa
        final newConversation = await supabase
            .from('conversations')
            .insert({
              'user_id1': currentUserId,
              'user_id2': otherUser.id,
              'created_at': DateTime.now().toIso8601String(),
            })
            .select()
            .single();

        conversationId = newConversation['id'];
      } else {
        conversationId = conversationResponse['id'];
      }

      // Navegar para chat
      if (mounted) {
        Navigator.pushNamed(
          context,
          '/chat',
          arguments: {
            'conversationId': conversationId,
            'otherUserId': otherUser.id,
            'otherUserName': otherUser.name,
            'otherUserAvatarUrl': otherUser.avatar_url,
          },
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao iniciar conversa: $e')),
        );
      }
      print('Erro ao criar/obter conversa: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Novo Chat'),
        elevation: 0,
      ),
      body: Consumer<NewChatProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.filteredUsers.isEmpty && provider.searchQuery.isEmpty) {
            return const Center(child: Text('Nenhum usuário disponível'));
          }

          if (provider.filteredUsers.isEmpty) {
            return Center(
              child: Text('Nenhum usuário encontrado para "${provider.searchQuery}"'),
            );
          }

          return Column(
            children: [
              // Barra de pesquisa
              Padding(
                padding: const EdgeInsets.all(16),
                child: TextField(
                  controller: searchCtrl,
                  onChanged: (value) => provider.searchUsers(value),
                  decoration: InputDecoration(
                    hintText: 'Pesquisar usuários',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: searchCtrl.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              searchCtrl.clear();
                              provider.clearSearch();
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                  onTap: () {
                    searchCtrl.selection = TextSelection(
                      baseOffset: 0,
                      extentOffset: searchCtrl.text.length,
                    );
                  },
                ),
              ),
              // Lista de usuários
              Expanded(
                child: ListView.builder(
                  itemCount: provider.filteredUsers.length,
                  itemBuilder: (context, index) {
                    final user = provider.filteredUsers[index];
                    return ListTile(
                      leading: CustomAvatar(
                        imageUrl: user.avatar_url,
                        name: user.name,
                        radius: 24,
                      ),
                      title: Text(user.name),
                      subtitle: Text(user.email),
                      onTap: () => _startNewChat(user),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}