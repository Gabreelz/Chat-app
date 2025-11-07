// lib/src/MyApp.dart
import 'package:flutter/material.dart';
import 'package:chat_app/src/screens/login/login_page.dart';
import 'package:chat_app/src/screens/login/signup_page.dart';
import 'package:chat_app/src/screens/home/home_page.dart';
import 'package:chat_app/src/screens/chat/chat_page.dart';
import 'package:chat_app/src/screens/chat/chat_list_page.dart';
import 'package:chat_app/src/utils/routes_enum.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chat App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: RoutesEnum.login.route,
      routes: {
        RoutesEnum.login.route: (_) => LoginScreen(),
        RoutesEnum.register.route: (_) => const RegisterScreen(),
        RoutesEnum.home.route: (_) => const HomeScreen(),
        '/chat': (_) => const ChatPage(),
        '/chats': (_) => const ChatListPage(),
      },
    );
  }
}
