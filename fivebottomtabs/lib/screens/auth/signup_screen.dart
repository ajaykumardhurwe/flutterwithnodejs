import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../utils/app_routes.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_text_field.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  void _signup() async {
    setState(() => _isLoading = true);
    try {
      final res = await ApiService.signup(_nameController.text.trim(), _emailController.text.trim(), _passwordController.text.trim());
      if (res['message'] != null || res['id'] != null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Registration successful! Please login.')));
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(res['message'] ?? 'Signup failed')));
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
      appBar: AppBar(title: const Text('Create Account')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              children: [
                AppTextField(label: 'Full Name', controller: _nameController),
                const SizedBox(height: 16),
                AppTextField(label: 'Email', controller: _emailController, keyboardType: TextInputType.emailAddress),
                const SizedBox(height: 16),
                AppTextField(label: 'Password', controller: _passwordController, isPassword: true),
                const SizedBox(height: 24),
                AppButton(label: 'Sign Up', onPressed: _signup, isLoading: _isLoading),
              ],
            ),
          ),
        ),
      ),
    );
  }
}