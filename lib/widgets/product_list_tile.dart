import 'package:flutter/material.dart';
import '../models/product.dart';
import '../theme/app_theme.dart';
import 'favorite_button.dart';
import 'price_tag.dart';
import 'product_image.dart';
import 'rating_stars.dart';

/// The horizontal "Item N" row: thumbnail, name, description, price on the
/// left; rating + favorite heart on the right. Reused by the category list,
/// cart, and favorites screens (each just toggles [showCheckbox] on/off).
class ProductListTile extends StatelessWidget {
  final Product product;
  final VoidCallback? onTap;
  final ValueChanged<bool>? onFavoriteChanged;
  final bool showCheckbox;
  final bool checked;
  final ValueChanged<bool?>? onCheckedChanged;
  final bool showDescription;

  const ProductListTile({
    super.key,
    required this.product,
    this.onTap,
    this.onFavoriteChanged,
    this.showCheckbox = false,
    this.checked = false,
    this.onCheckedChanged,
    this.showDescription = true,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (showCheckbox)
              Checkbox(value: checked, onChanged: onCheckedChanged),
            ProductImage(
              imageUrl: product.imageUrl,
              assetPath: product.imageAsset,
              width: 72,
              height: 72,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (showDescription && product.description.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      product.description,
                      style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(height: 4),
                  PriceTag(price: product.price, promoPrice: product.promoPrice),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                RatingStars(rating: product.rating),
                const SizedBox(height: 8),
                if (onFavoriteChanged != null)
                  FavoriteButton(
                    isFavorite: product.isFavorite,
                    onChanged: onFavoriteChanged!,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}