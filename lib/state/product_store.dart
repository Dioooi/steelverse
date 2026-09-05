import 'dart:math';
import 'package:flutter/foundation.dart';
import '../models/cart_item.dart';
import '../models/product.dart';
import '../models/review.dart';

/// A single shared in-memory store so favorite/cart state stays in sync
/// across every screen, instead of each screen holding its own local copy.
class ProductStore extends ChangeNotifier {
  ProductStore._internal();
  static final ProductStore instance = ProductStore._internal();

  final List<Product> _products = [];
  final List<CartItem> _cartItems = [];
  final Map<String, List<Review>> _reviews = {};
  final Set<String> _purchasedProductIds = {};

  List<Product> get products => List.unmodifiable(_products);
  List<CartItem> get cartItems => List.unmodifiable(_cartItems);
  List<Product> get favorites => _products.where((p) => p.isFavorite).toList();

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

  /// All reviews for a product -- seeded (randomized, but stable per
  /// product) reviews plus any real ones submitted via [addReview].
  List<Review> reviewsFor(String productId) =>
      List.unmodifiable(_reviews[productId] ?? const []);

  /// Adds a user-submitted review. Newest first.
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

  /// Deterministic (seeded by product id) so reviews don't reshuffle every
  /// time the same product is reopened, but still vary product to product.
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
  // Purchase tracking (used to gate "write a review" to real buyers)
  // -------------------------------------------------------------------

  bool hasPurchased(String productId) => _purchasedProductIds.contains(productId);

  /// Call this once a payment actually succeeds.
  void recordPurchase(Iterable<String> productIds) {
    _purchasedProductIds.addAll(productIds);
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