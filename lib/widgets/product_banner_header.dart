import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'product_image.dart';

/// The dark-gradient banner used on Category and Favorites screens
/// (background shape image + big title + optional subtitle + back button).
///
/// [bannerImageUrl] is the spot to drop in a real category/collection
/// photo later; leave null for the current placeholder gradient look.
class ProductBannerHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String? bannerImageUrl;
  final VoidCallback? onBack;
  final double height;

  const ProductBannerHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.bannerImageUrl,
    this.onBack,
    this.height = 220,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Background — swap for ProductImage(imageUrl: bannerImageUrl)
          // fit: BoxFit.cover once you have a real hardware-store photo.
          // Until then, this renders a dark industrial gradient with a
          // subtle tool-icon texture instead of a plain flat color.
          bannerImageUrl != null
              ? ProductImage(
            imageUrl: bannerImageUrl,
            width: double.infinity,
            height: height,
            borderRadius: BorderRadius.zero,
          )
              : Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.grey900, AppColors.primaryDark],
              ),
            ),
            child: Stack(
              children: const [
                Positioned(
                  top: -10,
                  right: -10,
                  child: Icon(Icons.construction, size: 110, color: Colors.white10),
                ),
                Positioned(
                  bottom: 30,
                  right: 60,
                  child: Icon(Icons.hardware_rounded, size: 70, color: Colors.white10),
                ),
                Positioned(
                  top: 40,
                  left: 140,
                  child: Icon(Icons.build_circle_outlined, size: 50, color: Colors.white10),
                ),
              ],
            ),
          ),
          // Gradient overlay so title text stays legible over any photo.
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.black38, Colors.black26, Colors.black87],
              ),
            ),
          ),
          if (onBack != null)
            Positioned(
              top: 12,
              left: 12,
              child: CircleAvatar(
                backgroundColor: Colors.white70,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
                  onPressed: onBack,
                ),
              ),
            ),
          Positioned(
            left: 20,
            bottom: 20,
            right: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                if (subtitle != null)
                  Text(
                    subtitle!,
                    style: const TextStyle(fontSize: 13, color: Colors.white70),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}