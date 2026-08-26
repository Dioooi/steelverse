import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// A placeholder-aware image widget used for every product thumbnail,
/// banner and gallery image in this package.
///
/// HOW TO WIRE UP REAL IMAGES LATER:
/// - Pass [imageUrl] once your backend/CDN returns product photo URLs, OR
/// - Pass [assetPath] for bundled/local images (e.g. category banners).
/// - Leaving both null (current state, matching the low-fi Figma) renders
///   a soft grey placeholder box with an icon — safe default, never crashes.
///
/// No extra packages required. If you later want caching, swap the
/// `Image.network` call for `CachedNetworkImage` — the rest of the app
/// won't need to change since everything goes through this one widget.
class ProductImage extends StatelessWidget {
  final String? imageUrl;
  final String? assetPath;
  final double width;
  final double height;
  final BorderRadius borderRadius;
  final IconData placeholderIcon;
  final BoxFit fit;

  const ProductImage({
    super.key,
    this.imageUrl,
    this.assetPath,
    this.width = 80,
    this.height = 80,
    this.borderRadius = const BorderRadius.all(Radius.circular(14)),
    this.placeholderIcon = Icons.inventory_2_outlined,
    this.fit = BoxFit.cover,
  });

  @override
  Widget build(BuildContext context) {
    Widget child;

    if (imageUrl != null && imageUrl!.isNotEmpty) {
      child = Image.network(
        imageUrl!,
        width: width,
        height: height,
        fit: fit,
        loadingBuilder: (context, widget, progress) {
          if (progress == null) return widget;
          return _placeholder();
        },
        errorBuilder: (context, error, stack) => _placeholder(),
      );
    } else if (assetPath != null && assetPath!.isNotEmpty) {
      child = Image.asset(
        assetPath!,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (context, error, stack) => _placeholder(),
      );
    } else {
      child = _placeholder();
    }

    return ClipRRect(borderRadius: borderRadius, child: child);
  }

  Widget _placeholder() {
    return Container(
      width: width,
      height: height,
      color: AppColors.placeholder,
      alignment: Alignment.center,
      child: Icon(
        placeholderIcon,
        color: AppColors.placeholderIcon,
        size: (width < height ? width : height) * 0.4,
      ),
    );
  }
}