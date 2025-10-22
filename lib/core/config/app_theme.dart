// lib/core/config/app_theme.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTheme {
  static final _poppins = GoogleFonts.poppinsTextTheme();

  static final TextTheme _lightTextTheme = _poppins.copyWith(
    titleLarge: _poppins.titleLarge?.copyWith(
      fontSize: 28,
      fontWeight: FontWeight.w600,
      height: 1.14,
      letterSpacing: 0.24,
    ),
    bodyMedium: _poppins.bodyMedium?.copyWith(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      height: 1.33,
    ),
  );

  static ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    // Use AppCompat-compatible base theme
    applyElevationOverlayColor: true, // Ensures compatibility with AppCompat
    primaryColor: AppColors.primary,
    scaffoldBackgroundColor: AppColors.white,
    cardColor: AppColors.card,
    fontFamily: GoogleFonts.poppins().fontFamily,
    colorScheme: ColorScheme.fromSwatch(
      primarySwatch: createMaterialColor(AppColors.primary), // Convert color to MaterialColor
      accentColor: AppColors.textSecondary,
    ).copyWith(
      surface: AppColors.card,
      onSurface: AppColors.textSecondary,
    ),
    textTheme: _lightTextTheme,
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.card,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.primary),
      ),
      hintStyle: const TextStyle(color: AppColors.placeholder),
    ),
  );

  // Helper function to create MaterialColor from a color
  static MaterialColor createMaterialColor(Color color) {
    List strengths = <double>[.05];
    Map<int, Color> swatch = {};
    final int r = color.red, g = color.green, b = color.blue;

    for (int i = 1; i < 10; i++) {
      strengths.add(0.1 * i);
    }
    for (var strength in strengths) {
      final double ds = 0.5 - strength;
      swatch[(strength * 1000).round()] = Color.fromRGBO(
        r + ((ds < 0 ? r : (255 - r)) * ds).round(),
        g + ((ds < 0 ? g : (255 - g)) * ds).round(),
        b + ((ds < 0 ? b : (255 - b)) * ds).round(),
        1,
      );
    }
    return MaterialColor(color.value, swatch);
  }

  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: AppColors.primary,
    scaffoldBackgroundColor: Colors.black,
    cardColor: const Color(0xFF1E1E1E),
    fontFamily: GoogleFonts.poppins().fontFamily,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.primary,
      secondary: AppColors.textSecondary,
    ),
    textTheme: GoogleFonts.poppinsTextTheme().apply(
      bodyColor: Colors.white,
      displayColor: Colors.white,
    ),
  );
}