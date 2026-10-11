import 'package:flutter/material.dart';
import 'package:nutq/core/extensions/theme_extension.dart';

class GlobalTextField extends StatelessWidget {
  final String hintText;
  final TextInputType textInputType;
  final TextEditingController? controller;
  final bool obscureText;
  final Widget? prefixWidget;
  final Widget? suffixWidget;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;

  const GlobalTextField({
    super.key,
    required this.hintText,
    required this.textInputType,
    this.controller,
    this.obscureText = false,
    this.prefixWidget,
    this.suffixWidget,
    this.validator,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return TextFormField(
      controller: controller,
      keyboardType: textInputType,
      obscureText: obscureText,
      validator: validator,
      onChanged: onChanged,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      decoration: InputDecoration(
        filled: true,
        fillColor: colors.surface,
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
        prefixIcon: prefixWidget,
        suffixIcon: suffixWidget == null
            ? null
            : Padding(padding: EdgeInsets.only(top: 12), child: suffixWidget),
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }
}
