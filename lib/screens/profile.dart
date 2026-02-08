import 'dart:io';
import 'package:flutter/foundation.dart'; // For kIsWeb
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:battery_plus/battery_plus.dart';
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
  String _name = "Loading...";
  String _email = "loading...";
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() => _isLoading = true);
    final user = await ApiService().fetchUser();
    if (user != null) {
      if (mounted) {
        setState(() {
          _name = user['name'] ?? "User";
          _email = user['email'] ?? "No Email";
        });
      }
    } else {
      if (mounted) {
        setState(() {
          _name = "Guest";
          _email = "Not logged in";
        });
      }
    }
    setState(() => _isLoading = false);
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

  void _showEditProfileDialog() {
    final nameController = TextEditingController(text: _name);
    final emailController = TextEditingController(text: _email);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Profile'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final newName = nameController.text.trim();
              final newEmail = emailController.text.trim();

              if (newName.isEmpty || newEmail.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please fill all fields')),
                );
                return;
              }

              Navigator.pop(context); // Close dialog

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Updating profile...')),
              );

              final error = await ApiService().updateProfile(newName, newEmail);

              if (mounted) {
                if (error == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Profile updated successfully!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                  setState(() {
                    _name = newName;
                    _email = newEmail;
                  });
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(error), backgroundColor: Colors.red),
                  );
                }
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = ThemeController.instance;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF25355E),
        foregroundColor: Colors.white,
        title: const Text('Profile'),
        actions: [
          IconButton(
            onPressed: _showEditProfileDialog,
            icon: const Icon(Icons.edit),
            tooltip: 'Edit Profile',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
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
                      FutureBuilder<int>(
                        future: Battery().batteryLevel,
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            return Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.battery_full,
                                  size: 16,
                                  color: Colors.green,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Battery: ${snapshot.data}%',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            );
                          }
                          return const SizedBox.shrink();
                        },
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
                      const SizedBox(height: 10),
                      OutlinedButton.icon(
                        onPressed: _showEditProfileDialog,
                        icon: const Icon(Icons.edit, size: 16),
                        label: const Text("Edit Profile"),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF25355E),
                          side: const BorderSide(color: Color(0xFF25355E)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                      ),
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
                              value
                                  ? controller.setDark()
                                  : controller.setLight();
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
