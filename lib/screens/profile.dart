import 'dart:io';
import 'package:flutter/foundation.dart'; // For kIsWeb
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'order_history.dart';
import '../services/api_service.dart';

import '../theme_controller.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  XFile? _pickedFile;
  final String _name = "Suthan"; // Default placeholder
  final String _email = "suthan@gmail.com";

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    // In a real app, you'd fetch this from API or stored config
    // For now, we use defaults or could load from SharedPreferences if we saved them on login
    // final prefs = await SharedPreferences.getInstance();
    // setState(() {
    //   _name = prefs.getString('user_name') ?? "Suthan";
    //   _email = prefs.getString('user_email') ?? "suthan@gmail.com";
    // });
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);

    if (picked != null) {
      setState(() {
        _pickedFile = picked;
      });
    }
  }

  ImageProvider? _getImageProvider() {
    if (_pickedFile == null) return null;
    if (kIsWeb) {
      return NetworkImage(_pickedFile!.path);
    }
    return FileImage(File(_pickedFile!.path));
  }

  @override
  Widget build(BuildContext context) {
    final controller = ThemeController.instance;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF25355E),
        foregroundColor: Colors.white,
        title: const Text('Profile'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Center(
            child: Column(
              children: [
                Stack(
                  children: [
                    GestureDetector(
                      onTap: _pickImage,
                      child: CircleAvatar(
                        radius: 50,
                        backgroundColor: const Color(0xFF25355E),
                        backgroundImage: _getImageProvider(),
                        child: _pickedFile == null
                            ? const Icon(
                                Icons.person,
                                size: 50,
                                color: Colors.white,
                              )
                            : null,
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.camera_alt,
                          size: 20,
                          color: Color(0xFF25355E),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  _name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                Text(_email, style: const TextStyle(color: Colors.grey)),
                const SizedBox(height: 20),
              ],
            ),
          ),
          const Divider(),
          Card(
            child: Column(
              children: [
                const ListTile(
                  leading: Icon(Icons.palette_outlined),
                  title: Text('Appearance'),
                  subtitle: Text('Switch app theme'),
                ),
                const Divider(height: 1),
                ValueListenableBuilder<ThemeMode>(
                  valueListenable: controller.themeMode,
                  builder: (context, mode, _) {
                    final isDark = mode == ThemeMode.dark;
                    return SwitchListTile(
                      title: const Text('Dark Mode'),
                      secondary: const Icon(Icons.dark_mode_outlined),
                      value: isDark,
                      onChanged: (value) {
                        value ? controller.setDark() : controller.setLight();
                      },
                      activeTrackColor: const Color(0xFF25355E),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.history),
                  title: const Text('Order History'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const OrderHistoryScreen(),
                      ),
                    );
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: Icon(Icons.lock_outline),
                  title: Text('Privacy & Security'),
                ),
                Divider(height: 1),
                ListTile(
                  leading: Icon(Icons.help_outline),
                  title: Text('Help & Support'),
                ),
                Divider(height: 1),
                ListTile(
                  leading: Icon(Icons.info_outline),
                  title: Text('About ElectroMart'),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: ElevatedButton.icon(
              onPressed: () async {
                await ApiService().logout();
                if (context.mounted) {
                  Navigator.of(
                    context,
                  ).pushNamedAndRemoveUntil('/login', (route) => false);
                }
              },
              icon: const Icon(Icons.logout),
              label: const Text('Log Out'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade600,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  vertical: 14,
                  horizontal: 20,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
