import 'user_model.dart';
class PostModel {
  final int id;
  final int? userId;
  final String content;
  final String createdAt;
  final UserModel author;
  final int likesCount;
  final int commentsCount;
  final bool isLiked;
  const PostModel({required this.id, this.userId, required this.content, required this.createdAt,
    required this.author, this.likesCount = 0, this.commentsCount = 0, this.isLiked = false});

  factory PostModel.fromJson(Map<String, dynamic> j) {
    final rawUser = j['user'] ?? j['author'] ?? j['users'];
    final userMap = rawUser is Map ? Map<String, dynamic>.from(rawUser) : <String, dynamic>{
      'id': j['user_id'], 'name': j['user_name'] ?? j['name'] ?? 'User', 'email': j['user_email'] ?? ''};
    return PostModel(id: int.tryParse('${j['id'] ?? j['post_id'] ?? 0}') ?? 0,
      userId: int.tryParse('${j['user_id'] ?? userMap['id'] ?? ''}'),
      content: (j['content'] ?? j['text'] ?? '').toString(),
      createdAt: (j['created_at'] ?? j['createdAt'] ?? '').toString(),
      author: UserModel.fromJson(userMap),
      likesCount: int.tryParse('${j['likes_count'] ?? j['like_count'] ?? j['likesCount'] ?? 0}') ?? 0,
      commentsCount: int.tryParse('${j['comments_count'] ?? j['comment_count'] ?? j['commentsCount'] ?? 0}') ?? 0,
      isLiked: j['is_liked'] == true || j['isLiked'] == true || j['liked_by_me'] == true);
  }
}
