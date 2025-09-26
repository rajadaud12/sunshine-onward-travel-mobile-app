import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Global light & dark themes using Poppins font and AppColors.
class AppTheme {
  static final _poppins = GoogleFonts.poppinsTextTheme();

  static final TextTheme _lightTextTheme = _poppins.copyWith(
    titleLarge: _poppins.titleLarge?.copyWith(
      fontSize: 28,
      fontWeight: FontWeight.w600, // SemiBold for titles
      height: 1.14,
      letterSpacing: 0.24,
    ),
    bodyMedium: _poppins.bodyMedium?.copyWith(
      fontSize: 16,
      fontWeight: FontWeight.w400, // Regular for descriptions
      height: 1.33,
    ),
  );

  static ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: AppColors.primary,
    scaffoldBackgroundColor: AppColors.white,
    cardColor: AppColors.card,
    fontFamily: GoogleFonts.poppins().fontFamily,
    colorScheme: const ColorScheme.light(
      primary: AppColors.primary,
      secondary: AppColors.textSecondary,
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

  // Dark theme kept minimal for now
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
