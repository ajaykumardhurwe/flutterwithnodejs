import 'package:flutter/material.dart';
import '../models/comment_model.dart';
import '../utils/app_colors.dart';

class CommentItem extends StatelessWidget {
  final CommentModel comment;
  final VoidCallback? onDelete;
  final bool isOwner;

  const CommentItem({super.key, required this.comment, this.onDelete, this.isOwner = false});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.dividerColor, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(comment.userName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              if (isOwner && onDelete != null)
                InkWell(
                  onTap: onDelete,
                  child: const Icon(Icons.close, size: 16, color: AppColors.error),
                ),
            ],
          ),
          const SizedBox(height: 6),
          Text(comment.comment, style: const TextStyle(fontSize: 14)),
        ],
      ),
    );
  }
}