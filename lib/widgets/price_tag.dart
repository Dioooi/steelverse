import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Renders product pricing with optional promo discounts and labels.
///
/// Example:
/// - No promo: "Price : RM20.00"
/// - Promo:    "Price : " ~RM25.00~  "RM20.00"
class PriceTag extends StatelessWidget {
  final double price;
  final double? promoPrice;
  final TextStyle? style;
  final bool showLabel;
  final String currencySymbol;

  const PriceTag({
    super.key,
    required this.price,
    this.promoPrice,
    this.style,
    this.showLabel = true,
    this.currencySymbol = 'RM',
  });

  String _format(double amount) => '$currencySymbol${amount.toStringAsFixed(2)}';

  @override
  Widget build(BuildContext context) {
    // Inherits base text style from theme context if not provided
    final TextStyle baseStyle = style ??
        Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: AppColors.textPrimary,
        ) ??
        const TextStyle(fontSize: 13, color: AppColors.textPrimary);

    final bool hasPromo = promoPrice != null && promoPrice! < price;

    // Fast path: Single Text widget for standard pricing
    if (!hasPromo) {
      final String label = showLabel ? 'Price : ' : '';
      return Text(
        '$label${_format(price)}',
        style: baseStyle,
      );
    }

    // Single RichText pipeline for promo pricing
    return Text.rich(
      TextSpan(
        style: baseStyle,
        children: [
          if (showLabel)
            const TextSpan(text: 'Price : '),
          TextSpan(
            text: _format(price),
            style: TextStyle(
              decoration: TextDecoration.lineThrough,
              decorationColor: AppColors.textSecondary,
              color: AppColors.textSecondary,
            ),
          ),
          const TextSpan(text: '  '), // Replaces SizedBox spacing
          TextSpan(
            text: _format(promoPrice!),
            style: TextStyle(
              color: AppColors.success,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      semanticsLabel: showLabel
          ? 'Original price ${_format(price)}, discounted price ${_format(promoPrice!)}'
          : null,
    );
  }
}