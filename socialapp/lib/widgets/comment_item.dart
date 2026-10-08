import 'package:flutter/material.dart';
import '../models/comment_model.dart';
import '../utils/app_colors.dart';

class CommentItem extends StatelessWidget {
  final CommentModel comment;
  final VoidCallback? onDelete;

  const CommentItem({super.key, required this.comment, this.onDelete});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(comment.userName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
      subtitle: Text(comment.comment, style: const TextStyle(fontSize: 14, color: AppColors.textPrimary)),
      trailing: onDelete != null
          ? IconButton(
              icon: const Icon(Icons.delete, size: 18, color: AppColors.error),
              onPressed: onDelete,
            )
          : null,
    );
  }
}