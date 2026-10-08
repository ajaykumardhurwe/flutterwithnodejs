import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/user_model.dart';
import '../models/post_model.dart';
import '../models/comment_model.dart';
import 'storage_service.dart';

class ApiService {
  final StorageService _storage = StorageService();

  Future<Map<String, String>> _getHeaders() async {
    final token = await _storage.getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // Auth
  Future<Map<String, dynamic>> signup(String name, String email, String password) async {
    final res = await http.post(
      Uri.parse('${ApiConfig.baseUrl}${ApiConfig.signup}'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'name': name, 'email': email, 'password': password}),
    );
    return jsonDecode(res.body);
  }

  Future<Map<String, dynamic>> signin(String email, String password) async {
    final res = await http.post(
      Uri.parse('${ApiConfig.baseUrl}${ApiConfig.signin}'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );
    return jsonDecode(res.body);
  }

  // Posts
  Future<List<PostModel>> getPosts() async {
    final headers = await _getHeaders();
    final res = await http.get(
      Uri.parse('${ApiConfig.baseUrl}${ApiConfig.posts}'),
      headers: headers,
    );
    if (res.statusCode == 200) {
      final List data = jsonDecode(res.body);
      return data.map((e) => PostModel.fromJson(e)).toList();
    }
    throw Exception('Failed to load posts');
  }

  Future<PostModel> getPostById(int id) async {
    final headers = await _getHeaders();
    final res = await http.get(
      Uri.parse('${ApiConfig.baseUrl}${ApiConfig.posts}/$id'),
      headers: headers,
    );
    return PostModel.fromJson(jsonDecode(res.body));
  }

  Future<bool> createPost(String content) async {
    final headers = await _getHeaders();
    final res = await http.post(
      Uri.parse('${ApiConfig.baseUrl}${ApiConfig.posts}'),
      headers: headers,
      body: jsonEncode({'content': content}),
    );
    return res.statusCode == 201 || res.statusCode == 200;
  }

  Future<bool> deletePost(int id) async {
    final headers = await _getHeaders();
    final res = await http.delete(
      Uri.parse('${ApiConfig.baseUrl}${ApiConfig.posts}/$id'),
      headers: headers,
    );
    return res.statusCode == 200;
  }

  // Likes
  Future<bool> toggleLike(int postId, bool isCurrentlyLiked) async {
    final headers = await _getHeaders();
    final url = '${ApiConfig.baseUrl}${ApiConfig.likes}/$postId';
    final res = isCurrentlyLiked
        ? await http.delete(Uri.parse(url), headers: headers)
        : await http.post(Uri.parse(url), headers: headers);
    return res.statusCode == 200 || res.statusCode == 201;
  }

  // Comments
  Future<List<CommentModel>> getComments(int postId) async {
    final headers = await _getHeaders();
    final res = await http.get(
      Uri.parse('${ApiConfig.baseUrl}${ApiConfig.comments}/$postId'),
      headers: headers,
    );
    if (res.statusCode == 200) {
      final List data = jsonDecode(res.body);
      return data.map((e) => CommentModel.fromJson(e)).toList();
    }
    return [];
  }

  Future<bool> addComment(int postId, String comment) async {
    final headers = await _getHeaders();
    final res = await http.post(
      Uri.parse('${ApiConfig.baseUrl}${ApiConfig.comments}/$postId'),
      headers: headers,
      body: jsonEncode({'comment': comment}),
    );
    return res.statusCode == 201 || res.statusCode == 200;
  }

  Future<bool> deleteComment(int commentId) async {
    final headers = await _getHeaders();
    final res = await http.delete(
      Uri.parse('${ApiConfig.baseUrl}${ApiConfig.deleteComment}/$commentId'),
      headers: headers,
    );
    return res.statusCode == 200;
  }
}