class CommentModel {
  final int id;
  final int userId;
  final int postId;
  final String userName;
  final String comment;
  final DateTime createdAt;

  CommentModel({
    required this.id,
    required this.userId,
    required this.postId,
    required this.userName,
    required this.comment,
    required this.createdAt,
  });

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    return CommentModel(
      id: json['id'],
      userId: json['user_id'],
      postId: json['post_id'],
      userName: json['user_name'] ?? json['name'] ?? 'User',
      comment: json['comment'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}