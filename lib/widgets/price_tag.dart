import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

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
    final TextStyle baseStyle = style ??
        Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: AppColors.textPrimary,
        ) ??
        const TextStyle(fontSize: 13, color: AppColors.textPrimary);

    final bool hasPromo = promoPrice != null && promoPrice! < price;

    if (!hasPromo) {
      final String label = showLabel ? 'Price : ' : '';
      return Text(
        '$label${_format(price)}',
        style: baseStyle,
      );
    }

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
          const TextSpan(text: '  '),
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