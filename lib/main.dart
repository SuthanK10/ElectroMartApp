import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app_shell.dart';
import 'services/api_service.dart';
import 'screens/cart.dart'; // To access CartStore
import 'screens/login.dart';
import 'screens/register.dart';
import 'screens/product_detail.dart';
import 'theme_controller.dart';

void main() => runApp(const ElectroMartApp());

class ElectroMartApp extends StatelessWidget {
  const ElectroMartApp({super.key});

  @override
  Widget build(BuildContext context) {
    const seed = Color(0xFF25355E);

    final ThemeData light = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: seed,
        brightness: Brightness.light,
      ),
      inputDecorationTheme: const InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderSide: BorderSide(color: seed),
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: seed, width: 1.5),
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: seed, width: 2.5),
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
        labelStyle: TextStyle(
          color: seed,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
        floatingLabelStyle: TextStyle(color: seed, fontWeight: FontWeight.bold),
        prefixIconColor: seed,
        hintStyle: TextStyle(color: Colors.black54),
      ),
      textTheme: const TextTheme(
        bodyLarge: TextStyle(
          color: Colors.black87,
          fontWeight: FontWeight.w500,
        ),
        bodyMedium: TextStyle(
          color: Colors.black87,
          fontWeight: FontWeight.w500,
        ),
      ),
    );

    final ThemeData dark = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: seed,
        brightness: Brightness.dark,
      ),
    );

    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeController.instance.themeMode,
      builder: (_, mode, __) {
        return ChangeNotifierProvider(
          create: (_) => CartStore(),
          child: MaterialApp(
            title: 'ElectroMart',
            debugShowCheckedModeBanner: false,
            theme: light,
            darkTheme: dark,
            themeMode: mode,
            home: const AuthCheck(),
            routes: {
              '/login': (_) => const LoginScreen(),
              '/register': (_) => const RegisterScreen(),
              '/shell': (_) => const AppShell(),
              '/productDetail': (_) => const ProductDetailScreen(),
            },
          ),
        );
      },
    );
  }
}

class AuthCheck extends StatelessWidget {
  const AuthCheck({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: ApiService().loadToken(), // Loads token from SharedPrefs
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        // Check if we have a valid token
        if (ApiService().isAuthenticated) {
          return const AppShell();
        } else {
          return const LoginScreen();
        }
      },
    );
  }
}
