import 'package:flutter/material.dart';
class LoadingWidget extends StatelessWidget {
  final String message;
  const LoadingWidget({super.key, this.message = 'Loading...'});
  @override Widget build(BuildContext context) => Center(child: Padding(padding: const EdgeInsets.all(28), child: Column(
    mainAxisSize: MainAxisSize.min, children: [const CircularProgressIndicator(), const SizedBox(height: 14), Text(message)])));
}
