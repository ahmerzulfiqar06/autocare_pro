// lib/core/theme/app_theme.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // ---- Brand / Accent Colors (keep inside the class) ----
  static const Color primaryBlue    = Color(0xFF1A73E8); // Google Blue - Primary
  static const Color primaryLight   = Color(0xFF4285F4); // Light Blue - Secondary
  static const Color accentGreen    = Color(0xFF34A853); // Success
  static const Color accentOrange   = Color(0xFFFFBC05); // Warning
  static const Color accentRed      = Color(0xFFEA4335); // Error
  static const Color accentPurple   = Color(0xFF9C27B0); // Accent

  // ---- Surfaces / Cards ----
  static const Color surfaceLight   = Color(0xFFFAFAFA);
  static const Color surfaceDark    = Color(0xFF121212);
  static const Color cardLight      = Color(0xFFFFFFFF);
  static const Color cardDark       = Color(0xFF1E1E1E);

  // ---- Light Theme ----
  static ThemeData get lightTheme {
    final base = ThemeData(
      brightness: Brightness.light,
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryBlue,
        brightness: Brightness.light,
      ),
    );

    return base.copyWith(
      textTheme: GoogleFonts.interTextTheme(base.textTheme),
      scaffoldBackgroundColor: surfaceLight,
      cardColor: cardLight,
      snackBarTheme: base.snackBarTheme.copyWith(
        backgroundColor: accentPurple,
        contentTextStyle: GoogleFonts.inter(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
      progressIndicatorTheme: base.progressIndicatorTheme.copyWith(
        color: primaryBlue,
      ),
    );
  }

  // ---- Dark Theme ----
  static ThemeData get darkTheme {
    final base = ThemeData(
      brightness: Brightness.dark,
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryBlue,
        brightness: Brightness.dark,
      ),
    );

    return base.copyWith(
      textTheme: GoogleFonts.interTextTheme(base.textTheme),
      scaffoldBackgroundColor: surfaceDark,
      cardColor: cardDark,
      snackBarTheme: base.snackBarTheme.copyWith(
        backgroundColor: accentPurple,
        contentTextStyle: GoogleFonts.inter(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
      progressIndicatorTheme: base.progressIndicatorTheme.copyWith(
        color: primaryLight,
      ),
    );
  }
}