import 'package:flutter/material.dart';

abstract final class AppTheme {
  static ThemeData light() {
    const accent = Color(0xFF2B5CF0);
    const ink = Color(0xFF131C33);

    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: accent,
        primary: accent,
        surface: Colors.white,
      ),
      scaffoldBackgroundColor: const Color(0xFFEEF2F9),
      textTheme: ThemeData.light().textTheme.apply(
        bodyColor: ink,
        displayColor: ink,
      ),
    );
  }
}
