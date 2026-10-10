import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/comment_model.dart';
import '../models/post_model.dart';
import '../models/user_model.dart';

class ApiException implements Exception {
  final String message;
  ApiException(this.message);
  @override String toString() => message;
}

class ApiService {
  static final ApiService instance = ApiService._();
  ApiService._();
  Uri _uri(String path) => Uri.parse('${ApiConfig.baseUrl}$path');
  Map<String, String> get _headers => {'Content-Type': 'application/json', 'Accept': 'application/json'};

  dynamic _decode(http.Response r) {
    dynamic data;
    try { data = r.body.isEmpty ? {} : jsonDecode(r.body); } catch (_) { data = {'message': r.body}; }
    if (r.statusCode < 200 || r.statusCode >= 300) {
      final msg = data is Map ? (data['message'] ?? data['error'] ?? 'Request failed (${r.statusCode})') : 'Request failed (${r.statusCode})';
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
      for (final k in ['posts', 'comments', 'users', 'items', 'results']) { if (data[k] is List) return data[k] as List; }
    }
    return [];
  }

  Future<UserModel> signup({required String name, required String email, required String password}) async {
    final d = _payload(_decode(await http.post(_uri('/auth/signup'), headers: _headers,
      body: jsonEncode({'name': name, 'email': email, 'password': password})).timeout(ApiConfig.timeout)));
    final m = d is Map ? (d['user'] is Map ? d['user'] : d) : {};
    return UserModel.fromJson(Map<String, dynamic>.from(m));
  }
  Future<UserModel> signin({required String email, required String password}) async {
    final d = _payload(_decode(await http.post(_uri('/auth/signin'), headers: _headers,
      body: jsonEncode({'email': email, 'password': password})).timeout(ApiConfig.timeout)));
    final m = d is Map ? (d['user'] is Map ? d['user'] : d) : {};
    return UserModel.fromJson(Map<String, dynamic>.from(m));
  }
  Future<List<PostModel>> getPosts() async {
    final d = _decode(await http.get(_uri('/posts'), headers: _headers).timeout(ApiConfig.timeout));
    return _list(d).whereType<Map>().map((e) => PostModel.fromJson(Map<String, dynamic>.from(e))).toList();
  }
  Future<PostModel> getPost(int id) async {
    final d = _payload(_decode(await http.get(_uri('/posts/$id'), headers: _headers).timeout(ApiConfig.timeout)));
    final m = d is Map && d['post'] is Map ? d['post'] : d;
    return PostModel.fromJson(Map<String, dynamic>.from(m as Map));
  }
  Future<void> createPost(String content) async {
    _decode(await http.post(_uri('/posts'), headers: _headers, body: jsonEncode({'content': content})).timeout(ApiConfig.timeout));
  }
  Future<void> updatePost(int id, String content) async {
    _decode(await http.put(_uri('/posts/$id'), headers: _headers, body: jsonEncode({'content': content})).timeout(ApiConfig.timeout));
  }
  Future<void> deletePost(int id) async {
    _decode(await http.delete(_uri('/posts/$id'), headers: _headers).timeout(ApiConfig.timeout));
  }
  Future<void> likePost(int id) async { _decode(await http.post(_uri('/likes/$id'), headers: _headers).timeout(ApiConfig.timeout)); }
  Future<void> unlikePost(int id) async { _decode(await http.delete(_uri('/likes/$id'), headers: _headers).timeout(ApiConfig.timeout)); }
  Future<List<CommentModel>> getComments(int postId) async {
    final d = _decode(await http.get(_uri('/comments/post/$postId'), headers: _headers).timeout(ApiConfig.timeout));
    return _list(d).whereType<Map>().map((e) => CommentModel.fromJson(Map<String, dynamic>.from(e))).toList();
  }
  Future<void> addComment(int postId, String comment) async {
    _decode(await http.post(_uri('/comments/post/$postId'), headers: _headers,
      body: jsonEncode({'comment': comment})).timeout(ApiConfig.timeout));
  }
  Future<void> deleteComment(int id) async { _decode(await http.delete(_uri('/comments/$id'), headers: _headers).timeout(ApiConfig.timeout)); }
}
