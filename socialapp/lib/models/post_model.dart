class PostModel {
  final int id;
  final int userId;
  final String userName;
  final String content;
  final DateTime createdAt;
  bool isLiked;
  int likesCount;
  int commentsCount;

  PostModel({
    required this.id,
    required this.userId,
    required this.userName,
    required this.content,
    required this.createdAt,
    this.isLiked = false,
    this.likesCount = 0,
    this.commentsCount = 0,
  });

  factory PostModel.fromJson(Map<String, dynamic> json) {
    return PostModel(
      id: json['id'],
      userId: json['user_id'],
      userName: json['user_name'] ?? json['name'] ?? 'Anonymous',
      content: json['content'],
      createdAt: DateTime.parse(json['created_at']),
      isLiked: json['is_liked'] ?? false,
      likesCount: json['likes_count'] ?? 0,
      commentsCount: json['comments_count'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'content': content,
      'created_at': createdAt.toIso8601String(),
    };
  }
}