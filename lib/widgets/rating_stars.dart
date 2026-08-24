import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Renders a 5-star rating row. Pass a raw average (e.g. 4.3) from your
/// backend — it's rounded to the nearest whole star for display.
class RatingStars extends StatelessWidget {
  final double rating; // 0.0 - 5.0
  final double size;
  final Color color;
  final bool showValue;

  const RatingStars({
    super.key,
    required this.rating,
    this.size = 16,
    this.color = AppColors.textPrimary,
    this.showValue = false,
  });

  @override
  Widget build(BuildContext context) {
    final rounded = rating.clamp(0, 5).round();
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ...List.generate(5, (i) {
          return Icon(
            i < rounded ? Icons.star : Icons.star_border,
            size: size,
            color: color,
          );
        }),
        if (showValue) ...[
          const SizedBox(width: 4),
          Text(rating.toStringAsFixed(1),
              style: TextStyle(fontSize: size * 0.7, color: AppColors.textSecondary)),
        ],
      ],
    );
  }
}