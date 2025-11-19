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
  late ChatProvider chatProvider;
  final ScrollController _scrollCtrl = ScrollController();
  bool loading = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    conversationId = args?['conversationId'] ?? '';
    otherUserId = args?['otherUserId'] ?? '';
    otherUserName = args?['otherUserName'];
    otherUserAvatarUrl = args?['otherUserAvatarUrl'];

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
    final XFile? file =
        await picker.pickImage(source: ImageSource.gallery, maxWidth: 1200);
    if (file == null) return;

    setState(() => loading = true);
    try {
      final bucket = 'chat_files';
      final ext = file.path.split('.').last;
      final key =
          '$conversationId/${DateTime.now().millisecondsSinceEpoch}.$ext';

      await supabase.storage.from(bucket).uploadBinary(
            key,
            await File(file.path).readAsBytes(),
            fileOptions: const FileOptions(upsert: true),
          );

      final url = supabase.storage.from(bucket).getPublicUrl(key);
      await chatProvider.sendFile(conversationId, user.id, url);

      _scrollToBottom();
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
    final userId = supabase.auth.currentUser?.id ?? '';
    final isAuthor = m.authorId == userId;

    showModalBottomSheet(
      context: context,
      builder: (_) {
        return SafeArea(
          child: Wrap(
            children: [
              if (isAuthor && m.canBeEdited())
                ListTile(
                  leading: const Icon(Icons.edit),
                  title: const Text('Editar'),
                  onTap: () {
                    Navigator.pop(context);
                    _showEditDialog(m);
                  },
                ),
              if (isAuthor && m.canBeDeleted())
                ListTile(
                  leading: const Icon(Icons.delete),
                  title: const Text('Apagar'),
                  onTap: () async {
                    Navigator.pop(context);
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: const Text('Confirmação'),
                        content:
                            const Text('Deseja apagar esta mensagem?'),
                        actions: [
                          TextButton(
                              onPressed: () =>
                                  Navigator.pop(context, false),
                              child: const Text('Cancelar')),
                          TextButton(
                              onPressed: () =>
                                  Navigator.pop(context, true),
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
                onTap: () => Navigator.pop(context),
              )
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
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar')),
          TextButton(
              onPressed: () async {
                final txt = editCtrl.text.trim();
                if (txt.isNotEmpty) {
                  await chatProvider.editMessage(m.id, txt);
                }
                Navigator.pop(context);
              },
              child: const Text('Salvar')),
        ],
      ),
    );
  }

  String _formatLastSeen(DateTime? lastSeen) {
    if (lastSeen == null) return "offline";
    final diff = DateTime.now().difference(lastSeen);
    if (diff.inSeconds < 60) return "agora";
    if (diff.inMinutes < 60) return "há ${diff.inMinutes}m";
    if (diff.inHours < 24) return "há ${diff.inHours}h";
    return "há ${diff.inDays}d";
  }

  @override
  void dispose() {
    chatProvider.disposeSubscription();
    textCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  Widget _buildMessageTile(MessageModel m, String userId) {
    final isMe = m.authorId == userId;
    final align =
        isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start;
    final bg = isMe ? Colors.blue.shade200 : Colors.grey.shade200;

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
                  maxWidth:
                      MediaQuery.of(context).size.width * 0.75),
              decoration: BoxDecoration(
                color: bg,
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
                        if (m.text != null && m.text!.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Text(m.text!),
                          )
                      ],
                    )
                  : Text(m.text ?? ''),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    TimeOfDay.fromDateTime(m.createdAt)
                        .format(context),
                    style: const TextStyle(
                        fontSize: 11, color: Colors.black54),
                  ),
                  if (m.wasEdited)
                    const Padding(
                      padding: EdgeInsets.only(left: 6),
                      child: Text(
                        "(editado)",
                        style: TextStyle(
                            fontSize: 11, color: Colors.black45),
                      ),
                    ),
                  if (isMe)
                    Padding(
                      padding: const EdgeInsets.only(left: 6),
                      child: Icon(
                        m.isRead ? Icons.done_all : Icons.done,
                        size: 14,
                        color: m.isRead ? Colors.blue : Colors.black38,
                      ),
                    )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userId = supabase.auth.currentUser?.id ?? '';

    return Scaffold(
      appBar: AppBar(
        leadingWidth: 40,
        leading: Padding(
          padding: const EdgeInsets.only(left: 8),
          child: CustomAvatar(
            name: otherUserName ?? "?",
            imageUrl: otherUserAvatarUrl,
            radius: 18,
          ),
        ),
        title: Consumer<ChatProvider>(
          builder: (_, provider, __) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(otherUserName ?? "Chat"),
                Text(
                  provider.otherUserIsOnline
                      ? "online"
                      : "offline • ${_formatLastSeen(provider.otherUserLastSeen)}",
                  style: TextStyle(
                    fontSize: 12,
                    color: provider.otherUserIsOnline
                        ? Colors.green
                        : Colors.grey,
                  ),
                )
              ],
            );
          },
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Consumer<ChatProvider>(
              builder: (_, provider, __) {
                WidgetsBinding.instance
                    .addPostFrameCallback((_) => _scrollToBottom());

                final msgs = provider.messages;

               

                return ListView.builder(
                  controller: _scrollCtrl,
                  itemCount: msgs.length,
                  itemBuilder: (_, i) =>
                      _buildMessageTile(msgs[i], userId),
                );
              },
            ),
          ),
          if (loading) const LinearProgressIndicator(),
          SafeArea(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              child: Row(
                children: [
                  IconButton(
                      icon: const Icon(Icons.image),
                      onPressed: _sendImage),
                  Expanded(
                    child: TextField(
                      controller: textCtrl,
                      onChanged: (_) =>
                          chatProvider.startTyping(conversationId),
                      onSubmitted: (_) => _sendText(),
                      decoration: const InputDecoration(
                        hintText: "Escreva uma mensagem",
                        border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(20))),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                      onPressed: _sendText,
                      child: const Text("Enviar"))
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
