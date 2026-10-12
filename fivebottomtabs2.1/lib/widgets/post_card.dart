import 'package:flutter/material.dart';
import '../models/post_model.dart';
import '../services/api_service.dart';
import '../utils/app_colors.dart';
import '../screens/post/post_detail_screen.dart';

class PostCard extends StatefulWidget {
  final PostModel post; final VoidCallback onChanged; final int? currentUserId;
  const PostCard({super.key, required this.post, required this.onChanged, this.currentUserId});
  @override State<PostCard> createState() => _PostCardState();
}
class _PostCardState extends State<PostCard> {
  late bool liked; late int likes; bool busy = false;
  @override void initState() { super.initState(); liked = widget.post.isLiked; likes = widget.post.likesCount; }
  String get timeLabel { final d = DateTime.tryParse(widget.post.createdAt); if (d == null) return 'Recently'; final diff = DateTime.now().difference(d.toLocal()); if (diff.inMinutes < 1) return 'now'; if (diff.inHours < 1) return '${diff.inMinutes}m'; if (diff.inDays < 1) return '${diff.inHours}h'; return '${diff.inDays}d'; }
  Future<void> toggleLike() async { if (busy) return; setState(() { busy = true; liked = !liked; likes += liked ? 1 : -1; }); try { if (liked) { await ApiService.instance.likePost(widget.post.id); } else { await ApiService.instance.unlikePost(widget.post.id); } } catch (e) { if (mounted) { setState(() { liked = !liked; likes += liked ? 1 : -1; }); ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e'))); } } finally { if (mounted) setState(() => busy = false); } }
  @override Widget build(BuildContext context) => Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Row(children: [CircleAvatar(backgroundColor: AppColors.primary.withValues(alpha: .15), child: Text(widget.post.author.name.isEmpty ? 'U' : widget.post.author.name[0].toUpperCase(), style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold))), const SizedBox(width: 10), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(widget.post.author.name, style: const TextStyle(fontWeight: FontWeight.w700)), Text(timeLabel, style: Theme.of(context).textTheme.bodySmall)])), IconButton(onPressed: () => _showMenu(context), icon: const Icon(Icons.more_horiz))]),
    const SizedBox(height: 12), Align(alignment: Alignment.centerLeft, child: Text(widget.post.content, style: const TextStyle(fontSize: 15, height: 1.45))),
    const SizedBox(height: 15), Row(children: [Icon(Icons.favorite, size: 15, color: Theme.of(context).colorScheme.primary), const SizedBox(width: 5), Text('$likes likes', style: Theme.of(context).textTheme.bodySmall), const Spacer(), Text('${widget.post.commentsCount} comments', style: Theme.of(context).textTheme.bodySmall)]),
    const Divider(height: 22), Row(children: [Expanded(child: _action(Icons.favorite, liked ? 'Liked' : 'Like', liked ? AppColors.danger : null, toggleLike)), Expanded(child: _action(Icons.mode_comment_outlined, 'Comment', null, () async { await Navigator.push(context, MaterialPageRoute(builder: (_) => PostDetailScreen(post: widget.post))); widget.onChanged(); })), Expanded(child: _action(Icons.share_outlined, 'Share', null, () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Share can be added with the share_plus package.')))))]),
  ])));
  Widget _action(IconData icon, String text, Color? color, VoidCallback onTap) => InkWell(onTap: onTap, borderRadius: BorderRadius.circular(10), child: Padding(padding: const EdgeInsets.symmetric(vertical: 5), child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(icon, size: 18, color: color ?? Theme.of(context).iconTheme.color), const SizedBox(width: 6), Text(text, style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w600))])));
  void _showMenu(BuildContext context) { showModalBottomSheet(context: context, builder: (ctx) => SafeArea(child: Wrap(children: [ListTile(leading: const Icon(Icons.open_in_new), title: const Text('View post and comments'), onTap: () { Navigator.pop(ctx); Navigator.push(context, MaterialPageRoute(builder: (_) => PostDetailScreen(post: widget.post))); }), if (widget.currentUserId != null && widget.currentUserId == widget.post.userId) ListTile(leading: const Icon(Icons.delete_outline, color: AppColors.danger), title: const Text('Delete post'), onTap: () async { Navigator.pop(ctx); try { await ApiService.instance.deletePost(widget.post.id); widget.onChanged(); } catch (e) { if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e'))); } })]))); }
}
