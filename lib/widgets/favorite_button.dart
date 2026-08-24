import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class FavoriteButton extends StatelessWidget {
  final bool isFavorite;
  final ValueChanged<bool> onChanged;
  final double size;

  const FavoriteButton({
    super.key,
    required this.isFavorite,
    required this.onChanged,
    this.size = 22,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(),
      splashRadius: size,
      icon: Icon(
        isFavorite ? Icons.favorite : Icons.favorite_border,
        color: isFavorite ? AppColors.danger : AppColors.textSecondary,
        size: size,
      ),
      onPressed: () => onChanged(!isFavorite),
    );
  }
}