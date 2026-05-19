import 'package:flutter/material.dart';

class AppTheme {
  static const Color colorLife = Color(0xFF4CAF50);
  static const Color colorBuffer = Color(0xFF2196F3);
  static const Color colorVault = Color(0xFF9C27B0);
  static const Color colorBills = Color(0xFFFF9800);
  static const Color colorIncome = Color(0xFF00BCD4);

  static ThemeData get dark => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorSchemeSeed: const Color(0xFF1DB954),
        scaffoldBackgroundColor: const Color(0xFF121212),
        cardTheme: const CardThemeData(
          color: Color(0xFF1E1E1E),
          elevation: 0,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF121212),
          scrolledUnderElevation: 0,
        ),
      );
}
