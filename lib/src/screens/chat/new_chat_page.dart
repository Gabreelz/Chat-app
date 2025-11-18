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

        // --- BOTÃO DE VOLTAR COM PNG ---
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Image.asset(
            'assets/icons/back-button.png', // coloque seu PNG aqui
            width: 24,
            height: 24,
          ),
          tooltip: 'Voltar',
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: IconButton(
              onPressed: () => newChatProvider.loadAllUsers(),
              icon: Image.asset(
                'assets/icons/recarregando.png',
                width: 28,
                height: 28,
              ),
              tooltip: 'Recarregar usuários',
            ),
          ),
        ],
      ),
      body: Consumer<NewChatProvider>(
        builder: (context, provider, _) {
          // ✅ CORREÇÃO: A estrutura principal (Column) é retornada SEMPRE.
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

                    // --- ÍCONE DE BUSCA COM PNG ---
                    prefixIcon: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Image.asset(
                        'assets/icons/lupa.png', // seu PNG aqui
                        width: 20,
                        height: 20,
                        fit: BoxFit.contain,
                      ),
                    ),

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

                    if (provider.allUsers.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Substituindo o ícone por PNG
                            Image.asset(
                              'assets/icons/logoP.png',
                              width: 80,
                              height: 80,
                              fit: BoxFit.contain,
                            ),

                            const SizedBox(height: 16),

                            const Text(
                              'Nenhum usuário encontrado.',
                              style: TextStyle(fontSize: 16),
                            ),

                            const SizedBox(height: 8),

                            // Botão tentar novamente (sem ícone, como pediu)
                            TextButton(
                              onPressed: () => provider.loadAllUsers(),
                              child: const Text("Tentar novamente"),
                            ),
                          ],
                        ),
                      );
                    }

                    // Estado de Busca sem resultados
                    if (provider.filteredUsers.isEmpty &&
                        provider.searchQuery.isNotEmpty) {
                      return Center(
                        child: Text(
                            'Nenhum usuário encontrado para "${provider.searchQuery}"'),
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
