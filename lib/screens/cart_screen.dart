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
  final void Function(List<CartItem> updatedItems)? onCartUpdated;

  const CartScreen({
    super.key,
    required this.items,
    this.onProceedToPayment,
    this.onFavoriteToggle,
    this.onCartUpdated,
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

  @override
  void didUpdateWidget(covariant CartScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.items != oldWidget.items) {
      _items = List.of(widget.items);
    }
  }

  void _notifyParent() {
    widget.onCartUpdated?.call(List.of(_items));
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
    _notifyParent();
  }

  void _removeItem(int index) {
    setState(() {
      _items.removeAt(index);
    });
    _notifyParent();
  }

  void _updateQuantity(int index, int newQuantity) {
    if (newQuantity <= 0) {
      _removeItem(index);
    } else {
      setState(() {
        _items[index] = CartItem(
          product: _items[index].product,
          quantity: newQuantity,
          selected: _items[index].selected,
        );
      });
      _notifyParent();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).maybePop(),
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
                return Dismissible(
                  key: ValueKey(item.product.id),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  onDismissed: (_) => _removeItem(i),
                  child: Row(
                    children: [
                      Expanded(
                        child: ProductListTile(
                          product: item.product,
                          showCheckbox: true,
                          checked: item.selected,
                          onCheckedChanged: (v) {
                            setState(() => item.selected = v ?? false);
                            _notifyParent();
                          },
                          onFavoriteChanged: (fav) {
                            setState(() {
                              _items[i] = CartItem(
                                product: item.product.copyWith(isFavorite: fav),
                                quantity: item.quantity,
                                selected: item.selected,
                              );
                            });
                            widget.onFavoriteToggle?.call(item, fav);
                            _notifyParent();
                          },
                        ),
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove_circle_outline, size: 20),
                            onPressed: () => _updateQuantity(i, item.quantity - 1),
                          ),
                          Text('${item.quantity}'),
                          IconButton(
                            icon: const Icon(Icons.add_circle_outline, size: 20),
                            onPressed: () => _updateQuantity(i, item.quantity + 1),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline, color: Colors.red),
                            onPressed: () => _removeItem(i),
                          ),
                        ],
                      ),
                    ],
                  ),
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
                      Text(
                        'Subtotal : RM${_subtotal.toStringAsFixed(2)}',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _items.any((i) => i.selected)
                          ? () => widget.onProceedToPayment
                          ?.call(_items.where((i) => i.selected).toList())
                          : null,
                      child: const Text('Proceed Payment'),
                    ),
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