class ApiConfig {
  // Replace with your local IP or emulator localhost (10.0.2.2 for Android Emulator)
  static const String baseUrl = 'http://172.25.246.203:5000/api';

  // Endpoints
  static const String signup = '/auth/signup';
  static const String signin = '/auth/signin';
  static const String posts = '/posts';
  static const String likes = '/likes';
  static const String comments = '/comments/post';
}