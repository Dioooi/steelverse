import 'package:flutter/material.dart';
import '../models/cart_item.dart';
import '../theme/app_theme.dart';
import '../widgets/product_list_tile.dart';

/// Corresponds to the "Cart" screen: per-item checkbox, favorite heart,
/// select-all + subtotal footer, "Proceed Payment" CTA.
class CartScreen extends StatefulWidget {
  final List<CartItem> items;
  final void Function(List<CartItem> selectedItems)? onProceedToPayment;
  final void Function(CartItem item, bool isFavorite)? onFavoriteToggle;

  const CartScreen({
    super.key,
    required this.items,
    this.onProceedToPayment,
    this.onFavoriteToggle,
  });

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  late List<CartItem> _items;

  @override
  void initState() {
    super.initState();
    _items = List.of(widget.items);
  }

  bool get _allSelected => _items.isNotEmpty && _items.every((i) => i.selected);

  double get _subtotal => _items
      .where((i) => i.selected)
      .fold(0.0, (sum, i) => sum + i.subtotal);

  void _toggleSelectAll(bool? value) {
    setState(() {
      for (final item in _items) {
        item.selected = value ?? false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Container(
          height: 40,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.divider),
            borderRadius: BorderRadius.circular(20),
          ),
          alignment: Alignment.centerLeft,
          child: const Text('Search', style: TextStyle(color: AppColors.textSecondary)),
        ),
      ),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Row(
              children: [
                Text('Cart', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          Expanded(
            child: _items.isEmpty
                ? const Center(
              child: Text('Your cart is empty', style: TextStyle(color: AppColors.textSecondary)),
            )
                : ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _items.length,
              separatorBuilder: (_, __) => const Divider(height: 1, color: AppColors.divider),
              itemBuilder: (context, i) {
                final item = _items[i];
                return ProductListTile(
                  product: item.product,
                  showCheckbox: true,
                  checked: item.selected,
                  onCheckedChanged: (v) => setState(() => item.selected = v ?? false),
                  onFavoriteChanged: (fav) {
                    setState(() {
                      _items[i] = CartItem(
                        product: item.product.copyWith(isFavorite: fav),
                        quantity: item.quantity,
                        selected: item.selected,
                      );
                    });
                    widget.onFavoriteToggle?.call(item, fav);
                  },
                );
              },
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: Column(
                children: [
                  Row(
                    children: [
                      Checkbox(value: _allSelected, onChanged: _toggleSelectAll),
                      const Text('Select all'),
                      const Spacer(),
                      Text('Subtotal : RM${_subtotal.toStringAsFixed(2)}',
                          style: const TextStyle(fontWeight: FontWeight.w600)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: _items.any((i) => i.selected)
                        ? () => widget.onProceedToPayment
                        ?.call(_items.where((i) => i.selected).toList())
                        : null,
                    child: const Text('Proceed Payment'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}