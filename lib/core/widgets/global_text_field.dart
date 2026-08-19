import 'package:flutter/material.dart';
import 'package:nutq/core/extensions/theme_extension.dart';

class GlobalTextField extends StatelessWidget {
  final String hintText;
  final TextInputType textInputType;
  final TextEditingController? controller;
  final bool obscureText;
  final Widget? suffixWidget;
  final String? Function(String?) validator;

  const GlobalTextField({
    super.key,
    required this.hintText,
    required this.textInputType,
    this.controller,
    this.obscureText = false,
    this.suffixWidget,
    required this.validator,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return TextFormField(
      controller: controller,
      keyboardType: textInputType,
      obscureText: obscureText,
      validator: validator,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      decoration: InputDecoration(
        filled: true,
        fillColor: colors.card,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colors.borderDefault),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colors.borderDefault),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colors.borderDefault, width: 2),
        ),
        hintText: hintText,
        hintStyle: context.typography.bodyBase.copyWith(
          color: context.appColors.textMuted,
        ),
        suffixIcon: Padding(
          padding: EdgeInsets.only(top: 12),
          child: suffixWidget,
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }
}
