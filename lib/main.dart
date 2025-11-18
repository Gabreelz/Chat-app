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
import 'package:chat_app/src/provaders/chat_list_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://kemvtrpjylxbqmjqzdhu.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImtlbXZ0cnBqeWx4YnFtanF6ZGh1Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjI3MTY5MTEsImV4cCI6MjA3ODI5MjkxMX0.f338krfDv7L5VJ4rK21XH_MWFpN7pfFWxKT8Xr1EUsk',
  );

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ChatProvider()),
        ChangeNotifierProvider(create: (_) => NewChatProvider()),
        ChangeNotifierProvider(create: (_) => ChatListProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        builder: FToastBuilder(),

        // ⭐ Aqui está o dark mode automático
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system, // Segue o modo do sistema/navegador

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
