import 'package:chat_app/src/utils/routes_enum.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:chat_app/src/provaders/new_chat_provider.dart';
import 'package:chat_app/src/models/UserModel.dart';
import 'package:chat_app/src/widgets/custom_avatar.dart';

class NewChatScreen extends StatefulWidget {
  const NewChatScreen({super.key});

  @override
  State<NewChatScreen> createState() => _NewChatScreenState();
}

class _NewChatScreenState extends State<NewChatScreen> {
  final searchCtrl = TextEditingController();
  late NewChatProvider newChatProvider;

  @override
  void initState() {
    super.initState();
    newChatProvider = Provider.of<NewChatProvider>(context, listen: false);
    // Carrega os usuários sem atraso
    WidgetsBinding.instance.addPostFrameCallback((_) {
      newChatProvider.loadAllUsers();
    });
  }

  @override
  void dispose() {
    searchCtrl.dispose();
    super.dispose();
  }

  // --- ESTA É A CORREÇÃO PRINCIPAL (TASK 2) ---
  Future<void> _startNewChat(UserModel otherUser) async {
    final supabase = Supabase.instance.client;
    // 1. Mostrar loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      // 2. Chamar a função SQL que você criou no banco de dados
      final conversationId = await supabase.rpc(
        'find_or_create_conversation',
        params: {'other_user_id': otherUser.id},
      ) as String?; // Cast para String

      if (conversationId == null) {
        throw Exception("Não foi possível obter a conversationId da RPC.");
      }

      // 3. Fechar o loading
      if (mounted) Navigator.pop(context);

      // 4. Navegar para a tela de chat com os dados corretos
      if (mounted) {
        // Navega e *substitui* a tela atual (NewChatPage)
        Navigator.pushReplacementNamed(
          context,
          RoutesEnum.chatPage.route,
          arguments: {
            'conversationId': conversationId,
            'otherUserId': otherUser.id,
            'otherUserName': otherUser.name,
            'otherUserAvatarUrl': otherUser.avatarUrl, // Corrigido: avatarUrl
          },
        );
      }
    } catch (e) {
      if (mounted) Navigator.pop(context); // Fecha o loading em caso de erro
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
        // ✅ ADICIONADO: Botão de Refresh na AppBar
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => newChatProvider.loadAllUsers(),
            tooltip: 'Recarregar usuários',
          )
        ],
      ),
      body: Consumer<NewChatProvider>(
        builder: (context, provider, _) {
          // ✅ CORREÇÃO: A estrutura principal (Column) é retornada SEMPRE.
          // O loading ou lista vazia são tratados APENAS na área da lista.
          return Column(
            children: [
              // 1. Barra de Pesquisa (Sempre visível)
              Padding(
                padding: const EdgeInsets.all(16),
                child: TextField(
                  controller: searchCtrl,
                  onChanged: (value) => provider.searchUsers(value),
                  decoration: InputDecoration(
                    hintText: 'Pesquisar usuários',
                    prefixIcon: const Icon(Icons.search),
                    // Botão de limpar busca
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
                ),
              ),

              // 2. Conteúdo da Lista (Variável)
              Expanded(
                child: Builder(
                  builder: (context) {
                    // Estado de Loading
                    if (provider.isLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    // Estado de Lista Vazia (Geral)
                    if (provider.allUsers.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.person_off, size: 48, color: Colors.grey),
                            const SizedBox(height: 16),
                            const Text('Nenhum usuário encontrado.'),
                            const SizedBox(height: 8),
                            // ✅ Botão extra para tentar recarregar no meio da tela
                            TextButton.icon(
                                onPressed: () => provider.loadAllUsers(),
                                icon: const Icon(Icons.refresh),
                                label: const Text("Tentar novamente")
                            )
                          ],
                        ),
                      );
                    }

                    // Estado de Busca sem resultados
                    if (provider.filteredUsers.isEmpty && provider.searchQuery.isNotEmpty) {
                      return Center(
                        child: Text('Nenhum usuário encontrado para "${provider.searchQuery}"'),
                      );
                    }

                    // Lista de Usuários
                    return ListView.builder(
                      itemCount: provider.filteredUsers.length,
                      itemBuilder: (context, index) {
                        final user = provider.filteredUsers[index];
                        return ListTile(
                          leading: CustomAvatar(
                            imageUrl: user.avatarUrl,
                            name: user.name,
                            radius: 24,
                          ),
                          title: Text(user.name),
                          subtitle: Text(user.email),
                          onTap: () => _startNewChat(user),
                        );
                      },
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