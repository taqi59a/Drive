import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const Color primary = Color(0xFF1B3A6B);
  static const Color primaryLight = Color(0xFF2D5BB8);
  static const Color primaryDark = Color(0xFF0F2347);

  static const Color accent = Color(0xFFF5A623);
  static const Color accentDeep = Color(0xFFE08A00);
  static const Color accentLight = Color(0xFFFFC55A);

  static const Color success = Color(0xFF2EBD85);
  static const Color successLight = Color(0xFFE6F9F3);
  static const Color error = Color(0xFFE5484D);
  static const Color errorLight = Color(0xFFFEECEC);
  static const Color warning = Color(0xFFF5A623);
  static const Color warningLight = Color(0xFFFFF4E0);

  // Light theme
  static const Color lightBg = Color(0xFFF7F9FC);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightBorder = Color(0xFFE4EAF2);
  static const Color lightTextHigh = Color(0xFF0F1B2D);
  static const Color lightTextMed = Color(0xFF5A6B82);
  static const Color lightTextLow = Color(0xFF9AAABE);

  // Dark theme
  static const Color darkBg = Color(0xFF0B1421);
  static const Color darkSurface = Color(0xFF15233A);
  static const Color darkCard = Color(0xFF1C2E4A);
  static const Color darkBorder = Color(0xFF253A57);
  static const Color darkTextHigh = Color(0xFFEAF1FB);
  static const Color darkTextMed = Color(0xFF9AB0CC);
  static const Color darkTextLow = Color(0xFF5A7191);

  // Gradients
  static const List<Color> brandGradient = [primary, primaryLight];
  static const List<Color> accentGradient = [accent, accentDeep];
  static const List<Color> heroGradient = [Color(0xFF1B3A6B), Color(0xFF0F2347)];
  static const List<Color> successGradient = [Color(0xFF2EBD85), Color(0xFF1A9B6A)];
}
