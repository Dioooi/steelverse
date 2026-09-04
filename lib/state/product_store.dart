import 'package:flutter/foundation.dart';
import '../models/cart_item.dart';
import '../models/product.dart';

/// A single shared in-memory store so favorite/cart state stays in sync
/// across every screen, instead of each screen holding its own local copy.
class ProductStore extends ChangeNotifier {
  ProductStore._internal();
  static final ProductStore instance = ProductStore._internal();

  final List<Product> _products = [];
  final List<CartItem> _cartItems = [];

  List<Product> get products => List.unmodifiable(_products);
  List<CartItem> get cartItems => List.unmodifiable(_cartItems);
  List<Product> get favorites => _products.where((p) => p.isFavorite).toList();

  void setProducts(List<Product> products) {
    _products
      ..clear()
      ..addAll(products);
    notifyListeners();
  }

  // -------------------------------------------------------------------
  // Inventory Management Methods (Admin Actions)
  // -------------------------------------------------------------------

  /// Adds a new product to the catalog.
  void addProduct(Product product) {
    _products.add(product);
    notifyListeners();
  }

  /// Removes a product from the catalog by ID and removes it from cart/favorites if present.
  void deleteProduct(String productId) {
    _products.removeWhere((p) => p.id == productId);
    _cartItems.removeWhere((i) => i.product.id == productId);
    notifyListeners();
  }

  void toggleFavorite(String productId, bool isFavorite) {
    final index = _products.indexWhere((p) => p.id == productId);
    if (index == -1) return;
    _products[index] = _products[index].copyWith(isFavorite: isFavorite);
    notifyListeners();
  }

  // -------------------------------------------------------------------
  // Cart Management Methods
  // -------------------------------------------------------------------

  /// Replaces the current cart list with updated items (e.g., from CartScreen edits).
  void updateCart(List<CartItem> updatedItems) {
    _cartItems
      ..clear()
      ..addAll(updatedItems);
    notifyListeners();
  }

  /// Adds a single product to the cart or increments its quantity if present.
  void addToCart(Product product) {
    final index = _cartItems.indexWhere((i) => i.product.id == product.id);
    if (index != -1) {
      final existing = _cartItems[index];
      _cartItems[index] = CartItem(
        product: existing.product,
        quantity: existing.quantity + 1,
        selected: existing.selected,
      );
    } else {
      _cartItems.add(CartItem(product: product));
    }
    notifyListeners();
  }

  /// Removes an item by product ID.
  void removeFromCart(String productId) {
    _cartItems.removeWhere((i) => i.product.id == productId);
    notifyListeners();
  }

  /// Clears all items from the cart.
  void clearCart() {
    _cartItems.clear();
    notifyListeners();
  }

  void updateProduct(Product updatedProduct) {
    final index = _products.indexWhere((p) => p.id == updatedProduct.id);
    if (index != -1) {
      _products[index] = updatedProduct;
      notifyListeners();
    }
  }
}