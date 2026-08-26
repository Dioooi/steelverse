import 'package:flutter/material.dart';

/// Colors pulled from the low-fidelity Figma (soft lilac backgrounds,
/// near-black CTA buttons, muted grey placeholders). Swap these out once
/// final brand colors are confirmed — every screen/widget in this package
/// reads from here rather than hardcoding hex values.
class AppColors {
  static const background = Color(0xFFFAF7FC);
  static const surface = Colors.white;
  static const primaryDark = Color(0xFF2B2A2E); // buttons e.g. "Login", "Submit"
  static const lilac = Color(0xFFE7E1F5); // bottom nav / pill backgrounds
  static const lilacSelected = Color(0xFFC9BEEA);
  static const placeholder = Color(0xFFE4E0EC);
  static const placeholderIcon = Color(0xFFB3ACC2);
  static const textPrimary = Color(0xFF1F1B24);
  static const textSecondary = Color(0xFF6F6A78);
  static const success = Color(0xFF3A8F4A);
  static const divider = Color(0xFFEAE6F0);
  static const danger = Color(0xFFD64545);
}

class AppTheme {
  static ThemeData light() {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primaryDark,
        primary: AppColors.primaryDark,
        surface: AppColors.background,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        centerTitle: false,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryDark,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(50),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
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