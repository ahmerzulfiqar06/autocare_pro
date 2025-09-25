import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
static final lightTheme = ThemeData(
    textTheme: GoogleFonts.interTextTheme(),
    primarySwatch: Colors.blue,
    brightness: Brightness.light,
  );

static final darkTheme = ThemeData(
    textTheme: GoogleFonts.interTextTheme(),
    brightness: Brightness.dark,
  );
}

  // Modern Professional Color Palette (Google Material 3 inspired)
  static const Color primaryBlue = Color(0xFF1A73E8);      // Google Blue - Primary
  static const Color primaryLight = Color(0xFF4285F4);     // Light Blue - Secondary
  static const Color accentGreen = Color(0xFF34A853);      // Success Green
  static const Color accentOrange = Color(0xFFFBBC05);     // Warning Orange
  static const Color accentRed = Color(0xFFEA4335);        // Error Red
  static const Color accentPurple = Color(0xFF9C27B0);     // Accent Purple

  // Neutral Colors
  static const Color surfaceLight = Color(0xFFFAFAFA);
  static const Color surfaceDark = Color(0xFF121212);
  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color cardDark = Color(0xFF1E1E1E);

  // Light theme
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,

      // Enhanced Color scheme with Material 3
      colorScheme: const ColorScheme.light(
        primary: primaryBlue,
        onPrimary: Colors.white,
        primaryContainer: Color(0xFFE3F2FD),
        onPrimaryContainer: Color(0xFF0D47A1),

        secondary: accentGreen,
        onSecondary: Colors.white,
        secondaryContainer: Color(0xFFE8F5E8),
        onSecondaryContainer: Color(0xFF1B5E20),

        tertiary: accentPurple,
        onTertiary: Colors.white,
        tertiaryContainer: Color(0xFFF3E5F5),
        onTertiaryContainer: Color(0xFF4A148C),

        error: accentRed,
        onError: Colors.white,
        errorContainer: Color(0xFFFCE8E6),
        onErrorContainer: Color(0xFFB71C1C),

        surface: cardLight,
        onSurface: Color(0xFF1C1B1F),
        onSurfaceVariant: Color(0xFF49454F),

        outline: Color(0xFF79747E),
        outlineVariant: Color(0xFFCAC4D0),

        shadow: Color(0xFF000000),
        scrim: Color(0xFF000000),

        surfaceTint: primaryBlue,
      ),

      // Typography with modern fonts
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.w700,
          color: Colors.black87,
          fontFamily: 'Inter',
          letterSpacing: -0.5,
        ),
        headlineMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
          fontFamily: 'Inter',
          letterSpacing: -0.25,
        ),
        headlineSmall: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
          fontFamily: 'Inter',
        ),
        titleLarge: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
          fontFamily: 'Inter',
        ),
        titleMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Colors.black87,
          fontFamily: 'Inter',
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: Colors.black87,
          fontFamily: 'Inter',
          height: 1.5,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: Colors.black87,
          fontFamily: 'Inter',
          height: 1.4,
        ),
        labelLarge: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Colors.black87,
          fontFamily: 'Inter',
        ),
      ).apply(
        displayColor: Colors.black87,
        bodyColor: Colors.black87,
      ),

      // Enhanced AppBar with modern styling
      appBarTheme: const AppBarTheme(
        backgroundColor: surfaceLight,
        foregroundColor: Color(0xFF1C1B1F),
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.transparent,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Color(0xFF1C1B1F),
        ),
      ),

      // Modern Card theme with subtle shadows
      cardTheme: CardTheme(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        color: cardLight,
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),

      // Button themes
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),

      // Input decoration theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFF5F5F5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: primaryBlue, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),

      // Floating action button theme
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primaryBlue,
        foregroundColor: Colors.white,
      ),

      // Bottom navigation bar theme
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: primaryBlue,
        unselectedItemColor: Colors.black54,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
    );
  }

  // Dark theme
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,

      // Color scheme
      colorScheme: const ColorScheme.dark(
        primary: primaryLight,
        secondary: accentGreen,
        tertiary: accentPurple,
        error: accentRed,
        surface: cardDark,
        onSurface: Color(0xFFE6E1E5),
        onSurfaceVariant: Color(0xFFCAC4D0),
      ),

      // Typography with modern fonts
      textTheme: ThemeData.dark().textTheme.copyWith(
        headlineLarge: const TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.w700,
          color: Colors.white,
          fontFamily: 'Inter',
          letterSpacing: -0.5,
        ),
        headlineMedium: const TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w600,
          color: Colors.white,
          fontFamily: 'Inter',
          letterSpacing: -0.25,
        ),
        headlineSmall: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: Colors.white,
          fontFamily: 'Inter',
        ),
        titleLarge: const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: Colors.white,
          fontFamily: 'Inter',
        ),
        titleMedium: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Colors.white,
          fontFamily: 'Inter',
        ),
        bodyLarge: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: Colors.white,
          fontFamily: 'Inter',
          height: 1.5,
        ),
        bodyMedium: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: Colors.white,
          fontFamily: 'Inter',
          height: 1.4,
        ),
        labelLarge: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Colors.white,
          fontFamily: 'Inter',
        ),
      ).apply(
        displayColor: Colors.white,
        bodyColor: Colors.white,
      ),

      // App bar theme
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF1E1E1E),
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),

      // Card theme
      cardTheme: CardTheme(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        color: const Color(0xFF1E1E1E),
      ),

      // Button themes
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),

      // Input decoration theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF2A2A2A),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF404040)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF42A5F5), width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),

      // Floating action button theme
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: Color(0xFF42A5F5),
        foregroundColor: Colors.white,
      ),

      // Bottom navigation bar theme
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Color(0xFF1E1E1E),
        selectedItemColor: Color(0xFF42A5F5),
        unselectedItemColor: Colors.white70,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
    );
  }
}
