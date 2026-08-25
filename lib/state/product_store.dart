import 'package:flutter/foundation.dart';
import '../models/product.dart';

/// A single shared in-memory store so favorite/cart state stays in sync
/// across every screen, instead of each screen holding its own local copy.
/// This is a lightweight stand-in for whatever real state management
/// (Provider/Riverpod/Bloc) or backend syncing the full app ends up using.
class ProductStore extends ChangeNotifier {
  ProductStore._internal();
  static final ProductStore instance = ProductStore._internal();

  final List<Product> _products = [];

  List<Product> get products => List.unmodifiable(_products);
  List<Product> get favorites => _products.where((p) => p.isFavorite).toList();

  void setProducts(List<Product> products) {
    _products
      ..clear()
      ..addAll(products);
    notifyListeners();
  }

  void toggleFavorite(String productId, bool isFavorite) {
    final index = _products.indexWhere((p) => p.id == productId);
    if (index == -1) return;
    _products[index] = _products[index].copyWith(isFavorite: isFavorite);
    notifyListeners();
  }
}