class CommentModel {
  final int id;
  final int userId;
  final int postId;
  final String comment;
  final String userName;
  final String createdAt;

  CommentModel({
    required this.id,
    required this.userId,
    required this.postId,
    required this.comment,
    required this.userName,
    required this.createdAt,
  });

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    return CommentModel(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? 0,
      postId: json['post_id'] ?? 0,
      comment: json['comment'] ?? '',
      userName: json['name'] ?? json['user_name'] ?? 'User',
      createdAt: json['created_at'] ?? '',
    );
  }
}