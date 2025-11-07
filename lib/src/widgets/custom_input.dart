import 'package:flutter/material.dart';

/// Campo de entrada customizado reutilizável
class CustomInput extends StatelessWidget {
  /// Rótulo exibido acima do campo
  final String label;

  /// Texto de dica exibido dentro do campo
  final String hint;

  /// Controlador do campo de entrada
  final TextEditingController controller;

  /// Função de validação (opcional)
  final String? Function(String?)? validator;

  /// Indica se o texto deve ser ocultado (para senhas)
  final bool obscureText;

  /// Ícone à direita (ex: olhinho)
  final Widget? suffixIcon;

  /// Tipo de teclado (email, texto, número, etc.)
  final TextInputType? keyboardType;

  const CustomInput({
    super.key,
    required this.label,
    required this.hint,
    required this.controller,
    this.validator,
    this.obscureText = false,
    this.suffixIcon,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: controller,
      builder: (context, value, child) {
        final bool isEmpty = value.text.isEmpty;

        return SizedBox(
          height: 68,
          child: TextFormField(
            controller: controller,
            validator: validator,
            obscureText: obscureText,
            keyboardType: keyboardType,
            decoration: InputDecoration(
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: isEmpty ? Colors.grey : Colors.blue,
                  width: 2,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Colors.blue, width: 2.5),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Colors.red, width: 2.5),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Colors.red, width: 2.5),
              ),
              labelText: label,
              hintText: hint,
              suffixIcon: suffixIcon, // ✅ agora existe
              fillColor: Colors.white,
              filled: true,
            ),
          ),
        );
      },
    );
  }
}
