import 'package:flutter/material.dart';
import '../../models/post_model.dart';
import '../../models/comment_model.dart';
import '../../services/api_service.dart';
import '../../widgets/comment_item.dart';
import '../../widgets/loading_widget.dart';

class PostDetailScreen extends StatefulWidget {
  const PostDetailScreen({super.key});

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  PostModel? _post;
  List<CommentModel> _comments = [];
  bool _isLoading = true;
  final _commentController = TextEditingController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final postId = ModalRoute.of(context)!.settings.arguments as int;
    _loadData(postId);
  }

  void _loadData(int postId) async {
    final post = await ApiService().getPostById(postId);
    final comments = await ApiService().getComments(postId);
    setState(() {
      _post = post;
      _comments = comments;
      _isLoading = false;
    });
  }

  void _addComment() async {
    if (_commentController.text.trim().isEmpty || _post == null) return;
    final success = await ApiService().addComment(_post!.id, _commentController.text);
    if (success) {
      _commentController.clear();
      _loadData(_post!.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Scaffold(body: LoadingWidget());

    return Scaffold(
      appBar: AppBar(title: const Text('Post')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(_post!.content, style: const TextStyle(fontSize: 18)),
          ),
          const Divider(),
          Expanded(
            child: ListView.builder(
              itemCount: _comments.length,
              itemBuilder: (ctx, idx) => CommentItem(comment: _comments[idx]),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    decoration: const InputDecoration(hintText: 'Add a comment...'),
                  ),
                ),
                IconButton(icon: const Icon(Icons.send), onPressed: _addComment),
              ],
            ),
          ),
        ],
      ),
    );
  }
}