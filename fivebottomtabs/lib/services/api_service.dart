import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/post_model.dart';
import '../models/comment_model.dart';
import 'storage_service.dart';

class ApiService {
  static Future<Map<String, String>> _getHeaders() async {
    final token = await StorageService.getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  static Future<Map<String, dynamic>> signup(String name, String email, String password) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}${ApiConfig.signup}'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'name': name, 'email': email, 'password': password}),
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> signin(String email, String password) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}${ApiConfig.signin}'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );
    return jsonDecode(response.body);
  }

  static Future<List<PostModel>> getPosts() async {
    final headers = await _getHeaders();
    final response = await http.get(Uri.parse('${ApiConfig.baseUrl}${ApiConfig.posts}'), headers: headers);
    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((json) => PostModel.fromJson(json)).toList();
    }
    throw Exception('Failed to load posts');
  }

  static Future<PostModel> getPostById(int id) async {
    final headers = await _getHeaders();
    final response = await http.get(Uri.parse('${ApiConfig.baseUrl}${ApiConfig.posts}/$id'), headers: headers);
    if (response.statusCode == 200) {
      return PostModel.fromJson(jsonDecode(response.body));
    }
    throw Exception('Failed to load post');
  }

  static Future<bool> createPost(String content) async {
    final headers = await _getHeaders();
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}${ApiConfig.posts}'),
      headers: headers,
      body: jsonEncode({'content': content}),
    );
    return response.statusCode == 201 || response.statusCode == 200;
  }

  static Future<bool> updatePost(int id, String content) async {
    final headers = await _getHeaders();
    final response = await http.put(
      Uri.parse('${ApiConfig.baseUrl}${ApiConfig.posts}/$id'),
      headers: headers,
      body: jsonEncode({'content': content}),
    );
    return response.statusCode == 200;
  }

  static Future<bool> deletePost(int id) async {
    final headers = await _getHeaders();
    final response = await http.delete(Uri.parse('${ApiConfig.baseUrl}${ApiConfig.posts}/$id'), headers: headers);
    return response.statusCode == 200;
  }

  static Future<bool> toggleLike(int postId, bool isLiked) async {
    final headers = await _getHeaders();
    final url = Uri.parse('${ApiConfig.baseUrl}/likes/$postId');
    final response = isLiked ? await http.delete(url, headers: headers) : await http.post(url, headers: headers);
    return response.statusCode == 200 || response.statusCode == 201;
  }

  static Future<List<CommentModel>> getComments(int postId) async {
    final headers = await _getHeaders();
    final response = await http.get(Uri.parse('${ApiConfig.baseUrl}${ApiConfig.comments}/$postId'), headers: headers);
    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((json) => CommentModel.fromJson(json)).toList();
    }
    throw Exception('Failed to load comments');
  }

  static Future<bool> addComment(int postId, String comment) async {
    final headers = await _getHeaders();
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}${ApiConfig.comments}/$postId'),
      headers: headers,
      body: jsonEncode({'comment': comment}),
    );
    return response.statusCode == 201 || response.statusCode == 200;
  }

  static Future<bool> deleteComment(int commentId) async {
    final headers = await _getHeaders();
    final response = await http.delete(Uri.parse('${ApiConfig.baseUrl}/comments/$commentId'), headers: headers);
    return response.statusCode == 200;
  }
}