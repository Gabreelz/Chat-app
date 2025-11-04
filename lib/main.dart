import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Atualize para os caminhos corretos do seu projeto
import 'package:chat_app/src/screens/login/login_page.dart';
import 'package:chat_app/src/screens/chat/chat_list_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://jfnbjmuyvqfpzkhjiscr.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImpmbmJqbXV5dnFmcHpraGppc2NyIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjIxODkyNjMsImV4cCI6MjA3Nzc2NTI2M30.G1BR610e2TmbtfMF_i7YwDJs9HYTxSNYPjDTHiKMRj4',
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chat App',
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => const LoginPage(),
        '/chat_list': (context) => const ChatListPage(),
      },
    );
  }
}
