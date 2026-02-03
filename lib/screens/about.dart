import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF25355E),
        foregroundColor: Colors.white,
        title: const Text('About ElectroMart'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _header(t),
          const SizedBox(height: 20),
          _highlights(),
          const SizedBox(height: 20),
          Card(
            child: const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'At ElectroMart, our mission is simple: make great tech easy to buy. '
                'We carefully select phones, laptops, audio gear, and smart devices to deliver value you can trust.',
                textAlign: TextAlign.center,
                style: TextStyle(height: 1.5),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Card(
            child: Column(
              children: const [
                ListTile(
                  leading: Icon(Icons.mail_outline),
                  title: Text('support@electromart.com'),
                  subtitle: Text('Email us anytime'),
                ),
                Divider(height: 1),
                ListTile(
                  leading: Icon(Icons.phone_outlined),
                  title: Text('+94 11 234 5678'),
                  subtitle: Text('Customer hotline'),
                ),
                Divider(height: 1),
                ListTile(
                  leading: Icon(Icons.public),
                  title: Text('www.electromart.com'),
                  subtitle: Text('Visit our website'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _header(TextTheme t) {
    return Column(
      children: [
        const CircleAvatar(
          radius: 42,
          child: Icon(Icons.electric_bolt_rounded, size: 40),
        ),
        const SizedBox(height: 12),
        Text(
          'Your Technology Partner',
          style: t.titleLarge?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 8),
        Text(
          'Quality electronics, fair prices, quick delivery — all in one place.',
          textAlign: TextAlign.center,
          style: t.bodyMedium?.copyWith(height: 1.4),
        ),
      ],
    );
  }

  Widget _highlights() {
    return Row(
      children: const [
        Expanded(
          child: _Pill(icon: Icons.verified_outlined, label: 'Genuine'),
        ),
        SizedBox(width: 10),
        Expanded(
          child: _Pill(
            icon: Icons.local_shipping_outlined,
            label: 'Fast Delivery',
          ),
        ),
        SizedBox(width: 10),
        Expanded(
          child: _Pill(
            icon: Icons.support_agent_outlined,
            label: '24/7 Support',
          ),
        ),
      ],
    );
  }
}

class _Pill extends StatelessWidget {
  final IconData icon;
  final String label;
  const _Pill({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(
          context,
        ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).dividerColor.withValues(alpha: 0.15),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon),
          const SizedBox(height: 6),
          Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
