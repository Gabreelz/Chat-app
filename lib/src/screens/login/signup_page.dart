import 'package:chat_app/src/models/registerViewModel.dart';
import 'package:chat_app/src/widgets/custom_button.dart';
import 'package:chat_app/src/widgets/custom_input.dart';
import 'package:chat_app/src/widgets/custom_input.dart.dart';
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
    viewModel.initToast(context);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F5FF),
      body: SingleChildScrollView(
        child: Center(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: SizedBox(
                    width:
                        constraints.maxWidth > 768 ? 768 : constraints.maxWidth,
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

  @override
  Widget build(BuildContext context) {
    return Form(
      key: widget.viewModel.formKey,
      child: Column(
        spacing: 4,
        children: [
          // Logo
          const Image(
            image: AssetImage('assets/logos/logo_login.png'),
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
                color: Color(0xFF2E2E2E),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Email
          CustomInput(
            hint: 'Digite seu email',
            label: 'Email',
            controller: widget.viewModel.emailController,
            keyboardType: TextInputType.emailAddress,
            validator: (value) => widget.viewModel.emailValidator(value),
          ),
          const SizedBox(height: 18),

          // Nome
          CustomInput(
            hint: 'Digite seu nome completo',
            label: 'Nome',
            controller: widget.viewModel.fullNameController,
            validator: (value) => widget.viewModel.fullNameValidator(value),
          ),
          const SizedBox(height: 18),

          // Senha com olhinho
          CustomInput(
            hint: 'Digite sua senha',
            label: 'Senha',
            controller: widget.viewModel.passwordController,
            obscureText: _obscurePassword,
            validator: (value) => widget.viewModel.passwordValidator(value),
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword ? Icons.visibility_off : Icons.visibility,
                color: Colors.grey[700],
              ),
              onPressed: () {
                setState(() {
                  _obscurePassword = !_obscurePassword;
                });
              },
            ),
          ),
          const SizedBox(height: 18),

          // Confirmação da senha com olhinho
          CustomInput(
            hint: 'Confirme sua senha',
            label: 'Confirmação da senha',
            controller: widget.viewModel.passwordConfirmationController,
            obscureText: _obscureConfirmPassword,
            validator: (value) =>
                widget.viewModel.passwordConfirmationValidator(value),
            suffixIcon: IconButton(
              icon: Icon(
                _obscureConfirmPassword
                    ? Icons.visibility_off
                    : Icons.visibility,
                color: Colors.grey[700],
              ),
              onPressed: () {
                setState(() {
                  _obscureConfirmPassword = !_obscureConfirmPassword;
                });
              },
            ),
          ),
          const SizedBox(height: 24),

          // Botão Registrar
          CustomButton(
            icon: widget.viewModel.isLoading ? Icons.hourglass_empty : null,
            buttonText:
                widget.viewModel.isLoading ? 'Registrando...' : 'Registrar',
            backgroundColor: const Color(0xFF03A9F4),
            buttonAction: widget.viewModel.isLoading
                ? null
                : () async => widget.viewModel.registerButtonAction(context),
          ),
          const SizedBox(height: 12),

          // Botão para login
          CustomTextButton(
            icon: Icons.login,
            buttonText: 'Já tem uma conta? Faça login',
            buttonAction: () => widget.viewModel.navigateToLogin(
              Navigator.of(context),
            ),
          ),
        ],
      ),
    );
  }
}
