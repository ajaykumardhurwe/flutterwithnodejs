import 'package:flutter/material.dart';
import '../models/comment_model.dart';
class CommentItem extends StatelessWidget {
  final CommentModel comment; final bool canDelete; final VoidCallback? onDelete;
  const CommentItem({super.key, required this.comment, this.canDelete = false, this.onDelete});
  @override Widget build(BuildContext context) => Padding(padding: const EdgeInsets.symmetric(vertical: 10), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
    CircleAvatar(radius: 18, backgroundColor: Theme.of(context).colorScheme.primaryContainer, child: Text(comment.userName.isEmpty ? '?' : comment.userName[0].toUpperCase())),
    const SizedBox(width: 10), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(comment.userName, style: const TextStyle(fontWeight: FontWeight.w700)), const SizedBox(height: 3), Text(comment.comment)])),
    if (canDelete) IconButton(visualDensity: VisualDensity.compact, icon: const Icon(Icons.delete_outline, size: 19), onPressed: onDelete),
  ]));
}
