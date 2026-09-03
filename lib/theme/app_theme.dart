// lib/theme/app_theme.dart
import 'package:flutter/material.dart';

class AppColors {
  static const background = Color(0xFFFAF7FC);
  static const surface = Colors.white;
  static const primaryDark = Color(0xFF2B2A2E);
  static const lilac = Color(0xFFE7E1F5);
  static const lilacSelected = Color(0xFFC9BEEA);
  static const placeholder = Color(0xFFE4E0EC);
  static const placeholderIcon = Color(0xFFB3ACC2);
  static const textPrimary = Color(0xFF1F1B24);
  static const textSecondary = Color(0xFF6F6A78);
  static const success = Color(0xFF3A8F4A);
  static const divider = Color(0xFFEAE6F0);
  static const danger = Color(0xFFD64545);

  static const primary = Color(0xFFEE4D2D);
  static const primaryLight = Color(0xFFFF6B4A);
  static const primaryBackground = Color(0xFFFFF0ED);
  static const warning = Color(0xFFFFA726);
  static const info = Color(0xFF2196F3);
  static const grey100 = Color(0xFFF5F5F5);
  static const grey300 = Color(0xFFE0E0E0);
  static const grey600 = Color(0xFF757575);

  // Dark-grey "industrial" palette — used for screens that want a darker,
  // hardware-store feel (e.g. Browse/Category) while product cards
  // themselves stay on the light `surface` color for readability.
  static const darkBackground = Color(0xFF1C1C1E);
  static const darkSurface = Color(0xFF2C2C2E);
  static const darkSurfaceAlt = Color(0xFF3A3A3C);
  static const darkDivider = Color(0xFF48484A);
  static const darkTextPrimary = Color(0xFFF2F2F2);
  static const darkTextSecondary = Color(0xFFA8A8AD);
  static const grey900 = Color(0xFF212121);
}

class AppTheme {
  static ThemeData light() {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primaryDark,
        primary: AppColors.primary,
        surface: AppColors.background,
        error: AppColors.danger,
        // Remove the 'success' parameter - it doesn't exist in fromSeed()
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        centerTitle: false,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(50),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.textPrimary,
          minimumSize: const Size.fromHeight(50),
          side: const BorderSide(color: AppColors.divider),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.lilac,
        selectedItemColor: AppColors.primaryDark,
        unselectedItemColor: AppColors.textSecondary,
        showUnselectedLabels: true,
      ),
      fontFamily: 'Roboto',
    );
  }
}