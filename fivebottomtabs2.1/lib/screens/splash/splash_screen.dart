import 'package:flutter/material.dart';
import '../../services/storage_service.dart';
import '../home/home_screen.dart';
import '../auth/login_screen.dart';
import '../../utils/app_colors.dart';
class SplashScreen extends StatefulWidget { const SplashScreen({super.key}); @override State<SplashScreen> createState() => _SplashScreenState(); }
class _SplashScreenState extends State<SplashScreen> {
 @override void initState() { super.initState(); _go(); }
 Future<void> _go() async { await Future.delayed(const Duration(milliseconds: 650)); final user = await StorageService().getUser(); if (!mounted) return; Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => user == null ? const LoginScreen() : HomeScreen(user: user))); }
 @override Widget build(BuildContext context) => Scaffold(body: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [Container(width: 86, height: 86, decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(28)), child: const Icon(Icons.forum_rounded, color: Colors.white, size: 44)), const SizedBox(height: 18), const Text('Socially', style: TextStyle(fontSize: 29, fontWeight: FontWeight.w800)), const SizedBox(height: 8), Text('Connect with your people', style: TextStyle(color: Theme.of(context).hintColor))])));
}
