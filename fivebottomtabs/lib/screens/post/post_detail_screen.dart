import 'package:flutter/material.dart';
import '../../models/post_model.dart';
import '../../models/comment_model.dart';
import '../../services/api_service.dart';
import '../../services/storage_service.dart';
import '../../widgets/comment_item.dart';
import '../../widgets/loading_widget.dart';

class PostDetailScreen extends StatefulWidget {
  final int postId;
  const PostDetailScreen({super.key, required this.postId});

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  late Future<PostModel> _postFuture;
  late Future<List<CommentModel>> _commentsFuture;
  final _commentController = TextEditingController();
  int? currentUserId;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() async {
    currentUserId = await StorageService.getUserId();
    setState(() {
      _postFuture = ApiService.getPostById(widget.postId);
      _commentsFuture = ApiService.getComments(widget.postId);
    });
  }

  void _addComment() async {
    if (_commentController.text.trim().isEmpty) return;
    await ApiService.addComment(widget.postId, _commentController.text.trim());
    _commentController.clear();
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Post Details')),
      body: Column(
        children: [
          Expanded(
            child: FutureBuilder<PostModel>(
              future: _postFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const LoadingWidget();
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData) {
                  return const Center(child: Text('Post not found'));
                }
                final post = snapshot.data!;
                return ListView(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(post.userName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          const SizedBox(height: 8),
                          Text(post.content, style: const TextStyle(fontSize: 16)),
                        ],
                      ),
                    ),
                    const Divider(),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
                      child: Text('Comments', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    ),
                    FutureBuilder<List<CommentModel>>(
                      future: _commentsFuture,
                      builder: (context, commentSnapshot) {
                        if (commentSnapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        } else if (!commentSnapshot.hasData || commentSnapshot.data!.isEmpty) {
                          return const Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Center(child: Text('No comments yet. Start the conversation!')),
                          );
                        }
                        final comments = commentSnapshot.data!;
                        return ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: comments.length,
                          itemBuilder: (context, index) {
                            final comment = comments[index];
                            return CommentItem(
                              comment: comment,
                              isOwner: comment.userId == currentUserId,
                              onDelete: comment.userId == currentUserId
                                  ? () async {
                                      await ApiService.deleteComment(comment.id);
                                      _loadData();
                                    }
                                  : null,
                            );
                          },
                        );
                      },
                    ),
                  ],
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    decoration: const InputDecoration(
                      hintText: 'Write a comment...',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send, color: Colors.indigo),
                  onPressed: _addComment,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}