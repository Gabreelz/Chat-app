import 'package:chat_app/src/models/registerViewModel.dart';
import 'package:chat_app/src/widgets/custom_button.dart';
import 'package:chat_app/src/widgets/custom_input.dart';
import 'package:chat_app/src/widgets/custom_text_button.dart';
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

          CustomInput(
            hint: 'Digite sua senha',
            label: 'Senha',
            controller: widget.viewModel.passwordController,
            obscureText: _obscurePassword,
            validator: (value) => widget.viewModel.passwordValidator(value),
            suffixIcon: IconButton(
              onPressed: () {
                setState(() {
                  _obscurePassword = !_obscurePassword;
                });
              },
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
            controller: widget.viewModel.passwordConfirmationController,
            obscureText: _obscureConfirmPassword,
            validator: (value) =>
                widget.viewModel.passwordConfirmationValidator(value),
            suffixIcon: IconButton(
              onPressed: () {
                setState(() {
                  _obscureConfirmPassword = !_obscureConfirmPassword;
                });
              },
              icon: Image.asset(
                _obscureConfirmPassword
                    ? 'assets/icons/olhoR.png'
                    : 'assets/icons/olho.png',
                width: 22,
                height: 22,
              ),
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
