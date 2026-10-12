import 'package:flutter/material.dart';
class AppTextField extends StatelessWidget {
  final TextEditingController controller; final String label; final IconData icon; final bool obscureText;
  final TextInputType? keyboardType; final String? Function(String?)? validator; final int maxLines;
  const AppTextField({super.key, required this.controller, required this.label, required this.icon,
    this.obscureText = false, this.keyboardType, this.validator, this.maxLines = 1});
  @override Widget build(BuildContext context) => TextFormField(controller: controller, obscureText: obscureText,
    keyboardType: keyboardType, validator: validator, maxLines: obscureText ? 1 : maxLines,
    decoration: InputDecoration(labelText: label, prefixIcon: Icon(icon)));
}
