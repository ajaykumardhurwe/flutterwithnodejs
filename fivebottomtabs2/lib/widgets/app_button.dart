import 'package:flutter/material.dart';
class AppButton extends StatelessWidget {
  final String label; final VoidCallback? onPressed; final bool loading; final IconData? icon;
  const AppButton({super.key, required this.label, required this.onPressed, this.loading = false, this.icon});
  @override Widget build(BuildContext context) => SizedBox(width: double.infinity, child: FilledButton(
    onPressed: loading ? null : onPressed,
    child: loading ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) :
      Row(mainAxisAlignment: MainAxisAlignment.center, mainAxisSize: MainAxisSize.min, children: [if (icon != null) ...[Icon(icon, size: 18), const SizedBox(width: 8)], Text(label, style: const TextStyle(fontWeight: FontWeight.w700))]),
  ));
}
