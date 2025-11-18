import 'package:chat_app/src/provaders/chat_list_provider.dart';
import 'package:chat_app/src/utils/routes_enum.dart';
import 'package:chat_app/src/widgets/custom_avatar.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ChatListPage extends StatefulWidget {
  const ChatListPage({super.key});

  @override
  State<ChatListPage> createState() => _ChatListPageState();
}

class _ChatListPageState extends State<ChatListPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ChatListProvider>(context, listen: false).loadConversations();
    });
  }

  String _formatTimestamp(DateTime? time) {
    if (time == null) return '';
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = Provider.of<ChatListProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Partness Chat'),
        leading: IconButton(
          onPressed: () async {
            await Supabase.instance.client.auth.signOut();
            if (mounted) {
              Navigator.pushReplacementNamed(context, RoutesEnum.login.route);
            }
          },
          icon: Image.asset(
            'assets/icons/saida.png', // ajuste o caminho do seu PNG
            width: 24,
            height: 24,
          ),
        ),
      ),
      body: _buildBody(context, provider, theme),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.pushNamed(context, RoutesEnum.newChat.route);
          if (mounted) {
            Provider.of<ChatListProvider>(context, listen: false)
                .loadConversations();
          }
        },
        tooltip: 'Nova Conversa',
        child: Image.asset(
          'assets/icons/logoP.png',
          width: 28,
          height: 28,
        ),
      ),
    );
  }

  Widget _buildBody(
      BuildContext context, ChatListProvider provider, ThemeData theme) {
    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.errorMessage != null) {
      return Center(
          child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(
          'Erro ao carregar: ${provider.errorMessage}',
          textAlign: TextAlign.center,
        ),
      ));
    }

    if (provider.conversations.isEmpty) {
      return const Center(
        child: Text(
          'Nenhuma conversa encontrada.\nClique em "+" para iniciar um novo chat.',
          textAlign: TextAlign.center,
        ),
      );
    }

    return ListView.builder(
      itemCount: provider.conversations.length,
      itemBuilder: (context, index) {
        final conversation = provider.conversations[index];
        final time = conversation.lastMessageTimestamp;
        final currentUserId = Supabase.instance.client.auth.currentUser?.id;

        String lastMessageText = conversation.lastMessageText ?? '...';
        if (conversation.lastMessageAuthorId == currentUserId &&
            lastMessageText != '...') {
          lastMessageText = 'Você: $lastMessageText';
        }

        return ListTile(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          leading: CustomAvatar(
            name: conversation.otherUserName,
            imageUrl: conversation.otherUserAvatarUrl,
            radius: 26,
          ),
          title: Text(
            conversation.otherUserName,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
          ),
          subtitle: Text(
            lastMessageText,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style:
                TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.7)),
          ),
          trailing: Text(
            _formatTimestamp(time),
            style: TextStyle(
              fontSize: 12,
              color: theme.colorScheme.onSurface.withOpacity(0.5),
            ),
          ),
          onTap: () async {
            await Navigator.pushNamed(
              context,
              RoutesEnum.chatPage.route,
              arguments: {
                'conversationId': conversation.conversationId,
                'otherUserId': conversation.otherUserId,
                'otherUserName': conversation.otherUserName,
                'otherUserAvatarUrl': conversation.otherUserAvatarUrl,
              },
            );
            if (mounted) {
              Provider.of<ChatListProvider>(context, listen: false)
                  .loadConversations();
            }
          },
        );
      },
    );
  }
}
