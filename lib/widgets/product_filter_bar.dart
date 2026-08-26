import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// The filter chip row under the category banner (Figma: "filter 1" /
/// "filter 2", or "Promotion" / "filter 2"). [filters] is dynamic so any
/// dev can pass whatever filter set the backend returns (price, rating,
/// in-stock, brand, etc.) without touching this widget.
class ProductFilterBar extends StatelessWidget {
  final List<String> filters;
  final String? selected;
  final ValueChanged<String> onSelected;
  final VoidCallback? onSlidersTap;

  const ProductFilterBar({
    super.key,
    required this.filters,
    required this.selected,
    required this.onSelected,
    this.onSlidersTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: Row(
        children: [
          InkWell(
            onTap: onSlidersTap,
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 4),
              child: Icon(Icons.tune, color: AppColors.textSecondary),
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: filters.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, i) {
                final filter = filters[i];
                final isSelected = filter == selected;
                return ChoiceChip(
                  label: Text(filter),
                  avatar: isSelected
                      ? const Icon(Icons.check, size: 16, color: AppColors.primaryDark)
                      : null,
                  selected: isSelected,
                  onSelected: (_) => onSelected(filter),
                  selectedColor: AppColors.lilacSelected,
                  backgroundColor: AppColors.lilac,
                  shape: StadiumBorder(
                    side: BorderSide(color: isSelected ? AppColors.primaryDark : Colors.transparent),
                  ),
                  labelStyle: TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}