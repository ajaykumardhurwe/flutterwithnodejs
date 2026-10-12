import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/comment_model.dart';
import '../models/post_model.dart';
import '../models/user_model.dart';
import 'storage_service.dart';

class ApiException implements Exception {
  final String message;
  ApiException(this.message);
  @override
  String toString() => message;
}

class ApiService {
  static final ApiService instance = ApiService._();
  ApiService._();

  final StorageService _storage = StorageService();
  Uri _uri(String path) => Uri.parse('${ApiConfig.baseUrl}$path');

  Future<Map<String, String>> _headers({bool authenticated = false}) async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (authenticated) {
      final token = await _storage.getToken();
      if (token == null) {
        throw ApiException('You are not signed in or your login token is missing. Please sign in again.');
      }
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  dynamic _decode(http.Response r) {
    dynamic data;
    try {
      data = r.body.isEmpty ? <String, dynamic>{} : jsonDecode(r.body);
    } catch (_) {
      data = {'message': r.body};
    }
    if (r.statusCode < 200 || r.statusCode >= 300) {
      final msg = data is Map
          ? (data['message'] ?? data['error'] ?? 'Request failed (${r.statusCode})')
          : 'Request failed (${r.statusCode})';
      throw ApiException(msg.toString());
    }
    return data;
  }

  dynamic _payload(dynamic data) {
    if (data is Map) return data['data'] ?? data['result'] ?? data;
    return data;
  }

  List<dynamic> _list(dynamic data, [String key = '']) {
    data = _payload(data);
    if (data is List) return data;
    if (data is Map) {
      if (key.isNotEmpty && data[key] is List) return data[key] as List;
      for (final k in ['posts', 'comments', 'users', 'items', 'results']) {
        if (data[k] is List) return data[k] as List;
      }
    }
    return [];
  }

  Map<String, dynamic> _asMap(dynamic value) => value is Map
      ? Map<String, dynamic>.from(value)
      : <String, dynamic>{};

  // Supports common API response shapes: {token, user}, {accessToken, user},
  // {data: {token, user}}, and {data: {accessToken, user}}.
  Future<UserModel> _saveAuthResponse(dynamic response) async {
    final root = _asMap(response);
    final data = _asMap(root['data'] ?? root['result']);
    final auth = data.isNotEmpty ? data : root;
    final tokenValue = auth['token'] ?? auth['accessToken'] ?? auth['access_token'] ??
        root['token'] ?? root['accessToken'] ?? root['access_token'];
    final token = tokenValue?.toString().trim();
    if (token == null || token.isEmpty || token == 'null') {
      throw ApiException('Authentication token was not returned by the server. Check the signin/signup response and backend JWT configuration.');
    }
    final userJson = auth['user'] ?? root['user'] ?? auth['profile'] ?? root['profile'];
    final user = UserModel.fromJson(_asMap(userJson ?? auth));
    await _storage.saveToken(token);
    await _storage.saveUser(user);
    return user;
  }

  Future<UserModel> signup({required String name, required String email, required String password}) async {
    final response = _decode(await http.post(
      _uri('/auth/signup'),
      headers: await _headers(),
      body: jsonEncode({'name': name, 'email': email, 'password': password}),
    ).timeout(ApiConfig.timeout));
    try {
      return await _saveAuthResponse(response);
    } on ApiException catch (e) {
      // Some APIs create the account but only return a message/user. In that
      // case, sign in immediately to obtain the JWT used by protected routes.
      if (e.message.contains('Authentication token was not returned')) {
        return signin(email: email, password: password);
      }
      rethrow;
    }
  }

  Future<UserModel> signin({required String email, required String password}) async {
    final response = _decode(await http.post(
      _uri('/auth/signin'),
      headers: await _headers(),
      body: jsonEncode({'email': email, 'password': password}),
    ).timeout(ApiConfig.timeout));
    return _saveAuthResponse(response);
  }

  Future<List<PostModel>> getPosts() async {
    final d = _decode(await http.get(_uri('/posts'), headers: await _headers()).timeout(ApiConfig.timeout));
    return _list(d).whereType<Map>().map((e) => PostModel.fromJson(Map<String, dynamic>.from(e))).toList();
  }

  Future<PostModel> getPost(int id) async {
    final d = _payload(_decode(await http.get(_uri('/posts/$id'), headers: await _headers()).timeout(ApiConfig.timeout)));
    final m = d is Map && d['post'] is Map ? d['post'] : d;
    return PostModel.fromJson(Map<String, dynamic>.from(m as Map));
  }

  Future<void> createPost(String content) async {
    _decode(await http.post(_uri('/posts'), headers: await _headers(authenticated: true), body: jsonEncode({'content': content})).timeout(ApiConfig.timeout));
  }

  Future<void> updatePost(int id, String content) async {
    _decode(await http.put(_uri('/posts/$id'), headers: await _headers(authenticated: true), body: jsonEncode({'content': content})).timeout(ApiConfig.timeout));
  }

  Future<void> deletePost(int id) async {
    _decode(await http.delete(_uri('/posts/$id'), headers: await _headers(authenticated: true)).timeout(ApiConfig.timeout));
  }

  Future<void> likePost(int id) async {
    _decode(await http.post(_uri('/likes/$id'), headers: await _headers(authenticated: true)).timeout(ApiConfig.timeout));
  }

  Future<void> unlikePost(int id) async {
    _decode(await http.delete(_uri('/likes/$id'), headers: await _headers(authenticated: true)).timeout(ApiConfig.timeout));
  }

  Future<List<CommentModel>> getComments(int postId) async {
    final d = _decode(await http.get(_uri('/comments/post/$postId'), headers: await _headers()).timeout(ApiConfig.timeout));
    return _list(d).whereType<Map>().map((e) => CommentModel.fromJson(Map<String, dynamic>.from(e))).toList();
  }

  Future<void> addComment(int postId, String comment) async {
    _decode(await http.post(_uri('/comments/post/$postId'), headers: await _headers(authenticated: true), body: jsonEncode({'comment': comment})).timeout(ApiConfig.timeout));
  }

  Future<void> deleteComment(int id) async {
    _decode(await http.delete(_uri('/comments/$id'), headers: await _headers(authenticated: true)).timeout(ApiConfig.timeout));
  }
}
