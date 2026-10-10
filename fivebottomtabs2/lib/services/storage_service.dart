import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

class StorageService {
  static const _userKey = 'social_user';
  static const _themeKey = 'theme_mode';
  Future<void> saveUser(UserModel user) async {
    final p = await SharedPreferences.getInstance();
    await p.setString(_userKey, jsonEncode(user.toJson()));
  }
  Future<UserModel?> getUser() async {
    final p = await SharedPreferences.getInstance(); final raw = p.getString(_userKey);
    if (raw == null) return null;
    try { return UserModel.fromJson(Map<String, dynamic>.from(jsonDecode(raw))); } catch (_) { return null; }
  }
  Future<void> clearUser() async { final p = await SharedPreferences.getInstance(); await p.remove(_userKey); }
  Future<void> saveTheme(String theme) async { final p = await SharedPreferences.getInstance(); await p.setString(_themeKey, theme); }
}
