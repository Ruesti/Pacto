import 'package:flutter/material.dart';

class AppColors {
  // Hintergründe
  static const background = Color(0xFF0A0A0F);
  static const surfaceCard = Color(0xFF15151E);
  static const surfaceElevated = Color(0xFF1C1C28);
  static const surfaceBorder = Color(0x1AFFFFFF); // 10% white

  // Primärfarbe
  static const primary = Color(0xFF7C5CE7);
  static const primaryLight = Color(0x267C5CE7); // 15% opacity

  // Text
  static const textPrimary = Color(0xFFFFFFFF);
  static const textSecondary = Color(0x99FFFFFF); // 60% white
  static const textTertiary = Color(0x4DFFFFFF); // 30% white

  // Status
  static const statusGreen = Color(0xFF00C896);
  static const statusGreenBg = Color(0x1A00C896);
  static const statusAmber = Color(0xFFFFB020);
  static const statusAmberBg = Color(0x1AFFB020);
  static const statusBlue = Color(0xFF4A9EFF);
  static const statusBlueBg = Color(0x1A4A9EFF);
  static const statusRed = Color(0xFFFF5A5A);
  static const statusRedBg = Color(0x1AFF5A5A);

  // Hero-Overlay
  static const heroGradientTop = Color(0x00000000);
  static const heroGradientBottom = Color(0xFF0A0A0F);

  // Kategorie-Farben (für Pill, Icon-Hintergrund)
  static const Map<String, Color> categoryFg = {
    'streaming': Color(0xFFFF6B9D),
    'versicherung': Color(0xFF4A9EFF),
    'handy': Color(0xFF00C896),
    'internet': Color(0xFFB57BFF),
    'software': Color(0xFF00BCD4),
    'fitness': Color(0xFFFFB020),
    'zeitung': Color(0xFFFF8A65),
    'sonstiges': Color(0xFF78909C),
  };

  static const Map<String, Color> categoryBg = {
    'streaming': Color(0x1AFF6B9D),
    'versicherung': Color(0x1A4A9EFF),
    'handy': Color(0x1A00C896),
    'internet': Color(0x1AB57BFF),
    'software': Color(0x1A00BCD4),
    'fitness': Color(0x1AFFB020),
    'zeitung': Color(0x1AFF8A65),
    'sonstiges': Color(0x1A78909C),
  };
}
