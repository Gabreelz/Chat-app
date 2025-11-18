import 'package:chat_app/src/utils/routes_enum.dart';
import 'package:chat_app/src/widgets/custom_input.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _textController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const ChatComponent(),
          InputComponent(controller: _textController),
        ],
      ),
    );
  }
}

class ChatComponent extends StatefulWidget {
  const ChatComponent({super.key});

  @override
  State<ChatComponent> createState() => _ChatComponentState();
}

class _ChatComponentState extends State<ChatComponent> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream:
          Supabase.instance.client.from('chat_room').stream(primaryKey: ['id']),
      builder: (context, asyncSnapshot) {
        if (asyncSnapshot.connectionState == ConnectionState.waiting) {
          return const Expanded(
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (asyncSnapshot.hasError) {
          return Expanded(
            child: Center(child: Text('Erro: ${asyncSnapshot.error}')),
          );
        }

        if (!asyncSnapshot.hasData || asyncSnapshot.data!.isEmpty) {
          return const Expanded(
            child: Center(child: Text('Nenhuma mensagem disponível')),
          );
        }

        final messages = asyncSnapshot.data!;

        return Expanded(
          child: ListView.builder(
            itemCount: messages.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.all(8),
                child: Align(
                  alignment: messages[index]['from_id'] ==
                          Supabase.instance.client.auth.currentUser!.id
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    width: 200,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      border: Border.all(color: Colors.grey.withOpacity(0.5)),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.all(8),
                    child: Text(messages[index]['content'] as String),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class InputComponent extends StatefulWidget {
  const InputComponent({required this.controller, super.key});

  final TextEditingController controller;

  @override
  State<InputComponent> createState() => _InputComponentState();
}

class _InputComponentState extends State<InputComponent> {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: CustomInput(
            label: '',
            hint: 'Digite sua mensagem',
            controller: widget.controller,
          ),
        ),
        IconButton(
          icon: const Icon(Icons.send),
          onPressed: () async {
            final content = widget.controller.text;
            debugPrint(
              'user data: '
              '${Supabase.instance.client.auth.currentUser}',
            );
            if (content.isNotEmpty) {
              await Supabase.instance.client.from('chat_room').insert({
                'content': content,
                'from_id': Supabase.instance.client.auth.currentUser!.id,
                'from_name': Supabase.instance.client.auth.currentUser!
                    .userMetadata?['full_name'],
              });
              widget.controller.clear();
            }
          },
        ),
      ],
    );
  }
}
