import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Matches the Figma "Price : $$" / "Price : $$$ $$" pattern:
/// - No promo -> "Price : RM20.00"
/// - Promo    -> original struck through in grey, promo price in green.
///
/// Currency symbol/format lives in one place ([_format]) so it's easy to
/// localize later (e.g. swap 'RM' for a locale-aware NumberFormat).
class PriceTag extends StatelessWidget {
  final double price;
  final double? promoPrice;
  final TextStyle? style;
  final bool showLabel;

  const PriceTag({
    super.key,
    required this.price,
    this.promoPrice,
    this.style,
    this.showLabel = true,
  });

  String _format(double v) => 'RM${v.toStringAsFixed(2)}';

  @override
  Widget build(BuildContext context) {
    final base = style ?? const TextStyle(fontSize: 13, color: AppColors.textPrimary);
    final label = showLabel ? 'Price : ' : '';
    final hasPromo = promoPrice != null && promoPrice! < price;

    if (!hasPromo) {
      return Text('$label${_format(price)}', style: base);
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label.isNotEmpty) Text(label, style: base),
        Text(
          _format(price),
          style: base.copyWith(
            decoration: TextDecoration.lineThrough,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          _format(promoPrice!),
          style: base.copyWith(color: AppColors.success, fontWeight: FontWeight.w700),
        ),
      ],
    );
  }
}