import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../widgets/app_button.dart';

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final _contentController = TextEditingController();
  bool _isLoading = false;

  void _submitPost() async {
    if (_contentController.text.trim().isEmpty) return;
    setState(() => _isLoading = true);
    final success = await ApiService().createPost(_contentController.text);
    setState(() => _isLoading = false);
    if (success && mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Post')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _contentController,
              maxLines: 5,
              decoration: const InputDecoration(
                hintText: "What's on your mind?",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            AppButton(text: 'Post', isLoading: _isLoading, onPressed: _submitPost),
          ],
        ),
      ),
    );
  }
}