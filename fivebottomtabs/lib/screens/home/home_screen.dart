import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../services/storage_service.dart';
import '../../models/post_model.dart';
import '../../utils/app_routes.dart';
import '../../widgets/post_card.dart';
import '../../widgets/loading_widget.dart';
import '../profile/profile_screen.dart';

class HomeScreen extends StatefulWidget {
  final Function(bool)? onThemeChanged;
  const HomeScreen({super.key, this.onThemeChanged});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  int? currentUserId;
  bool isDark = false;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  void _loadUser() async {
    final id = await StorageService.getUserId();
    final dark = await StorageService.getThemeMode();
    setState(() {
      currentUserId = id;
      isDark = dark;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> tabs = [
      const FeedTab(),
      const ExploreTab(),
      const NotificationsTab(),
      const MessagesTab(),
      ProfileScreen(
        onThemeChanged: (val) {
          setState(() => isDark = val);
        },
      ),
    ];

    return Scaffold(
      body: tabs[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) => setState(() => _currentIndex = index),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Feed'),
          NavigationDestination(icon: Icon(Icons.explore_outlined), selectedIcon: Icon(Icons.explore), label: 'Explore'),
          NavigationDestination(icon: Icon(Icons.notifications_outlined), selectedIcon: Icon(Icons.notifications), label: 'Alerts'),
          NavigationDestination(icon: Icon(Icons.chat_bubble_outline), selectedIcon: Icon(Icons.chat_bubble), label: 'Messages'),
          NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}

// Tab 1: Feed Tab with Post List & Create Shortcut
class FeedTab extends StatefulWidget {
  const FeedTab({super.key});

  @override
  State<FeedTab> createState() => _FeedTabState();
}

class _FeedTabState extends State<FeedTab> {
  late Future<List<PostModel>> _postsFuture;
  int? currentUserId;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  void _fetchData() async {
    currentUserId = await StorageService.getUserId();
    setState(() {
      _postsFuture = ApiService.getPosts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Social Feed', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_box_outlined),
            onPressed: () async {
              await Navigator.pushNamed(context, AppRoutes.createPost);
              _fetchData();
            },
          ),
        ],
      ),
      body: FutureBuilder<List<PostModel>>(
        future: _postsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const LoadingWidget();
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No posts found. Be the first to post!'));
          }
          final posts = snapshot.data!;
          return RefreshIndicator(
            onRefresh: () async => _fetchData(),
            child: ListView.builder(
              itemCount: posts.length,
              itemBuilder: (context, index) {
                final post = posts[index];
                return PostCard(
                  post: post,
                  isOwner: post.userId == currentUserId,
                  onTap: () async {
                    await Navigator.pushNamed(context, AppRoutes.postDetail, arguments: post.id);
                    _fetchData();
                  },
                  onLikeToggle: () async {
                    await ApiService.toggleLike(post.id, post.isLiked);
                    _fetchData();
                  },
                  onDelete: post.userId == currentUserId
                      ? () async {
                          await ApiService.deletePost(post.id);
                          _fetchData();
                        }
                      : null,
                );
              },
            ),
          );
        },
      ),
    );
  }
}

// Tab 2: Explore Tab
class ExploreTab extends StatelessWidget {
  const ExploreTab({super.key});
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('Explore Trending Posts & Tags', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500))),
    );
  }
}

// Tab 3: Notifications Tab
class NotificationsTab extends StatelessWidget {
  const NotificationsTab({super.key});
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('No new notifications', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500))),
    );
  }
}

// Tab 4: Messages Tab
class MessagesTab extends StatelessWidget {
  const MessagesTab({super.key});
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('Direct Messages', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500))),
    );
  }
}