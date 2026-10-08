import 'package:flutter/material.dart';
import '../../models/post_model.dart';
import '../../services/api_service.dart';
import '../../utils/app_routes.dart';
import '../../widgets/post_card.dart';
import '../../widgets/loading_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<PostModel> _posts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchPosts();
  }

  Future<void> _fetchPosts() async {
    try {
      final posts = await ApiService().getPosts();
      setState(() {
        _posts = posts;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  void _handleLike(PostModel post) async {
    final updatedState = !post.isLiked;
    setState(() {
      post.isLiked = updatedState;
      post.likesCount += updatedState ? 1 : -1;
    });
    await ApiService().toggleLike(post.id, !updatedState);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Feed'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () => Navigator.pushNamed(context, AppRoutes.profile),
          ),
        ],
      ),
      body: _isLoading
          ? const LoadingWidget()
          : RefreshIndicator(
              onRefresh: _fetchPosts,
              child: ListView.builder(
                itemCount: _posts.length,
                itemBuilder: (ctx, index) {
                  final post = _posts[index];
                  return PostCard(
                    post: post,
                    onTap: () => Navigator.pushNamed(context, AppRoutes.postDetail, arguments: post.id),
                    onLike: () => _handleLike(post),
                  );
                },
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.pushNamed(context, AppRoutes.createPost);
          _fetchPosts();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}