import 'package:flutter/material.dart';

class AppTheme {
  static const _seed = Color(0xFF1A6B3C);

  static ThemeData get light => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: _seed),
        appBarTheme: const AppBarTheme(centerTitle: false, elevation: 0),
        cardTheme: CardThemeData(
          elevation: 0,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          color: const Color(0xFFF5F5F5),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          filled: true,
        ),
      );

  static const categoryColors = <String, Color>{
    'streaming': Color(0xFFE53935),
    'versicherung': Color(0xFF1565C0),
    'handy': Color(0xFF2E7D32),
    'internet': Color(0xFF6A1B9A),
    'software': Color(0xFF00838F),
    'fitness': Color(0xFFEF6C00),
    'zeitung': Color(0xFF5D4037),
    'sonstiges': Color(0xFF546E7A),
  };
}
