import 'package:flutter/material.dart';

/// Paleta de ConfirmaU tomada del logo y de los mockups.
class AppColors {
  AppColors._();

  static const Color primary = Color(0xFF0F7B4F);
  static const Color primaryDark = Color(0xFF0A5C3B);
  static const Color primaryLight = Color(0xFF1E9560);
  static const Color accent = Color(0xFF45AD4A); // la "U" del logo
  static const Color primaryDisabled = Color(0xFF80B9A0);

  static const Color background = Color(0xFFF5F5F5);
  static const Color border = Color(0xFFE3E5E8);
  static const Color textPrimary = Color(0xFF1F2933);
  static const Color textMuted = Color(0xFF6B7280);
  static const Color hint = Color(0xFF9CA3AF);
  static const Color error = Color(0xFFD32F2F);
}

class AppTheme {
  AppTheme._();

  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        primary: AppColors.primary,
      ),
      scaffoldBackgroundColor: AppColors.background,
      snackBarTheme: const SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
