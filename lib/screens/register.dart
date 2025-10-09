import 'package:flutter/material.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final name = TextEditingController();
    final email = TextEditingController();
    final password = TextEditingController();
    final confirm = TextEditingController();

    return Scaffold(
      appBar: AppBar(title: const Text('Create account')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const SizedBox(height: 12),
          const Icon(Icons.person_add_outlined, size: 64),
          const SizedBox(height: 12),
          TextField(
            controller: name,
            decoration: const InputDecoration(labelText: 'Full name', prefixIcon: Icon(Icons.person_outline)),
          ),
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
          const SizedBox(height: 12),
          TextField(
            controller: confirm,
            obscureText: true,
            decoration: const InputDecoration(labelText: 'Confirm password', prefixIcon: Icon(Icons.lock_outline)),
          ),
          const SizedBox(height: 18),
          ElevatedButton(
            onPressed: () => Navigator.pushReplacementNamed(context, '/shell'),
            style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
            child: const Text('Create account'),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Back to sign in'),
          ),
        ],
      ),
    );
  }
}
