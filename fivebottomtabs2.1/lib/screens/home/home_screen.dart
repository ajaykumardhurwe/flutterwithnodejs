import 'package:flutter/material.dart';

import '../../models/post_model.dart';
import '../../models/user_model.dart';
import '../../services/api_service.dart';
import '../../services/storage_service.dart';
import '../../utils/app_colors.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/post_card.dart';
import '../auth/login_screen.dart';
import '../post/create_post_screen.dart';
import '../profile/profile_screen.dart';
import '../jobs/jobs_screen.dart';




class HomeScreen extends StatefulWidget {
  final UserModel user;
  const HomeScreen({super.key, required this.user});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _index = 0;
  List<PostModel> _posts = [];
  bool _loading = true;
  String? _error;
  final TextEditingController _search = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadPosts();
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _loadPosts() async {
    if (mounted) {
      setState(() {
        _loading = true;
        _error = null;
      });
    }
    try {
      final posts = await ApiService.instance.getPosts();
      if (mounted) setState(() => _posts = posts);
    } catch (e) {
      if (mounted) setState(() => _error = '$e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _create() async {
    final created = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const CreatePostScreen()),
    );
    if (created == true) {
      setState(() => _index = 0);
      await _loadPosts();
    }
  }

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      _feed(),
      _searchPage(),
      _activityPage(),
      const JobScreen(),
      ProfileScreen(user: widget.user, onLogout: _logout),
    ];

    // final pageIndex = _index > 2 ? _index - 1 : _index;
    final pageIndex = _index > 2 ? _index - 1 : _index;
    return Scaffold(
      appBar: _index == 2
          ? null
          : AppBar(
              title: Row(
                children: [
                  const Text(
                    'Socially',
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(width: 7),
                  Container(
                    width: 7,
                    height: 7,
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ),
              actions: [
                if (_index == 0)
                  IconButton(
                    tooltip: 'Refresh feed',
                    onPressed: _loadPosts,
                    icon: const Icon(Icons.refresh_rounded),
                  ),
                IconButton(
                  tooltip: 'Create post',
                  onPressed: _create,
                  icon: const Icon(Icons.edit_square),
                ),
              ],
            ),
      body: _index == 2
          ? CreatePostScreen(
              onCreated: () {
                setState(() => _index = 0);
                _loadPosts();
              },
            )
          : IndexedStack(index: pageIndex, children: pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (index) {
          if (index == 2) {
            _create();
          } else {
            setState(() => _index = index);
          }
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.search_rounded),
            label: 'Search',
          ),
          NavigationDestination(
            icon: Icon(Icons.add_box_outlined),
            selectedIcon: Icon(Icons.add_box_rounded),
            label: 'Create',
          ),
          NavigationDestination(
            icon: Icon(Icons.favorite_border_rounded),
            selectedIcon: Icon(Icons.favorite_rounded),
            label: 'Activity',
          ),

          NavigationDestination(
            icon: Icon(Icons.work_outline_rounded),
            selectedIcon: Icon(Icons.work_rounded),
            label: 'Jobs'
          ),
          // NavigationDestination(
          //  icon: Icon(Icons.video_library_outlined),
          //  selectedIcon: Icon(Icons.video_library_rounded),
          //  label: 'Reels',
          // ),
          NavigationDestination(
            icon: Icon(Icons.person_outline_rounded),
            selectedIcon: Icon(Icons.person_rounded),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  Widget _feed() {
    if (_loading) {
      return const LoadingWidget(message: 'Loading your feed...');
    }
    if (_error != null) {
      return ListView(
        children: [
          const SizedBox(height: 100),
          const Icon(Icons.cloud_off_outlined, size: 52),
          const SizedBox(height: 12),
          Center(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Could not load posts.\n$_error',
                textAlign: TextAlign.center,
              ),
            ),
          ),
          Center(
            child: FilledButton.icon(
              onPressed: _loadPosts,
              icon: const Icon(Icons.refresh),
              label: const Text('Try again'),
            ),
          ),
        ],
      );
    }
    if (_posts.isEmpty) {
      return ListView(
        children: [
          const SizedBox(height: 80),
          Icon(
            Icons.forum_outlined,
            size: 60,
            color: Theme.of(context).hintColor,
          ),
          const SizedBox(height: 12),
          const Center(child: Text('Your feed is quiet')),
          const SizedBox(height: 6),
          Center(
            child: Text(
              'Be the first to share something.',
              style: TextStyle(color: Theme.of(context).hintColor),
            ),
          ),
          const SizedBox(height: 18),
          Center(
            child: FilledButton.icon(
              onPressed: _create,
              icon: const Icon(Icons.add),
              label: const Text('Create a post'),
            ),
          ),
        ],
      );
    }
    return RefreshIndicator(
      onRefresh: _loadPosts,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
        children: [
          _welcomeCard(),
          const SizedBox(height: 14),
          ..._posts.map(
            (post) => Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: PostCard(
                post: post,
                currentUserId: widget.user.id,
                onChanged: _loadPosts,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _welcomeCard() {
    final name = widget.user.name.trim().split(' ').first;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.secondary],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hey, $name 👋',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 5),
                const Text(
                  'What’s happening in your world?',
                  style: TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white54),
                  ),
                  onPressed: _create,
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Write a post'),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          const Icon(
            Icons.auto_awesome_rounded,
            color: Colors.white70,
            size: 56,
          ),
        ],
      ),
    );
  }

  Widget _searchPage() {
    final query = _search.text.toLowerCase().trim();
    final filtered = _posts.where((post) {
      return post.content.toLowerCase().contains(query) ||
          post.author.name.toLowerCase().contains(query);
    }).toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            controller: _search,
            onChanged: (_) => setState(() {}),
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.search),
              hintText: 'Search posts or people',
            ),
          ),
        ),
        Expanded(
          child: query.isEmpty
              ? Center(
                  child: Text(
                    'Search posts and people',
                    style: TextStyle(color: Theme.of(context).hintColor),
                  ),
                )
              : filtered.isEmpty
                  ? const Center(child: Text('No results found'))
                  : ListView(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      children: filtered
                          .map(
                            (post) => Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: PostCard(
                                post: post,
                                currentUserId: widget.user.id,
                                onChanged: _loadPosts,
                              ),
                            ),
                          )
                          .toList(),
                    ),
        ),
      ],
    );
  }

  // Widget _activityPage() {
  //   return Center(
  //     child: Padding(
  //       padding: const EdgeInsets.all(28),
  //       child: Column(
  //         mainAxisSize: MainAxisSize.min,
  //         children: [
  //           Icon(
  //             Icons.notifications_none_rounded,
  //             size: 58,
  //             color: Theme.of(context).hintColor,
  //           ),
  //           const SizedBox(height: 12),
  //           const Text(
  //             'You’re all caught up',
  //             style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800),
  //           ),
  //           const SizedBox(height: 6),
  //           Text(
  //             'New activity will show up here.',
  //             style: TextStyle(color: Theme.of(context).hintColor),
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }



  Widget _activityPage() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.notifications_none_rounded,
              size: 58,
              color: Theme.of(context).hintColor,
            ),
            const SizedBox(height: 12),
            const Text(
              'You’re all caught up',
              style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 6),
            Text(
              'New activity will show up here.',
              style: TextStyle(color: Theme.of(context).hintColor),
            ),
          ],
        ),
      ),
    );
  }




  Future<void> _logout() async {
    await StorageService().clearUser();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (_) => false,
    );
  }
}
