import 'package:flutter/material.dart';
import '../models/product.dart';
import '../theme/app_theme.dart';
import 'favorite_button.dart';
import 'price_tag.dart';
import 'product_image.dart';
import 'rating_stars.dart';

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
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (showCheckbox)
              SizedBox(
                width: 28,
                height: 28,
                child: Checkbox(
                  value: checked,
                  onChanged: onCheckedChanged,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
            ProductImage(
              imageUrl: product.imageUrl,
              assetPath: product.imageAsset,
              width: 56,
              height: 56,
            ),
            const SizedBox(width: 8),
            // Text Column with FittedBoxes to scale down long content automatically
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    product.name,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: RatingStars(rating: product.rating),
                  ),
                  if (showDescription && product.description.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      product.description,
                      style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(height: 4),
                  // Forces PriceTag to shrink if promo price text is too long
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: PriceTag(price: product.price, promoPrice: product.promoPrice),
                  ),
                  if (onFavoriteChanged != null) ...[
                    const SizedBox(height: 4),
                    FavoriteButton(
                      isFavorite: product.isFavorite,
                      onChanged: onFavoriteChanged!,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}