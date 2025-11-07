// lib/src/screens/chat/chat_list_page.dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ChatListPage extends StatefulWidget {
  const ChatListPage({super.key});
  @override
  State<ChatListPage> createState() => _ChatListPageState();
}

class _ChatListPageState extends State<ChatListPage> {
  final supabase = Supabase.instance.client;
  List<Map<String, dynamic>> conversations = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    final res = await supabase
        .from('conversations')
        .select('*, participants(*)')
        .or('owner_id.eq.${user.id},participants.user_id.eq.${user.id}');

    // o retorno já é List<dynamic> (não há mais res.data)
    final data = res as List<dynamic>? ?? [];

    setState(() {
      conversations = data.map((e) => Map<String, dynamic>.from(e)).toList();
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (loading) return const Center(child: CircularProgressIndicator());
    if (conversations.isEmpty)
      return const Center(child: Text('Nenhuma conversa.'));

    return ListView.builder(
      itemCount: conversations.length,
      itemBuilder: (context, i) {
        final conv = conversations[i];
        final title = conv['title'] ?? 'Conversa';
        final id = conv['id'];
        return ListTile(
          title: Text(title),
          subtitle: const Text('Última mensagem...'),
          onTap: () {
            Navigator.pushNamed(
              context,
              '/chat',
              arguments: {'conversationId': id, 'title': title},
            );
          },
        );
      },
    );
  }
}
