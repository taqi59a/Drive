import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTypography {
  AppTypography._();

  static TextTheme lightTextTheme = TextTheme(
    displayLarge: GoogleFonts.plusJakartaSans(
      fontSize: 57, fontWeight: FontWeight.w800, color: AppColors.lightTextHigh, letterSpacing: -1.5,
    ),
    displayMedium: GoogleFonts.plusJakartaSans(
      fontSize: 45, fontWeight: FontWeight.w800, color: AppColors.lightTextHigh, letterSpacing: -1,
    ),
    displaySmall: GoogleFonts.plusJakartaSans(
      fontSize: 36, fontWeight: FontWeight.w700, color: AppColors.lightTextHigh, letterSpacing: -0.5,
    ),
    headlineLarge: GoogleFonts.plusJakartaSans(
      fontSize: 32, fontWeight: FontWeight.w700, color: AppColors.lightTextHigh,
    ),
    headlineMedium: GoogleFonts.plusJakartaSans(
      fontSize: 28, fontWeight: FontWeight.w700, color: AppColors.lightTextHigh,
    ),
    headlineSmall: GoogleFonts.plusJakartaSans(
      fontSize: 24, fontWeight: FontWeight.w600, color: AppColors.lightTextHigh,
    ),
    titleLarge: GoogleFonts.plusJakartaSans(
      fontSize: 22, fontWeight: FontWeight.w600, color: AppColors.lightTextHigh,
    ),
    titleMedium: GoogleFonts.plusJakartaSans(
      fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.lightTextHigh,
    ),
    titleSmall: GoogleFonts.plusJakartaSans(
      fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.lightTextHigh,
    ),
    bodyLarge: GoogleFonts.plusJakartaSans(
      fontSize: 16, fontWeight: FontWeight.w400, color: AppColors.lightTextHigh,
    ),
    bodyMedium: GoogleFonts.plusJakartaSans(
      fontSize: 14, fontWeight: FontWeight.w400, color: AppColors.lightTextMed,
    ),
    bodySmall: GoogleFonts.plusJakartaSans(
      fontSize: 12, fontWeight: FontWeight.w400, color: AppColors.lightTextLow,
    ),
    labelLarge: GoogleFonts.plusJakartaSans(
      fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.lightTextHigh,
    ),
    labelMedium: GoogleFonts.plusJakartaSans(
      fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.lightTextMed,
    ),
    labelSmall: GoogleFonts.plusJakartaSans(
      fontSize: 11, fontWeight: FontWeight.w500, color: AppColors.lightTextLow, letterSpacing: 0.5,
    ),
  );

  static TextTheme darkTextTheme = TextTheme(
    displayLarge: GoogleFonts.plusJakartaSans(
      fontSize: 57, fontWeight: FontWeight.w800, color: AppColors.darkTextHigh, letterSpacing: -1.5,
    ),
    displayMedium: GoogleFonts.plusJakartaSans(
      fontSize: 45, fontWeight: FontWeight.w800, color: AppColors.darkTextHigh, letterSpacing: -1,
    ),
    displaySmall: GoogleFonts.plusJakartaSans(
      fontSize: 36, fontWeight: FontWeight.w700, color: AppColors.darkTextHigh, letterSpacing: -0.5,
    ),
    headlineLarge: GoogleFonts.plusJakartaSans(
      fontSize: 32, fontWeight: FontWeight.w700, color: AppColors.darkTextHigh,
    ),
    headlineMedium: GoogleFonts.plusJakartaSans(
      fontSize: 28, fontWeight: FontWeight.w700, color: AppColors.darkTextHigh,
    ),
    headlineSmall: GoogleFonts.plusJakartaSans(
      fontSize: 24, fontWeight: FontWeight.w600, color: AppColors.darkTextHigh,
    ),
    titleLarge: GoogleFonts.plusJakartaSans(
      fontSize: 22, fontWeight: FontWeight.w600, color: AppColors.darkTextHigh,
    ),
    titleMedium: GoogleFonts.plusJakartaSans(
      fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.darkTextHigh,
    ),
    titleSmall: GoogleFonts.plusJakartaSans(
      fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.darkTextHigh,
    ),
    bodyLarge: GoogleFonts.plusJakartaSans(
      fontSize: 16, fontWeight: FontWeight.w400, color: AppColors.darkTextHigh,
    ),
    bodyMedium: GoogleFonts.plusJakartaSans(
      fontSize: 14, fontWeight: FontWeight.w400, color: AppColors.darkTextMed,
    ),
    bodySmall: GoogleFonts.plusJakartaSans(
      fontSize: 12, fontWeight: FontWeight.w400, color: AppColors.darkTextLow,
    ),
    labelLarge: GoogleFonts.plusJakartaSans(
      fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.darkTextHigh,
    ),
    labelMedium: GoogleFonts.plusJakartaSans(
      fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.darkTextMed,
    ),
    labelSmall: GoogleFonts.plusJakartaSans(
      fontSize: 11, fontWeight: FontWeight.w500, color: AppColors.darkTextLow, letterSpacing: 0.5,
    ),
  );
}
