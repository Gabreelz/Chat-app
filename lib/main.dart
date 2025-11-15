import 'package:chat_app/src/screens/chat/chat_list_page.dart';
import 'package:chat_app/src/screens/chat/new_chat_page.dart';
import 'package:chat_app/src/screens/home/home_page.dart';
import 'package:chat_app/src/screens/login/signup_page.dart';
import 'package:chat_app/src/theme/app_theme.dart';
import 'package:chat_app/src/utils/routes_enum.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:chat_app/src/screens/login/login_page.dart';
import 'package:chat_app/src/screens/chat/chat_page.dart';
import 'package:chat_app/src/provaders/auth_provider.dart';
import 'package:chat_app/src/provaders/chat_provider.dart';
import 'package:chat_app/src/provaders/new_chat_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://jfnbjmuyvqfpzkhjiscr.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImpmbmJqbXV5dnFmcHpraGppc2NyIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjIxODkyNjMsImV4cCI6MjA3Nzc2NTI2M30.G1BR610e2TmbtfMF_i7YwDJs9HYTxSNYPjDTHiKMRj4',
  );

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  /// Construtor da classe [MainApp]
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => ChatProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => NewChatProvider(),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        builder: FToastBuilder(),
        
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system, 

        routes: {
          RoutesEnum.login.route: (context) => LoginScreen(),
          RoutesEnum.register.route: (context) => const RegisterScreen(),
          RoutesEnum.home.route: (context) => const HomeScreen(),

          RoutesEnum.chatList.route: (context) => const ChatListPage(),
          RoutesEnum.newChat.route: (context) => const NewChatScreen(),
          RoutesEnum.chatPage.route: (context) => const ChatPage(),
        },
        initialRoute: RoutesEnum.login.route,
      ),
    );
  }
}