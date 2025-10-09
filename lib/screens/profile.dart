import 'package:flutter/material.dart';
import '../theme_controller.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = ThemeController.instance;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF25355E),
        foregroundColor: Colors.white,
        title: const Text(
          'Profile',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          //  Profile header
          Center(
            child: Column(
              children: const [
                CircleAvatar(
                  backgroundColor: Colors.grey,
                ),
                SizedBox(height: 10),
                Text(
                  'Suthan',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                Text(
                  'suthan@gmail.com',
                  style: TextStyle(color: Colors.grey),
                ),
                SizedBox(height: 20),
              ],
            ),
          ),
          const Divider(),

          // Dark Mode Toggle
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
                        if (value) {
                          controller.setDark();
                        } else {
                          controller.setLight();
                        }
                      },
                      activeColor: Colors.indigo,
                    );
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          //  Other options
          const Card(
            child: Column(
              children: [
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

          //  Log out button
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: ElevatedButton.icon(
              onPressed: () => Navigator.pushNamed(context, '/'),
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
