import 'package:flutter/material.dart';
import 'models/cart_item.dart';
import 'models/product.dart';
import 'models/review.dart';
import 'screens/cart_screen.dart';
import 'screens/category_list_screen.dart';
import 'screens/favorites_screen.dart';
import 'screens/item_detail_screen.dart';
import 'theme/app_theme.dart';
import 'state/product_store.dart';

/// Standalone demo entry point — lets you test/verify your screens in
/// isolation before they're wired into the main app's navigation.
void main() {
  ProductStore.instance.setProducts(_sampleProducts); // seed once at startup
  runApp(const ProductDemoApp());
}

class ProductDemoApp extends StatelessWidget {
  const ProductDemoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Product Pages Demo',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      home: const _DemoLauncher(),
    );
  }
}

// ---------------------------------------------------------------------
// Sample data — replace with real repository/API calls when integrating.
// ---------------------------------------------------------------------
final List<Product> _sampleProducts = List.generate(10, (i) {
  final n = i + 1;
  final hasPromo = n % 2 == 0; // even-numbered items on promo, for demo
  return Product(
    id: 'item_$n',
    name: 'Item $n',
    description: 'Description $n',
    price: 20.0 + n,
    promoPrice: hasPromo ? (20.0 + n) * 0.7 : null,
    rating: 4.0 + (n % 2) * 0.5,
    reviewCount: 12 + n,
    category: 'Hardware Parts',
    isFavorite: n <= 2,
  );
});

final List<Review> _sampleReviews = [
  Review(
    reviewerName: 'Alex T.',
    rating: 5,
    date: DateTime(2026, 6, 12),
    comment: 'Great quality, exactly as described. Fast shipping too.',
  ),
  Review(
    reviewerName: 'Mei L.',
    rating: 4,
    date: DateTime(2026, 5, 30),
    comment: 'Good value for money, would buy again.',
  ),
];

class _DemoLauncher extends StatelessWidget {
  const _DemoLauncher();

  void _push(BuildContext context, Widget screen) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Product Screens Demo')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ElevatedButton(
            onPressed: () => _push(
              context,
                  CategoryListScreen(
                      categoryTitle: 'Category 1',
                      categorySubtitle: 'Subtitle',
                      filters: const ['filter 1', 'filter 2', 'Promotion'],
                      products: ProductStore.instance.products,
                      onLoadMore: () async {
                        await Future.delayed(const Duration(milliseconds: 400));
                        return <Product>[];
                      },
                      onProductTap: (p) => _push(
                      context,
                      ItemDetailScreen(product: p, reviews: _sampleReviews),
                      ),
                      onFavoriteToggle: (p, fav) {
                        ProductStore.instance.toggleFavorite(p.id, fav);
                    },
                ),
            ),
            child: const Text('Category / Browse listing'),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () => _push(
              context,
              ItemDetailScreen(
                product: _sampleProducts.first,
                reviews: _sampleReviews,
                onAddToCart: () => ScaffoldMessenger.of(context)
                    .showSnackBar(const SnackBar(content: Text('Added to cart'))),
                onBuyNow: () => ScaffoldMessenger.of(context)
                    .showSnackBar(const SnackBar(content: Text('Buy now tapped'))),
              ),
            ),
            child: const Text('Item Detail'),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () => _push(
              context,
              CartScreen(
                items: _sampleProducts.take(4).map((p) => CartItem(product: p)).toList(),
                onProceedToPayment: (items) {
                  // Payment is handled by another dev — this is just a stub
                  // so you can confirm the cart hands off the right data.
                  debugPrint('Proceeding to payment with ${items.length} item(s), '
                      'subtotal RM${items.fold<double>(0, (s, i) => s + i.subtotal).toStringAsFixed(2)}');
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Would hand off to Payment here')),
                  );
                },
              ),
            ),
            child: const Text('Cart'),
          ),
          const SizedBox(height: 12),
                  ElevatedButton(
                  onPressed: () => _push(
                  context,
                  FavoritesScreen(favorites: ProductStore.instance.favorites),  // was: _sampleProducts.where(...)
                  ),
                  child: const Text('Favorites'),
                  ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}