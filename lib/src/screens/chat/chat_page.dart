import 'dart:io';
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
  final supabase = Supabase.instance.client;
  final textCtrl = TextEditingController();
  bool loading = false;
  late ChatProvider chatProvider;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    conversationId = args?['conversationId'] ?? '';
    chatProvider = Provider.of<ChatProvider>(context, listen: false);
    chatProvider.loadMessages(conversationId);
  }

  Future<void> _sendText() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;
    if (textCtrl.text.trim().isEmpty) return;

    await chatProvider.sendText(conversationId, user.id, textCtrl.text.trim());
    textCtrl.clear();
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

    final bucket = 'chat_files';
    final ext = file.path.split('.').last;
    final key = '$conversationId/${DateTime.now().millisecondsSinceEpoch}.$ext';

    // Upload da imagem (usa a API moderna do Supabase)
    await supabase.storage.from(bucket).uploadBinary(
          key,
          await File(file.path).readAsBytes(),
          fileOptions: const FileOptions(upsert: true),
        );

    // Obter URL pública (nova API retorna objeto com .data)
    final publicUrl = supabase.storage.from(bucket).getPublicUrl(key);

    // Enviar mensagem com a URL da imagem
    await chatProvider.sendFile(conversationId, user.id, publicUrl);

    setState(() => loading = false);
  }

  @override
  void dispose() {
    chatProvider.disposeSubscription();
    textCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chat')),
      body: Column(
        children: [
          Expanded(
            child: Consumer<ChatProvider>(
              builder: (context, cp, _) {
                final msgs = cp.messages;
                if (msgs.isEmpty) {
                  return const Center(child: Text('Nenhuma mensagem ainda'));
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: msgs.length,
                  itemBuilder: (context, i) {
                    final MessageModel m = msgs[i];
                    final me = supabase.auth.currentUser?.id;
                    final isMe = m.authorId == me;

                    return Align(
                      alignment:
                          isMe ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: isMe
                              ? Colors.indigo.shade100
                              : Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: isMe
                              ? CrossAxisAlignment.end
                              : CrossAxisAlignment.start,
                          children: [
                            if (m.text != null)
                              Text(
                                m.text!,
                                style: const TextStyle(fontSize: 15),
                              ),
                            if (m.fileUrl != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 6),
                                child: GestureDetector(
                                  onTap: () {
                                    // você pode abrir em tela cheia futuramente
                                  },
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.network(
                                      m.fileUrl!,
                                      width: 200,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              ),
                            const SizedBox(height: 4),
                            Text(
                              m.createdAt.toLocal().toString(),
                              style: const TextStyle(
                                fontSize: 10,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          if (loading) const LinearProgressIndicator(),
          SafeArea(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.photo),
                    onPressed: _sendImage,
                  ),
                  Expanded(
                    child: TextField(
                      controller: textCtrl,
                      decoration:
                          const InputDecoration(hintText: 'Mensagem...'),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send),
                    onPressed: _sendText,
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
