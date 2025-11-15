import 'package:flutter/material.dart';

class CustomTextButton extends StatelessWidget {
  const CustomTextButton({
    required this.buttonText,
    required this.buttonAction,
    Key? key,
    this.icon,
  }) : super(key: key);

  /// Texto exibido no botão
  final String buttonText;

  /// Ação ao clicar no botão
  final VoidCallback? buttonAction;

  /// Ícone opcional ao lado do texto
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: buttonAction,
      icon: Icon(
        icon,
        color: const Color(0xFF0F4888),
      ),
      label: Text(
        buttonText,
        style: const TextStyle(color: Color(0xFF0F4888)),
      ),
    );
  }
}
