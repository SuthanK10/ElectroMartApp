import 'package:flutter/material.dart';
import 'app_shell.dart';
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
        return MaterialApp(
          title: 'ElectroMart',
          debugShowCheckedModeBanner: false,
          theme: light,
          darkTheme: dark,
          themeMode: mode,           
          initialRoute: '/shell',    
          routes: {
            '/': (_) => const LoginScreen(),
            '/register': (_) => const RegisterScreen(),
            '/shell': (_) => const AppShell(),
            '/productDetail': (_) => const ProductDetailScreen(),
          },
        );
      },
    );
  }
}
