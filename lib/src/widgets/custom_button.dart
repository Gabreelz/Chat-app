import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  /// Cor de fundo do botão
  final Color backgroundColor;

  final String buttonText;

  final VoidCallback? buttonAction;

  final IconData? icon;

  /// Construtor da classe [CustomButton]
  const CustomButton({
    super.key,
    required this.backgroundColor,
    required this.buttonText,
    required this.buttonAction,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      width: double.infinity,
      child: ElevatedButton.icon(
        icon: icon != null
            ? Icon(icon, color: Colors.white)
            : const SizedBox.shrink(),
        label: Text(
          buttonText,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        style: ButtonStyle(
          backgroundColor: MaterialStatePropertyAll(
            buttonAction == null
                ? backgroundColor.withOpacity(0.6) // botão desabilitado
                : backgroundColor,
          ),
          shape: MaterialStatePropertyAll(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          elevation: const MaterialStatePropertyAll(3),
        ),
        onPressed: buttonAction,
      ),
    );
  }
}
