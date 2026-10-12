import 'package:flutter/material.dart';

/// "Forest" palette used by every screen.
class AppColors {
  static const Color deepForest = Color(0xFF081C15); // darkest text
  static const Color forest = Color(0xFF1B4332); // headings
  static const Color leaf = Color(0xFF2D6A4F); // main accent
  static const Color emerald = Color(0xFF40916C); // secondary accent
  static const Color sage = Color(0xFF52B788); // highlights
  static const Color mint = Color(0xFFB7E4C7); // soft chips, badges
  static const Color cream = Color(0xFFF4FAF5); // page background
  static const Color card = Colors.white;
  static const Color muted = Color(0xFF5F7A6B); // secondary text
  static const Color danger = Color(0xFFC0563F); // errors, delete
  static const Color dangerSoft = Color(0xFFF6D5CC);
}

/// Gradients shared by every screen so the whole app feels like one design.
class AppGradients {
  /// AppBars, hero headers, primary buttons.
  static const LinearGradient primary = LinearGradient(
    colors: [Color(0xFF0B3D2E), Color(0xFF1B6B4A), Color(0xFF3FA36B)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Badges, FAB, small highlights.
  static const LinearGradient accent = LinearGradient(
    colors: [Color(0xFF52B788), Color(0xFF2D9D78)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// "Already saved" state.
  static const LinearGradient soft = LinearGradient(
    colors: [Color(0xFFD8F3DC), Color(0xFFB7E4C7)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Delete / error state.
  static const LinearGradient danger = LinearGradient(
    colors: [Color(0xFFE07A5F), Color(0xFFC0563F)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Subtle page background.
  static const LinearGradient background = LinearGradient(
    colors: [Color(0xFFF4FAF5), Color(0xFFE3F1E6)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}

class AppTheme {
  static ThemeData get theme {
    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.leaf,
      primary: AppColors.leaf,
      secondary: AppColors.sage,
      surface: AppColors.cream,
      error: AppColors.danger,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      fontFamily: 'Roboto',
      scaffoldBackgroundColor: AppColors.cream,

      // AppBars are transparent; the gradient is drawn by GradientAppBar.
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontFamily: 'Roboto',
          fontSize: 21,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.4,
          color: Colors.white,
        ),
      ),

      textTheme: const TextTheme(
        headlineMedium: TextStyle(
          fontSize: 26,
          fontWeight: FontWeight.w800,
          height: 1.2,
          color: Colors.white,
        ),
        headlineSmall: TextStyle(
          fontSize: 23,
          fontWeight: FontWeight.w800,
          height: 1.3,
          color: Colors.white,
        ),
        titleMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: AppColors.deepForest,
          height: 1.3,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          height: 1.75,
          color: AppColors.deepForest,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          height: 1.4,
          color: AppColors.muted,
        ),
        labelSmall: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.4,
          color: AppColors.emerald,
        ),
      ),

      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.leaf,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
          shape: const StadiumBorder(),
          textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: AppColors.leaf),
      ),

      dialogTheme: DialogThemeData(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
        titleTextStyle: const TextStyle(
          fontFamily: 'Roboto',
          fontSize: 20,
          fontWeight: FontWeight.w800,
          color: AppColors.forest,
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.cream,
        labelStyle: const TextStyle(color: AppColors.muted),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.mint, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.leaf, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.danger, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.danger, width: 2),
        ),
      ),

      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.forest,
        contentTextStyle: const TextStyle(color: Colors.white, fontSize: 14),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),

      progressIndicatorTheme:
          const ProgressIndicatorThemeData(color: AppColors.leaf),
    );
  }
}