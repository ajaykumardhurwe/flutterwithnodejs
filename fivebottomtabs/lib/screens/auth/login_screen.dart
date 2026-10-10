import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../services/storage_service.dart';
import '../../utils/app_routes.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_text_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  void _login() async {
    setState(() => _isLoading = true);
    try {
      final res = await ApiService.signin(_emailController.text.trim(), _passwordController.text.trim());
      if (res['token'] != null) {
        await StorageService.saveAuthData(
          token: res['token'],
          userId: res['user']['id'],
          name: res['user']['name'],
          email: res['user']['email'],
        );
        if (!mounted) return;
        Navigator.pushReplacementNamed(context, AppRoutes.home);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(res['message'] ?? 'Login failed')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.lock_person, size: 64, color: Colors.indigo),
                const SizedBox(height: 24),
                const Text("Welcome Back!", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                const SizedBox(height: 32),
                AppTextField(label: 'Email', controller: _emailController, keyboardType: TextInputType.emailAddress),
                const SizedBox(height: 16),
                AppTextField(label: 'Password', controller: _passwordController, isPassword: true),
                const SizedBox(height: 24),
                AppButton(label: 'Sign In', onPressed: _login, isLoading: _isLoading),
                TextButton(
                  onPressed: () => Navigator.pushNamed(context, AppRoutes.signup),
                  child: const Text("Don't have an account? Sign Up"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}