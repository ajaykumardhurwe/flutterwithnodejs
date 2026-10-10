import 'package:flutter/material.dart';
import '../models/post_model.dart';
import '../utils/app_colors.dart';

class PostCard extends StatelessWidget {
  final PostModel post;
  final VoidCallback onTap;
  final VoidCallback onLikeToggle;
  final VoidCallback? onDelete;
  final bool isOwner;

  const PostCard({
    super.key,
    required this.post,
    required this.onTap,
    required this.onLikeToggle,
    this.onDelete,
    this.isOwner = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: AppColors.primary.withOpacity(0.2),
                    child: Text(post.userName.isNotEmpty ? post.userName[0].toUpperCase() : 'U',
                        style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(post.userName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        Text(post.createdAt.split('T')[0], style: TextStyle(fontSize: 12, color: theme.hintColor)),
                      ],
                    ),
                  ),
                  if (isOwner && onDelete != null)
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: AppColors.error),
                      onPressed: onDelete,
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Text(post.content, style: const TextStyle(fontSize: 15, height: 1.4)),
              const SizedBox(height: 16),
              const Divider(height: 1),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  TextButton.icon(
                    onPressed: onLikeToggle,
                    icon: Icon(
                      post.isLiked ? Icons.favorite : Icons.favorite_border,
                      color: post.isLiked ? AppColors.likeRed : theme.hintColor,
                    ),
                    label: Text('${post.likesCount}',
                        style: TextStyle(color: post.isLiked ? AppColors.likeRed : theme.hintColor)),
                  ),
                  TextButton.icon(
                    onPressed: onTap,
                    icon: Icon(Icons.chat_bubble_outline, color: theme.hintColor),
                    label: Text('${post.commentsCount}', style: TextStyle(color: theme.hintColor)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}