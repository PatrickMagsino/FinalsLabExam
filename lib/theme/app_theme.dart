import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Pastel green palette (chunky "game UI" style) used by every screen.
class AppColors {
  static const Color background = Color(0xFFD6E29B); // page background
  static const Color outline = Color(0xFF2E4A10); // thick dark outlines + text
  static const Color depth = Color(0xFF56781F); // 3D layer under buttons
  static const Color primary = Color(0xFFA3C63F); // buttons, panels
  static const Color panel = Color(0xFFB2CF68); // softer panel green
  static const Color tile = Color(0xFFD4E98B); // list rows, tiles
  static const Color cream = Color(0xFFEFFBB8); // highlights, badges, pills
  static const Color text = Color(0xFF2E4A10);
  static const Color muted = Color(0xFF5E7434);
  static const Color danger = Color(0xFFEDA085); // delete, errors
  static const Color dangerDepth = Color(0xFF9C4F38);
  static const Color dangerText = Color(0xFF6E2A17);
}

class AppTheme {
  /// Rounded "Fredoka" font used everywhere.
  static TextStyle font({
    double size = 16,
    FontWeight weight = FontWeight.w500,
    Color color = AppColors.text,
    double? height,
    double? letterSpacing,
  }) {
    return GoogleFonts.fredoka(
      fontSize: size,
      fontWeight: weight,
      color: color,
      height: height,
      letterSpacing: letterSpacing,
    );
  }

  static ThemeData get theme {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        primary: AppColors.depth,
        surface: AppColors.background,
        error: AppColors.dangerDepth,
      ),
      scaffoldBackgroundColor: AppColors.background,
    );

    return base.copyWith(
      // Fonts: Fredoka for all text.
      textTheme: GoogleFonts.fredokaTextTheme(base.textTheme).apply(
        bodyColor: AppColors.text,
        displayColor: AppColors.text,
      ),

      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.background,
        surfaceTintColor: Colors.transparent,
        foregroundColor: AppColors.text,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        toolbarHeight: 84,
      ),

      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.background,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(26),
          side: const BorderSide(color: AppColors.outline, width: 3),
        ),
        titleTextStyle: font(size: 22, weight: FontWeight.w600),
        contentTextStyle: font(size: 15, weight: FontWeight.w400),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.cream,
        labelStyle: font(size: 15, color: AppColors.muted),
        hintStyle: font(size: 15, weight: FontWeight.w400, color: AppColors.muted),
        floatingLabelStyle: font(size: 15, weight: FontWeight.w600),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.outline, width: 2.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.depth, width: 3),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.dangerDepth, width: 2.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.dangerDepth, width: 3),
        ),
        errorStyle: font(size: 13, color: AppColors.dangerDepth),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.outline,
          textStyle: font(size: 16, weight: FontWeight.w600),
        ),
      ),

      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.outline,
        contentTextStyle: font(size: 15, color: AppColors.cream),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),

      progressIndicatorTheme:
          const ProgressIndicatorThemeData(color: AppColors.depth),
    );
  }
}