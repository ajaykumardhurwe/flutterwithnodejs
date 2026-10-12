class CommentModel {
  final int id;
  final int? userId;
  final int? postId;
  final String comment;
  final String userName;
  final String createdAt;
  const CommentModel({required this.id, this.userId, this.postId, required this.comment,
    required this.userName, required this.createdAt});
  factory CommentModel.fromJson(Map<String, dynamic> j) {
    final u = j['user'] ?? j['author'];
    final name = u is Map ? (u['name'] ?? u['username'] ?? 'User').toString() : (j['user_name'] ?? j['name'] ?? 'User').toString();
    return CommentModel(id: int.tryParse('${j['id'] ?? 0}') ?? 0,
      userId: int.tryParse('${j['user_id'] ?? ''}'), postId: int.tryParse('${j['post_id'] ?? ''}'),
      comment: (j['comment'] ?? j['content'] ?? '').toString(), userName: name,
      createdAt: (j['created_at'] ?? '').toString());
  }
}
