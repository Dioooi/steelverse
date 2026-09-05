import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// The bottom "Home / Browse / Profile" nav bar seen throughout the Figma.
/// [currentIndex] and [onTap] are left for whoever owns app-wide navigation
/// (likely wired to a shared IndexedStack/GoRouter by another dev) — this
/// widget is purely presentational so it can be dropped into any screen.
class AppBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const AppBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      backgroundColor: AppColors.lilac,
      currentIndex: currentIndex,
      onTap: onTap,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: AppColors.primaryDark,
      unselectedItemColor: AppColors.textSecondary,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.storefront_outlined), label: 'Browse'),
        BottomNavigationBarItem(icon: Icon(Icons.favorite_border), label: 'Favorites'),
      ],
    );
  }
}