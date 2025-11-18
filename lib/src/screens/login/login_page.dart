import 'package:chat_app/src/utils/routes_enum.dart';
import 'package:chat_app/src/widgets/custom_button.dart';
import 'package:chat_app/src/widgets/custom_input.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;

  Future<void> _signIn(BuildContext context) async {
    final supabase = Supabase.instance.client;
    setState(() => _isLoading = true);

    try {
      final response = await supabase.auth.signInWithPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      if (response.user != null && mounted) {
        Navigator.pushNamed(context, RoutesEnum.chatList.route);
      } else {
        _showError('Usuário ou senha inválidos.');
      }
    } catch (e) {
      _showError('Erro ao entrar: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.redAccent),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo do app
                Image.asset('assets/icons/logoP.png', height: 180),

                const SizedBox(height: 24),

                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Login',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2E2E2E),
                    ),
                  ),
                ),
                const SizedBox(height: 18),

                // Campo de email
                CustomInput(
                  hint: 'Digite seu email',
                  label: 'Email',
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 18),

                // Campo de senha com "olhinho"
                CustomInput(
                  hint: 'Digite sua senha',
                  label: 'Senha',
                  controller: passwordController,
                  obscureText: _obscurePassword,
                  suffixIcon: GestureDetector(
                    onTap: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Image.asset(
                        _obscurePassword
                            ? 'assets/icons/olhoR.png'
                            : 'assets/icons/olho.png',
                        width: 24,
                        height: 24,
                      ),
                    ),
                  ),
                ),

                // Botão de login
                CustomButton(
                  buttonText: _isLoading ? 'Entrando...' : 'Entrar',
                  backgroundColor: const Color(0xFF03A9F4),
                  buttonAction: _isLoading ? null : () => _signIn(context),
                ),

                const SizedBox(height: 24),

                // Link para cadastro
                GestureDetector(
                  onTap: () =>
                      Navigator.pushNamed(context, RoutesEnum.register.route),
                  child: const Text(
                    'Não tem uma conta? Cadastre-se',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF1565C0),
                      fontWeight: FontWeight.w500,
                      decoration: TextDecoration.none,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
