import 'package:flutter/material.dart';

class ThemeController {
  ThemeController._();
  static final instance = ThemeController._();

  final ValueNotifier<ThemeMode> themeMode = ValueNotifier(ThemeMode.light);

  void setLight() => themeMode.value = ThemeMode.light;
  void setDark()  => themeMode.value = ThemeMode.dark;
}
