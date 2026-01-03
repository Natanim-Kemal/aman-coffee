import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const Color primary = Color(0xFFD47311);
  static const Color backgroundLight = Color(0xFFF5F5F7); // Whitish grey
  static const Color backgroundDark = Color(0xFF221910);
  static const Color surfaceDark = Color(0xFF32261B); // Using the dashboard variant
  static const Color surfaceLight = Color(0xFFFFFFFF);
  
  static const Color textMutedDark = Color(0xFFC9AD92); // "Latte" text
  static const Color textMutedLight = Color(0xFF64748B); // Slate-500 equivalent
  
  static const Color success = Color(0xFF22C55E); // Green-500
  static const Color error = Color(0xFFEF4444); // Red-500
}

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: AppColors.backgroundLight,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        surface: AppColors.surfaceLight,
        onSurface: Colors.black87,
      ),
      textTheme: GoogleFonts.outfitTextTheme().apply(
        bodyColor: Colors.black87,
        displayColor: Colors.black87,
      ),
      iconTheme: const IconThemeData(color: Colors.black87),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: AppColors.backgroundDark,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primary,
        surface: AppColors.surfaceDark,
        onSurface: Colors.white,
      ),
      textTheme: GoogleFonts.outfitTextTheme().apply(
        bodyColor: Colors.white,
        displayColor: Colors.white,
      ),
      iconTheme: const IconThemeData(color: Colors.white),
    );
  }
}
