import 'package:chat_app/src/models/registerViewModel.dart';
import 'package:chat_app/src/widgets/custom_button.dart';
import 'package:chat_app/src/widgets/custom_input.dart';
import 'package:flutter/material.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final RegisterViewModel viewModel = RegisterViewModel();

  @override
  void initState() {
    super.initState();
    viewModel.initToast(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Center(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: SizedBox(
                    child: FormWidget(viewModel: viewModel),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class FormWidget extends StatefulWidget {
  const FormWidget({required this.viewModel, super.key});
  final RegisterViewModel viewModel;

  @override
  State<FormWidget> createState() => _FormWidgetState();
}

class _FormWidgetState extends State<FormWidget> {
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  // Hover Animation
  bool _hoverLogin = false;

  @override
  Widget build(BuildContext context) {
    final vm = widget.viewModel;

    return Form(
      key: vm.formKey,
      child: Column(
        spacing: 4,
        children: [
          const Image(
            image: AssetImage('assets/icons/logoP.png'),
            height: 220,
          ),

          const SizedBox(height: 8),

          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Registro',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          const SizedBox(height: 12),

          // EMAIL
          CustomInput(
            hint: 'Digite seu email',
            label: 'Email',
            controller: vm.emailController,
            keyboardType: TextInputType.emailAddress,
            validator: vm.emailValidator,
          ),
          const SizedBox(height: 18),

          // NOME
          CustomInput(
            hint: 'Digite seu nome completo',
            label: 'Nome',
            controller: vm.fullNameController,
            validator: vm.fullNameValidator,
          ),
          const SizedBox(height: 18),

          // SENHA
          CustomInput(
            hint: 'Digite sua senha',
            label: 'Senha',
            controller: vm.passwordController,
            obscureText: _obscurePassword,
            validator: vm.passwordValidator,
            suffixIcon: IconButton(
              onPressed: () =>
                  setState(() => _obscurePassword = !_obscurePassword),
              icon: Image.asset(
                _obscurePassword
                    ? 'assets/icons/olhoR.png'
                    : 'assets/icons/olho.png',
                width: 22,
                height: 22,
              ),
            ),
          ),
          const SizedBox(height: 18),

          CustomInput(
            hint: 'Confirme sua senha',
            label: 'Confirmação da senha',
            controller: vm.passwordConfirmationController,
            obscureText: _obscureConfirmPassword,
            validator: vm.passwordConfirmationValidator,
            suffixIcon: IconButton(
              onPressed: () => setState(
                  () => _obscureConfirmPassword = !_obscureConfirmPassword),
              icon: Image.asset(
                _obscureConfirmPassword
                    ? 'assets/icons/olhoR.png'
                    : 'assets/icons/olho.png',
                width: 22,
                height: 22,
              ),
            ),
          ),

          const SizedBox(height: 28),

          // BOTÃO REGISTRAR
          CustomButton(
            icon: vm.isLoading ? Icons.hourglass_empty : null,
            buttonText: vm.isLoading ? 'Registrando...' : 'Registrar',
            backgroundColor: const Color(0xFF03A9F4),
            buttonAction:
                vm.isLoading ? null : () => vm.registerButtonAction(context),
          ),

          const SizedBox(height: 16),

          // -----------------------------------------
          // LINK ANIMADO "Já tem uma conta? Faça login"
          // -----------------------------------------
          MouseRegion(
            onEnter: (_) => setState(() => _hoverLogin = true),
            onExit: (_) => setState(() => _hoverLogin = false),
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: () => vm.navigateToLogin(Navigator.of(context)),
              child: Column(
                children: [
                  AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 180),
                    curve: Curves.easeOut,
                    style: TextStyle(
                      fontSize: _hoverLogin ? 15 : 14,
                      color: _hoverLogin
                          ? const Color(0xFF0D47A1)
                          : const Color(0xFF1565C0),
                      fontWeight: FontWeight.w600,
                      decoration: TextDecoration.none,
                    ),
                    child: const Text('Já tem uma conta? Faça login'),
                  ),
                  const SizedBox(height: 2),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    curve: Curves.easeOut,
                    height: 2,
                    width: _hoverLogin ? 140 : 0,
                    color: const Color(0xFF0D47A1),
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
