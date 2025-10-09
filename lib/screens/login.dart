import 'package:flutter/material.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final email = TextEditingController();
    final password = TextEditingController();

    return Scaffold(
      appBar: AppBar(title: const Text('Sign in')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const SizedBox(height: 12),
          const Icon(Icons.lock_outline, size: 64),
          const SizedBox(height: 12),
          TextField(
            controller: email,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(labelText: 'Email', prefixIcon: Icon(Icons.email_outlined)),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: password,
            obscureText: true,
            decoration: const InputDecoration(labelText: 'Password', prefixIcon: Icon(Icons.lock_outline)),
          ),
          const SizedBox(height: 18),
          ElevatedButton(
            onPressed: () => Navigator.pushReplacementNamed(context, '/shell'),
            style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
            child: const Text('Sign in'),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () => Navigator.pushNamed(context, '/register'),
            child: const Text('Create an account'),
          ),
        ],
      ),
    );
  }
}
