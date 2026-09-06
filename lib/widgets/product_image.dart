import 'dart:io';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// A placeholder-aware image widget used for every product thumbnail,
/// banner and gallery image in this package.
///
/// HOW TO WIRE UP REAL IMAGES LATER:
/// - Pass [imageUrl] for either a network URL (http/https) OR a local
///   device file path (e.g. from an image picker) -- both are detected
///   automatically and rendered with Image.network / Image.file.
/// - Pass [assetPath] for bundled/local images (e.g. category banners)
///   that ship inside the app itself via pubspec.yaml.
/// - Leaving everything null renders a soft grey placeholder box with an
///   icon -- safe default, never crashes.
///
/// No extra packages required for local files (dart:io covers it). If you
/// later want network caching, swap the `Image.network` call for
/// `CachedNetworkImage` -- the rest of the app won't need to change since
/// everything goes through this one widget.
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
      if (_isNetworkUrl(imageUrl!)) {
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
      } else {
        // Not an http(s) URL, so treat it as a local device file path
        // (e.g. saved from an image picker).
        child = Image.file(
          File(imageUrl!),
          width: width,
          height: height,
          fit: fit,
          errorBuilder: (context, error, stack) => _placeholder(),
        );
      }
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

  bool _isNetworkUrl(String value) {
    final uri = Uri.tryParse(value);
    return uri != null && (uri.scheme == 'http' || uri.scheme == 'https');
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