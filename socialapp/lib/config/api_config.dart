class ApiConfig {
  static const String baseUrl = 'http://10.0.2.2:5000/api'; // Use 10.0.2.2 for Android Emulator, localhost for iOS

  // Endpoints
  static const String signup = '/auth/signup';
  static const String signin = '/auth/signin';
  static const String posts = '/posts';
  static const String likes = '/likes';
  static const String comments = '/comments/post';
  static const String deleteComment = '/comments';
}