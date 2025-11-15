import 'dart:io';
import 'package:chat_app/src/widgets/custom_avatar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:chat_app/src/provaders/chat_provider.dart';
import 'package:chat_app/src/models/messageModel.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  late String conversationId;
  late String otherUserId;
  String? otherUserName;
  String? otherUserAvatarUrl;

  final supabase = Supabase.instance.client;
  final textCtrl = TextEditingController();
  bool loading = false;
  late ChatProvider chatProvider;
  final ScrollController _scrollCtrl = ScrollController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    conversationId = args?['conversationId'] ?? '';
    otherUserId = args?['otherUserId'] ?? '';
    otherUserName = args?['otherUserName']; // Captura o nome
    otherUserAvatarUrl = args?['otherUserAvatarUrl']; // Captura o avatar

    chatProvider = Provider.of<ChatProvider>(context, listen: false);
    chatProvider.loadMessages(conversationId, otherUserId: otherUserId);
  }

  Future<void> _sendText() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;
    if (textCtrl.text.trim().isEmpty) return;

    await chatProvider.sendText(conversationId, user.id, textCtrl.text.trim());
    textCtrl.clear();
    _scrollToBottom();
  }

  Future<void> _sendImage() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    final picker = ImagePicker();
    final XFile? file = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1200,
    );
    if (file == null) return;

    setState(() => loading = true);

    try {
      final bucket = 'chat_files';
      final ext = file.path.split('.').last;
      final key = '$conversationId/${DateTime.now().millisecondsSinceEpoch}.$ext';

      await supabase.storage.from(bucket).uploadBinary(
            key,
            await File(file.path).readAsBytes(),
            fileOptions: const FileOptions(upsert: true),
          );

      final publicUrl = supabase.storage.from(bucket).getPublicUrl(key);

      await chatProvider.sendFile(conversationId, user.id, publicUrl);

      _scrollToBottom();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao enviar imagem: $e')),
        );
      }
    } finally {
      setState(() => loading = false);
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _onLongPressMessage(MessageModel m) async {
    final currentUserId = supabase.auth.currentUser?.id ?? '';
    final isAuthor = m.authorId == currentUserId;
    final canEdit = isAuthor && m.canBeEdited();
    final canDelete = isAuthor && m.canBeDeleted();

    showModalBottomSheet(
      context: context,
      builder: (_) {
        return SafeArea(
          child: Wrap(
            children: [
              if (canEdit)
                ListTile(
                  leading: const Icon(Icons.edit),
                  title: const Text('Editar'),
                  onTap: () {
                    Navigator.of(context).pop();
                    _showEditDialog(m);
                  },
                ),
              if (canDelete)
                ListTile(
                  leading: const Icon(Icons.delete),
                  title: const Text('Apagar'),
                  onTap: () async {
                    Navigator.of(context).pop();
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: const Text('Confirmação'),
                        content: const Text('Deseja apagar esta mensagem?'),
                        actions: [
                          TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text('Cancelar')),
                          TextButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: const Text('Apagar')),
                        ],
                      ),
                    );
                    if (confirm == true) {
                      await chatProvider.deleteMessage(m.id);
                    }
                  },
                ),
              ListTile(
                leading: const Icon(Icons.close),
                title: const Text('Fechar'),
                onTap: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showEditDialog(MessageModel m) {
    final editCtrl = TextEditingController(text: m.text ?? '');
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Editar mensagem'),
        content: TextField(
          controller: editCtrl,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Texto'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              final newText = editCtrl.text.trim();
              if (newText.isNotEmpty) {
                await chatProvider.editMessage(m.id, newText);
              }
              Navigator.of(context).pop();
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
    // O dispose estava no lugar errado, movido para fora do builder
    // editCtrl.dispose();
  }

  String _formatLastSeen(DateTime? lastSeen) {
    if (lastSeen == null) return 'offline';

    final now = DateTime.now();
    final diff = now.difference(lastSeen);

    if (diff.inSeconds < 60) {
      return 'agora';
    } else if (diff.inMinutes < 60) {
      return 'há ${diff.inMinutes}m';
    } else if (diff.inHours < 24) {
      return 'há ${diff.inHours}h';
    } else {
      return 'há ${diff.inDays}d';
    }
  }

  @override
  void dispose() {
    chatProvider.disposeSubscription();
    textCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  Widget _buildMessageTile(MessageModel m, String currentUserId) {
    final isMe = m.authorId == currentUserId;
    final align = isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start;
    final color = isMe ? Colors.blue.shade200 : Colors.grey.shade200;
    final textColor = Colors.black87;

    return GestureDetector(
      onLongPress: () => _onLongPressMessage(m),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
        child: Column(
          crossAxisAlignment: align,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.75,
              ),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(12),
              ),
              child: m.fileUrl != null
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Image.network(
                          m.fileUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                              const Icon(Icons.broken_image),
                        ),
                        if (m.text != null && m.text!.isNotEmpty) ...[
                          const SizedBox(height: 6),
                          Text(m.text!, style: TextStyle(color: textColor)),
                        ]
                      ],
                    )
                  : Text(m.text ?? '', style: TextStyle(color: textColor)),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  TimeOfDay.fromDateTime(m.createdAt).format(context),
                  style: const TextStyle(
                    fontSize: 11,
                    color: Colors.black54,
                  ),
                ),
                if (m.wasEdited) ...[
                  const SizedBox(width: 6),
                  const Text(
                    '(editado)',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.black45,
                    ),
                  ),
                ],
                if (isMe) ...[
                  const SizedBox(width: 6),
                  Icon(
                    m.isRead ? Icons.done_all : Icons.done,
                    size: 14,
                    color: m.isRead ? Colors.blue : Colors.black38,
                  )
                ]
              ],
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = supabase.auth.currentUser?.id ?? '';

    return Scaffold(
      appBar: AppBar(
        // Adiciona o Avatar
        leadingWidth: 40,
        leading: Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: CustomAvatar(
            name: otherUserName ?? '?',
            imageUrl: otherUserAvatarUrl,
            radius: 18,
          ),
        ),
        title: Consumer<ChatProvider>(
          builder: (context, provider, _) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Usa o nome do usuário recebido por argumento
                Text(otherUserName ?? 'Chat'), 
                const SizedBox(height: 4),
                Text(
                  provider.otherUserIsOnline
                      ? 'online'
                      : 'offline • ${_formatLastSeen(provider.otherUserLastSeen)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: provider.otherUserIsOnline
                        ? Colors.green
                        : Colors.grey,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ],
            );
          },
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Consumer<ChatProvider>(
              builder: (context, provider, _) {
                WidgetsBinding.instance
                    .addPostFrameCallback((_) => _scrollToBottom());
                final msgs = provider.messages;
                final isSomeoneTyping = provider.typingUsers.entries
                    .any((e) => e.value && e.key != currentUserId);

                if (msgs.isEmpty) {
                  return const Center(child: Text('Sem mensagens ainda'));
                }

                return Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        controller: _scrollCtrl,
                        itemCount: msgs.length,
                        itemBuilder: (_, i) =>
                            _buildMessageTile(msgs[i], currentUserId),
                      ),
                    ),
                    if (isSomeoneTyping)
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'digitando...',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
          if (loading) const LinearProgressIndicator(),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.image),
                    onPressed: _sendImage,
                  ),
                  Expanded(
                    child: TextField(
                      controller: textCtrl,
                      textCapitalization: TextCapitalization.sentences,
                      onChanged: (_) =>
                          chatProvider.startTyping(conversationId),
                      onSubmitted: (_) => _sendText(),
                      decoration: const InputDecoration(
                        hintText: 'Escreva uma mensagem',
                        border: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.all(Radius.circular(20)),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _sendText,
                    child: const Text('Enviar'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}