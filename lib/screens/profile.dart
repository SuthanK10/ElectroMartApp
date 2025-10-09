import 'package:flutter/material.dart';
import '../theme_controller.dart';
import 'login.dart'; // to use savedName/savedEmail

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

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
                const CircleAvatar(
                  radius: 45,
                  backgroundColor: Color(0xFF25355E),
                  child: Icon(Icons.person, size: 50, color: Colors.white),
                ),
                const SizedBox(height: 10),
                Text(
                  savedName.isNotEmpty ? savedName : "User",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                Text(
                  savedEmail.isNotEmpty ? savedEmail : "No email found",
                  style: const TextStyle(color: Colors.grey),
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
                      activeColor: const Color(0xFF25355E),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Card(
            child: Column(
              children: [
                ListTile(
                    leading: Icon(Icons.lock_outline),
                    title: Text('Privacy & Security')),
                Divider(height: 1),
                ListTile(
                    leading: Icon(Icons.help_outline),
                    title: Text('Help & Support')),
                Divider(height: 1),
                ListTile(
                    leading: Icon(Icons.info_outline),
                    title: Text('About ElectroMart')),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/');
              },
              icon: const Icon(Icons.logout),
              label: const Text('Log Out'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade600,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
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
