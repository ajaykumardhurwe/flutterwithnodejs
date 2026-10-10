class PostModel {
  final int id;
  final int userId;
  final String content;
  final String userName;
  final String userEmail;
  final String createdAt;
  int likesCount;
  int commentsCount;
  bool isLiked;

  PostModel({
    required this.id,
    required this.userId,
    required this.content,
    required this.userName,
    required this.userEmail,
    required this.createdAt,
    this.likesCount = 0,
    this.commentsCount = 0,
    this.isLiked = false,
  });

  factory PostModel.fromJson(Map<String, dynamic> json) {
    return PostModel(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? 0,
      content: json['content'] ?? '',
      userName: json['name'] ?? json['user_name'] ?? 'Unknown',
      userEmail: json['email'] ?? json['user_email'] ?? '',
      createdAt: json['created_at'] ?? '',
      likesCount: json['likes_count'] ?? 0,
      commentsCount: json['comments_count'] ?? 0,
      isLiked: json['is_liked'] == 1 || json['is_liked'] == true,
    );
  }
}