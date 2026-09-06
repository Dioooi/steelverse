import 'dart:math';
import 'package:flutter/foundation.dart';
import '../models/cart_item.dart';
import '../models/product.dart';
import '../models/review.dart';
import 'product_repository.dart';

class ProductStore extends ChangeNotifier {
  ProductStore._internal();
  static final ProductStore instance = ProductStore._internal();

  final List<Product> _products = [];
  final List<CartItem> _cartItems = [];
  final Map<String, List<Review>> _reviews = {};
  final Set<String> _purchasedProductIds = {};
  final ProductRepository _repository = ProductRepository();

  String? _currentUsername;
  Set<String> _favoriteIds = {};

  List<Product> get products => List.unmodifiable(
    _products.map((p) => p.copyWith(isFavorite: _favoriteIds.contains(p.id))),
  );
  List<CartItem> get cartItems => List.unmodifiable(_cartItems);
  List<Product> get favorites =>
      _products.where((p) => _favoriteIds.contains(p.id)).map((p) => p.copyWith(isFavorite: true)).toList();

  Future<void> setCurrentUser(String username) async {
    _currentUsername = username;
    _favoriteIds = await _repository.getFavoriteIds(username);
    notifyListeners();
  }

  Future<void> init({List<Product> seedProducts = const []}) async {
    if (seedProducts.isNotEmpty) {
      await _repository.seedIfEmpty(seedProducts);
    }
    final loaded = await _repository.getAllProducts();
    _products
      ..clear()
      ..addAll(loaded);
    for (final product in _products) {
      _reviews.putIfAbsent(product.id, () => _generateReviewsFor(product));
    }
    notifyListeners();
  }

  void setProducts(List<Product> products) {
    _products
      ..clear()
      ..addAll(products);
    for (final product in products) {
      _reviews.putIfAbsent(product.id, () => _generateReviewsFor(product));
    }
    notifyListeners();
  }

  List<Review> reviewsFor(String productId) =>
      List.unmodifiable(_reviews[productId] ?? const []);

  void addReview(String productId, Review review) {
    final list = _reviews.putIfAbsent(productId, () => []);
    list.insert(0, review);
    notifyListeners();
  }

  static final List<String> _reviewerPool = [
    'Alex T.', 'Mei L.', 'Farah S.', 'Wei Jian', 'Nurul A.', 'Kumar R.',
    'Siti N.', 'Daniel K.', 'Priya M.', 'Hafiz Z.', 'Chong W.', 'Aisyah R.',
  ];

  static final List<String> _commentPool = [
    'Great quality, exactly as described. Fast shipping too.',
    'Good value for money, would buy again.',
    'Does the job well, no complaints so far.',
    'Sturdy build, feels well made.',
    'Works as expected, packaging could be better.',
    'Exceeded my expectations for the price.',
    'A bit smaller than I imagined but still useful.',
    'Solid purchase, been using it for weeks now.',
    'Exactly what I needed for my project.',
    'Delivery was quick, product matches the photos.',
  ];

  List<Review> _generateReviewsFor(Product product) {
    final random = Random(product.id.hashCode);
    final count = 2 + random.nextInt(3); // 2-4 reviews
    final now = DateTime.now();
    return List.generate(count, (i) {
      final daysAgo = random.nextInt(120) + i * 3;
      final ratingOffset = random.nextInt(3) - 1; // -1, 0, or +1
      final rating = (product.rating + ratingOffset).clamp(1, 5).toDouble();
      return Review(
        reviewerName: _reviewerPool[random.nextInt(_reviewerPool.length)],
        rating: rating,
        date: now.subtract(Duration(days: daysAgo)),
        comment: _commentPool[random.nextInt(_commentPool.length)],
      );
    });
  }

  bool hasPurchased(String productId) => _purchasedProductIds.contains(productId);

  void recordPurchase(Iterable<String> productIds) {
    _purchasedProductIds.addAll(productIds);
    notifyListeners();
  }

  void loadCartFromDatabase(List<CartItem> items) {
    _cartItems
      ..clear()
      ..addAll(items);
    notifyListeners();
  }

  void updateCart(List<CartItem> updatedItems) {
    _cartItems
      ..clear()
      ..addAll(updatedItems);
    notifyListeners();
  }

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

  void removeFromCart(String productId) {
    _cartItems.removeWhere((i) => i.product.id == productId);
    notifyListeners();
  }

  void clearCart() {
    _cartItems.clear();
    notifyListeners();
  }

  Future<void> addProduct(Product product) async {
    await _repository.addProduct(product);
    _products.add(product);
    notifyListeners();
  }

  Future<void> deleteProduct(String productId) async {
    await _repository.deleteProduct(productId);
    _products.removeWhere((p) => p.id == productId);
    _cartItems.removeWhere((i) => i.product.id == productId);
    notifyListeners();
  }

  Future<void> toggleFavorite(String productId, bool isFavorite) async {
    final username = _currentUsername;
    if (username == null) return;
    if (isFavorite) {
      _favoriteIds.add(productId);
    } else {
      _favoriteIds.remove(productId);
    }
    notifyListeners();
    await _repository.setFavorite(username, productId, isFavorite);
  }

  Future<void> updateProduct(Product updatedProduct) async {
    await _repository.updateProduct(updatedProduct);
    final index = _products.indexWhere((p) => p.id == updatedProduct.id);
    if (index != -1) {
      _products[index] = updatedProduct;
      notifyListeners();
    }
  }
}