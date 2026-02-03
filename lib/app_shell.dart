import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'screens/home.dart';
import 'screens/products.dart';
import 'screens/cart.dart';
import 'screens/about.dart';
import 'screens/profile.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key, this.startIndex = 0}); // 👈 allow starting tab
  final int startIndex;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  late int _index;
  bool _isOffline = false;
  // ignore: unused_field
  StreamSubscription? _sub;

  @override
  void initState() {
    super.initState();
    _index =
        widget.startIndex; // 👈 pick initial tab (0=Home, 1=Products, 2=Cart…)
    _checkConnectivity();
    _sub = Connectivity().onConnectivityChanged.listen((result) {
      _updateStatus(result);
    });
  }

  void _updateStatus(List<ConnectivityResult> results) {
    // connectivity_plus now returns a List<ConnectivityResult>
    final isOffline = results.contains(ConnectivityResult.none);
    setState(() => _isOffline = isOffline);
  }

  Future<void> _checkConnectivity() async {
    final results = await Connectivity().checkConnectivity();
    _updateStatus(results);
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  final _pages = const [
    HomeScreen(),
    ProductsScreen(),
    CartScreen(),
    AboutScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: Column(
        children: [
          if (_isOffline)
            Container(
              width: double.infinity,
              color: Colors.red,
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: const Text(
                'No Internet Connection',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
          Expanded(child: _pages[_index]),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
        backgroundColor: scheme.surface,
        selectedItemColor: scheme.primary,
        unselectedItemColor: scheme.onSurfaceVariant,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.grid_view),
            label: 'Products',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart_outlined),
            label: 'Cart',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.info_outline),
            label: 'About',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
