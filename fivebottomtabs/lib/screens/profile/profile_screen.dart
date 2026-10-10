import 'package:flutter/material.dart';
import '../../services/storage_service.dart';
import '../../utils/app_routes.dart';

class ProfileScreen extends StatefulWidget {
  final Function(bool)? onThemeChanged;
  const ProfileScreen({super.key, this.onThemeChanged});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String name = '';
  String email = '';
  bool isDark = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  void _loadProfile() async {
    final details = await StorageService.getUserDetails();
    final dark = await StorageService.getThemeMode();
    setState(() {
      name = details['name'] ?? 'User';
      email = details['email'] ?? '';
      isDark = dark;
    });
  }

  void _logout() async {
    await StorageService.clear();
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, AppRoutes.login, (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const CircleAvatar(radius: 50, child: Icon(Icons.person, size: 50)),
            const SizedBox(height: 16),
            Text(name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            Text(email, style: const TextStyle(fontSize: 14, color: Colors.grey)),
            const SizedBox(height: 32),
            SwitchListTile(
              title: const Text('Dark Mode'),
              value: isDark,
              onChanged: (val) async {
                setState(() => isDark = val);
                await StorageService.setThemeMode(val);
                if (widget.onThemeChanged != null) widget.onThemeChanged!(val);
              },
            ),
            const Spacer(),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
              onPressed: _logout,
              icon: const Icon(Icons.logout),
              label: const Text('Logout'),
            ),
          ],
        ),
      ),
    );
  }
}