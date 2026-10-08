import 'package:flutter/material.dart';
import '../models/post_model.dart';
import '../utils/app_colors.dart';

class PostCard extends StatelessWidget {
  final PostModel post;
  final VoidCallback onTap;
  final VoidCallback onLike;
  final VoidCallback? onDelete;

  const PostCard({
    super.key,
    required this.post,
    required this.onTap,
    required this.onLike,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(post.userName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  if (onDelete != null)
                    IconButton(
                      icon: const Icon(Icons.delete_outline, size: 20, color: AppColors.textSecondary),
                      onPressed: onDelete,
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Text(post.content, style: const TextStyle(fontSize: 15)),
              const SizedBox(height: 12),
              Row(
                children: [
                  IconButton(
                    icon: Icon(
                      post.isLiked ? Icons.favorite : Icons.favorite_border,
                      color: post.isLiked ? AppColors.likeRed : AppColors.textSecondary,
                    ),
                    onPressed: onLike,
                  ),
                  Text('${post.likesCount}'),
                  const SizedBox(width: 24),
                  const Icon(Icons.chat_bubble_outline, size: 20, color: AppColors.textSecondary),
                  const SizedBox(width: 6),
                  Text('${post.commentsCount}'),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}