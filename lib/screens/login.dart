import 'package:flutter/material.dart';
import '../theme_controller.dart';
import '../app_shell.dart';
import 'register.dart';

// Demo user variables
String savedName = "Suthan";
String savedEmail = "suthan@gmail.com";
String savedPassword = "suthan123";

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  String? errorMessage;

  void login() {
    if (emailController.text.trim() == savedEmail &&
        passwordController.text.trim() == savedPassword) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const AppShell()),
      );
    } else {
      setState(() {
        errorMessage = "Invalid email or password";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = ThemeController.instance;

    return ValueListenableBuilder<ThemeMode>(
      valueListenable: theme.themeMode,
      builder: (context, mode, _) {
        final isDark = mode == ThemeMode.dark;
        return Scaffold(
          backgroundColor: isDark ? const Color(0xFF121212) : Colors.white,
          appBar: AppBar(
            backgroundColor: const Color(0xFF25355E),
            title: const Text('Login'),
            foregroundColor: Colors.white,
          ),
          body: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.lock_outline, size: 80, color: Color(0xFF25355E)),
                const SizedBox(height: 20),
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email_outlined),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 15),
                TextField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    prefixIcon: Icon(Icons.lock_outline),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                if (errorMessage != null)
                  Text(errorMessage!, style: const TextStyle(color: Colors.red)),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF25355E),
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 48),
                  ),
                  child: const Text("Login"),
                ),
                const SizedBox(height: 10),
                TextButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const RegisterScreen()),
                    );
                  },
                  child: const Text("Don't have an account? Register"),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
