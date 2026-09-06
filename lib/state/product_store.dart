import 'dart:math';
import 'package:flutter/foundation.dart';
import '../models/cart_item.dart';
import '../models/product.dart';
import '../models/review.dart';
import '../login/database_helper.dart';
import 'product_repository.dart';

/// A single shared in-memory store so favorite/cart state stays in sync
/// across every screen, instead of each screen holding its own local copy.
class ProductStore extends ChangeNotifier {
  ProductStore._internal();
  static final ProductStore instance = ProductStore._internal();

  final List<Product> _products = [];
  final List<CartItem> _cartItems = [];
  final Map<String, List<Review>> _reviews = {};
  final Set<String> _purchasedProductIds = {};
  final ProductRepository _repository = ProductRepository();

  String _currentUsername = 'User';

  // Alias getter so AdminPage explicitly receives all items
  List<Product> get allProducts => List.unmodifiable(_products);
  List<Product> get products => List.unmodifiable(_products);
  List<CartItem> get cartItems => List.unmodifiable(_cartItems);
  List<Product> get favorites => _products.where((p) => p.isFavorite).toList();

  /// Call this once, at app startup, instead of setProducts().
  Future<void> init({List<Product> seedProducts = const []}) async {
    if (seedProducts.isNotEmpty) {
      await _repository.seedIfEmpty(seedProducts);
    }
    final loaded = await _repository.getAllProducts();

    // Favorites are kept local/session-only, preserving whatever is set
    final favoriteIds = _products.where((p) => p.isFavorite).map((p) => p.id).toSet();
    _products
      ..clear()
      ..addAll(loaded.map((p) => p.copyWith(isFavorite: favoriteIds.contains(p.id))));
    for (final product in _products) {
      _reviews.putIfAbsent(product.id, () => _generateReviewsFor(product));
    }
    notifyListeners();
  }

  /// Sets the active logged-in user for persistent storage.
  void setCurrentUser(String username) {
    _currentUsername = username;
  }

  /// Loads cart items directly from SQLite for the active user without triggering a rewrite.
  void loadCartFromDatabase(List<CartItem> cart) {
    _cartItems
      ..clear()
      ..addAll(cart);
    notifyListeners();
  }

  /// Legacy manual override -- prefer init() now that products live in the local database.
  void setProducts(List<Product> products) {
    _products
      ..clear()
      ..addAll(products);
    for (final product in products) {
      _reviews.putIfAbsent(product.id, () => _generateReviewsFor(product));
    }
    notifyListeners();
  }

  // -------------------------------------------------------------------
  // Reviews
  // -------------------------------------------------------------------

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

  // -------------------------------------------------------------------
  // Purchase tracking
  // -------------------------------------------------------------------

  bool hasPurchased(String productId) => _purchasedProductIds.contains(productId);

  void recordPurchase(Iterable<String> productIds) {
    _purchasedProductIds.addAll(productIds);
    notifyListeners();
  }

  // -------------------------------------------------------------------
  // Inventory Management Methods (Admin Actions)
  // -------------------------------------------------------------------

  Future<void> addProduct(Product product) async {
    await _repository.addProduct(product);
    _products.add(product);
    _reviews.putIfAbsent(product.id, () => _generateReviewsFor(product));
    notifyListeners();
  }

  Future<void> deleteProduct(String productId) async {
    await _repository.deleteProduct(productId);
    _products.removeWhere((p) => p.id == productId);
    _cartItems.removeWhere((i) => i.product.id == productId);
    _reviews.remove(productId);
    DatabaseHelper.instance.saveUserCart(_currentUsername, _cartItems);
    notifyListeners();
  }

  void toggleFavorite(String productId, bool isFavorite) {
    final index = _products.indexWhere((p) => p.id == productId);
    if (index == -1) return;
    _products[index] = _products[index].copyWith(isFavorite: isFavorite);
    notifyListeners();
  }

  Future<void> updateProduct(Product updatedProduct) async {
    await _repository.updateProduct(updatedProduct);
    final index = _products.indexWhere((p) => p.id == updatedProduct.id);
    if (index != -1) {
      _products[index] = updatedProduct.copyWith(isFavorite: _products[index].isFavorite);
      notifyListeners();
    }
  }

  // -------------------------------------------------------------------
  // Cart Management Methods (With SQLite Persistence)
  // -------------------------------------------------------------------

  /// Replaces current cart items and syncs with SQLite database.
  void updateCart(List<CartItem> updatedItems) {
    _cartItems
      ..clear()
      ..addAll(updatedItems);
    DatabaseHelper.instance.saveUserCart(_currentUsername, _cartItems);
    notifyListeners();
  }

  /// Adds a single product or increments quantity, then syncs to SQLite.
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
    DatabaseHelper.instance.saveUserCart(_currentUsername, _cartItems);
    notifyListeners();
  }

  /// Removes an item by product ID and updates SQLite.
  void removeFromCart(String productId) {
    _cartItems.removeWhere((i) => i.product.id == productId);
    DatabaseHelper.instance.saveUserCart(_currentUsername, _cartItems);
    notifyListeners();
  }

  /// Clears all cart items and updates SQLite.
  void clearCart() {
    _cartItems.clear();
    DatabaseHelper.instance.saveUserCart(_currentUsername, _cartItems);
    notifyListeners();
  }
}