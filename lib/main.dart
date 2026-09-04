// main.dart
import 'package:flutter/material.dart';
import 'models/cart_item.dart';
import 'models/product.dart';
import 'models/review.dart';
import 'models/user.dart';
import 'screens/cart_screen.dart';
import 'screens/category_list_screen.dart';
import 'screens/favorites_screen.dart';
import 'screens/item_detail_screen.dart';
import 'theme/app_theme.dart';
import 'state/product_store.dart';
import 'login/welcome_page.dart';
import 'screens/profile_page.dart';
import 'widgets/app_bottom_nav.dart';

void main() {
  ProductStore.instance.setProducts(_sampleProducts);
  ProductStore.instance.updateCart([]);
  runApp(const ProductDemoApp());
}

class ProductDemoApp extends StatelessWidget {
  const ProductDemoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Steelverse Hardware Store',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      home: const WelcomePage(),
    );
  }
}

// Curated hardware + furniture catalog. Only a subset has a matching real
// photo (imageUrl) for now -- the rest fall back to ProductImage's neutral
// placeholder rather than risk a mismatched or broken hotlinked photo.
// Swap in imageUrl/imageAsset per item as real product photography becomes
// available; nothing else needs to change.
final List<Product> _sampleProducts = [
  Product(
    id: 'item_1',
    name: 'Claw Hammer 16oz',
    description: 'Forged steel head, fiberglass handle, reduced vibration.',
    price: 21.0,
    rating: 5.0,
    reviewCount: 34,
    category: 'Hardware Parts',
    isFavorite: true,
    imageUrl: 'https://images.unsplash.com/photo-1542583633-aa0b0e378e2e?fm=jpg&q=80&w=400&fit=crop&auto=format',
  ),
  Product(
    id: 'item_2',
    name: 'Cordless Drill Driver',
    description: '20V lithium-ion, 2-speed, built-in LED work light.',
    price: 22.0,
    promoPrice: 15.4,
    rating: 4.0,
    reviewCount: 51,
    category: 'Hardware Parts',
    isFavorite: true,
    imageUrl: 'https://images.unsplash.com/photo-1593307315564-c96172dc89dc?fm=jpg&q=80&w=400&fit=crop&auto=format',
  ),
  Product(
    id: 'item_3',
    name: 'Adjustable Wrench Set (3-Piece)',
    description: 'Chrome vanadium steel, fits tight and awkward fittings.',
    price: 23.0,
    rating: 5.0,
    reviewCount: 27,
    category: 'Hardware Parts',
    imageUrl: 'https://images.unsplash.com/photo-1650501662347-284973714a68?fm=jpg&q=80&w=400&fit=crop&auto=format',
  ),
  Product(
    id: 'item_4',
    name: 'Stainless Steel Screw Assortment (500pc)',
    description: 'Mixed sizes for wood, metal and drywall projects.',
    price: 24.0,
    promoPrice: 16.8,
    rating: 4.0,
    reviewCount: 19,
    category: 'Hardware Parts',
    imageUrl: 'https://images.unsplash.com/photo-1704732061018-3ac738176c20?fm=jpg&q=80&w=400&fit=crop&auto=format',
  ),
  Product(
    id: 'item_5',
    name: 'Heavy-Duty Tool Box, 24"',
    description: 'Lockable steel tool box with a removable tray.',
    price: 25.0,
    rating: 5.0,
    reviewCount: 22,
    category: 'Hardware Parts',
  ),
  Product(
    id: 'item_6',
    name: 'Oak Bookshelf, 5-Tier',
    description: 'Solid oak bookshelf with a natural wood finish.',
    price: 26.0,
    promoPrice: 18.2,
    rating: 4.0,
    reviewCount: 15,
    category: 'Furniture',
    imageUrl: 'https://images.unsplash.com/photo-1620388639945-990753377b58?fm=jpg&q=80&w=400&fit=crop&auto=format',
  ),
  Product(
    id: 'item_7',
    name: 'Ergonomic Office Chair',
    description: 'Mesh back, adjustable lumbar support and armrests.',
    price: 27.0,
    rating: 5.0,
    reviewCount: 40,
    category: 'Furniture',
    imageUrl: 'https://images.unsplash.com/photo-1688578735352-9a6f2ac3b70a?fm=jpg&q=80&w=400&fit=crop&auto=format',
  ),
  Product(
    id: 'item_8',
    name: 'Foldable Steel Workbench',
    description: 'Portable workbench, 300kg load capacity, quick-fold legs.',
    price: 28.0,
    promoPrice: 19.6,
    rating: 4.0,
    reviewCount: 12,
    category: 'Hardware Parts',
  ),
  Product(
    id: 'item_9',
    name: 'Outdoor Rattan Patio Table Set',
    description: 'Weather-resistant table and 4 chairs for the patio.',
    price: 29.0,
    rating: 5.0,
    reviewCount: 8,
    category: 'Furniture',
    imageUrl: 'https://images.unsplash.com/photo-1719324923613-ff0884b031ed?fm=jpg&q=80&w=400&fit=crop&auto=format',
  ),
  Product(
    id: 'item_10',
    name: 'Rechargeable LED Work Light',
    description: '3000-lumen work light with adjustable folding stand.',
    price: 30.0,
    promoPrice: 21.0,
    rating: 4.0,
    reviewCount: 17,
    category: 'Hardware Parts',
  ),
];

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

// Default user for the app
final User defaultUser = User(
  name: 'Lee Jia Cheng',
  phone: '(+60) 11-7281 2642',
  address: 'B 134, Ground Floor, Pusat Komersil Semambu, 25350 Kuantan',
  balance: 45.65,
  pin: '123456',
);

class HomeScreen extends StatefulWidget {
  final String username;

  const HomeScreen({super.key, this.username = 'User'});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _push(BuildContext context, Widget screen) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));
  }

  void _openCart(BuildContext context) {
    _push(
      context,
      CartScreen(
        items: ProductStore.instance.cartItems,
        user: defaultUser,
        onCartUpdated: (updatedItems) {
          ProductStore.instance.updateCart(updatedItems);
        },
      ),
    );
  }

  Widget _buildItemDetailScreen(BuildContext context, Product product) {
    return ItemDetailScreen(
      product: product,
      reviews: _sampleReviews,
      onAddToCart: () {
        ProductStore.instance.addToCart(product);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Added ${product.name} to cart')),
        );
      },
      onCartTap: () => _openCart(context),
      onFavoriteChanged: (fav) {
        ProductStore.instance.toggleFavorite(product.id, fav);
      },
      onBuyNow: () => ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Buy now tapped')),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Image with Dark Overlay
          Positioned.fill(
            child: Image.asset(
              'assets/pic store.webp',
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: Container(
              color: Colors.black.withValues(alpha: 0.75),
            ),
          ),
          // Main Content wrapped in AnimatedBuilder to automatically listen for store updates
          SafeArea(
            child: AnimatedBuilder(
              animation: ProductStore.instance,
              builder: (context, _) {
                final products = ProductStore.instance.products;

                // Filter products based on search input
                final searchResults = _searchQuery.isEmpty
                    ? <Product>[]
                    : products
                    .where((p) =>
                p.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                    p.category.toLowerCase().contains(_searchQuery.toLowerCase()))
                    .toList();

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // App Header with Search Bar, Cart, and Profile Icon
                      Row(
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.build_circle_rounded, color: Colors.orangeAccent, size: 36),
                              SizedBox(width: 8),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'STEELVERSE',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w400,
                                      letterSpacing: 1.2,
                                    ),
                                  ),
                                  Text(
                                    'Hardware Store',
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(width: 12),

                          // Search Bar in Header
                          Expanded(
                            child: SizedBox(
                              height: 40,
                              child: TextField(
                                controller: _searchController,
                                style: const TextStyle(color: Colors.white, fontSize: 13),
                                onChanged: (val) {
                                  setState(() {
                                    _searchQuery = val.trim();
                                  });
                                },
                                decoration: InputDecoration(
                                  hintText: 'Search...',
                                  hintStyle: const TextStyle(color: Colors.white54, fontSize: 13),
                                  prefixIcon: const Icon(Icons.search, color: Colors.orangeAccent, size: 18),
                                  suffixIcon: _searchQuery.isNotEmpty
                                      ? IconButton(
                                    icon: const Icon(Icons.clear, color: Colors.white54, size: 16),
                                    onPressed: () {
                                      _searchController.clear();
                                      setState(() {
                                        _searchQuery = '';
                                      });
                                    },
                                  )
                                      : null,
                                  filled: true,
                                  fillColor: Colors.white.withValues(alpha: 0.12),
                                  contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 10),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(20),
                                    borderSide: const BorderSide(color: Colors.white24),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(20),
                                    borderSide: const BorderSide(color: Colors.orangeAccent),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            icon: const Icon(Icons.shopping_cart_outlined, color: Colors.white, size: 26),
                            onPressed: () => _openCart(context),
                          ),
                          const SizedBox(width: 12),
                          IconButton(
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            icon: const Icon(Icons.person_outline, color: Colors.white, size: 26),
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => ProfilePage(username: widget.username),
                                ),
                              );
                            },
                          ),
                        ],
                      ),

                      // Search Results Dropdown overlay under Header
                      if (_searchQuery.isNotEmpty) ...[
                        const SizedBox(height: 10),
                        Container(
                          height: 250,
                          decoration: BoxDecoration(
                            color: const Color(0xFF1E1E1E),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.white24),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.5),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: searchResults.isEmpty
                              ? const Padding(
                            padding: EdgeInsets.all(16),
                            child: Text(
                              'No matching products found.',
                              style: TextStyle(color: Colors.white54),
                            ),
                          )
                              : ListView.separated(
                            shrinkWrap: true,
                            itemCount: searchResults.length,
                            separatorBuilder: (_, __) => const Divider(color: Colors.white10, height: 1),
                            itemBuilder: (context, index) {
                              final product = searchResults[index];
                              return ListTile(
                                leading: const Icon(Icons.build, color: Colors.orangeAccent),
                                title: Text(
                                  product.name,
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                ),
                                subtitle: Text(
                                  '\$${product.price.toStringAsFixed(2)} - ${product.category}',
                                  style: const TextStyle(color: Colors.white70),
                                ),
                                onTap: () {
                                  FocusScope.of(context).unfocus();
                                  _push(context, _buildItemDetailScreen(context, product));
                                },
                              );
                            },
                          ),
                        ),
                      ],
                      const SizedBox(height: 24),

                      // Hero Banner Card
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          gradient: LinearGradient(
                            colors: [Colors.orange.shade800, Colors.deepOrange.shade600],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.3),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            )
                          ],
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'PRO HARDWARE & TOOLS',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  const Text(
                                    'Equip your workshop with heavy-duty components.',
                                    style: TextStyle(color: Colors.white70, fontSize: 13),
                                  ),
                                  const SizedBox(height: 12),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.white,
                                      foregroundColor: Colors.black,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    onPressed: () => _push(
                                      context,
                                      CategoryListScreen(
                                        categoryTitle: 'Hardware Parts',
                                        categorySubtitle: 'All Tools & Supplies',
                                        filters: const ['filter 1', 'filter 2', 'Promotion'],
                                        products: products,
                                        onLoadMore: () async {
                                          await Future.delayed(const Duration(milliseconds: 400));
                                          return <Product>[];
                                        },
                                        onProductTap: (p) => _push(
                                          context,
                                          _buildItemDetailScreen(context, p),
                                        ),
                                        onFavoriteToggle: (p, fav) {
                                          ProductStore.instance.toggleFavorite(p.id, fav);
                                        },
                                        username: widget.username,
                                      ),
                                    ),
                                    child: const Text('Browse Catalog'),
                                  )
                                ],
                              ),
                            ),
                            const Icon(Icons.handyman_rounded, color: Colors.white38, size: 70),
                          ],
                        ),
                      ),
                      const SizedBox(height: 28),

                      const Text(
                        'Quick Navigation',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Single Row Navigation Menu
                      Row(
                        children: [
                          Expanded(
                            child: _MenuTile(
                              title: 'Categories',
                              subtitle: 'Browse',
                              icon: Icons.category_outlined,
                              color: Colors.blueAccent,
                              onTap: () => _push(
                                context,
                                CategoryListScreen(
                                  categoryTitle: 'Hardware Parts',
                                  categorySubtitle: 'Everything you need, built to last.',
                                  filters: const ['filter 1', 'filter 2', 'Promotion'],
                                  products: products,
                                  onLoadMore: () async {
                                    await Future.delayed(const Duration(milliseconds: 400));
                                    return <Product>[];
                                  },
                                  onProductTap: (p) => _push(
                                    context,
                                    _buildItemDetailScreen(context, p),
                                  ),
                                  onFavoriteToggle: (p, fav) {
                                    ProductStore.instance.toggleFavorite(p.id, fav);
                                  },
                                  username: widget.username,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _MenuTile(
                              title: 'Featured',
                              subtitle: 'Item details',
                              icon: Icons.star_outline_rounded,
                              color: Colors.amber.shade700,
                              onTap: () {
                                if (products.isNotEmpty) {
                                  _push(context, _buildItemDetailScreen(context, products.first));
                                }
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _MenuTile(
                              title: 'My Cart',
                              subtitle: '${ProductStore.instance.cartItems.fold<int>(0, (sum, i) => sum + i.quantity)} items',
                              icon: Icons.shopping_bag_outlined,
                              color: Colors.green,
                              onTap: () => _openCart(context),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _MenuTile(
                              title: 'Favorites',
                              subtitle: '${ProductStore.instance.favorites.length} saved',
                              icon: Icons.favorite_outline_rounded,
                              color: Colors.redAccent,
                              onTap: () => _push(
                                context,
                                FavoritesScreen(favorites: ProductStore.instance.favorites, username: widget.username),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 28),

                      // Horizontal Featured Items Carousel
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Featured Products',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextButton(
                            onPressed: () => _push(
                              context,
                              CategoryListScreen(
                                categoryTitle: 'Hardware Parts',
                                categorySubtitle: 'Everything you need, built to last.',
                                filters: const ['filter 1', 'filter 2', 'Promotion'],
                                products: products,
                                onLoadMore: () async => <Product>[],
                                onProductTap: (p) => _push(context, _buildItemDetailScreen(context, p)),
                                onFavoriteToggle: (p, fav) => ProductStore.instance.toggleFavorite(p.id, fav),
                                username: widget.username,
                              ),
                            ),
                            child: const Text('See All', style: TextStyle(color: Colors.orangeAccent)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 205,
                        child: products.isEmpty
                            ? const Center(
                          child: Text('No featured products', style: TextStyle(color: Colors.white54)),
                        )
                            : ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: products.length,
                          itemBuilder: (context, index) {
                            final p = products[index];
                            return _HorizontalProductCard(
                              product: p,
                              onTap: () => _push(context, _buildItemDetailScreen(context, p)),
                              onAddToCart: () {
                                ProductStore.instance.addToCart(p);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Added ${p.name} to cart')),
                                );
                              },
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 28),

                      // Product Grid Listing
                      const Text(
                        'Available Products',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 14),
                      products.isEmpty
                          ? const Center(
                        child: Padding(
                          padding: EdgeInsets.all(24.0),
                          child: Text(
                            'No items currently available.',
                            style: TextStyle(color: Colors.white54),
                          ),
                        ),
                      )
                          : GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: products.length,
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 14,
                          mainAxisSpacing: 14,
                          childAspectRatio: 0.78,
                        ),
                        itemBuilder: (context, index) {
                          final p = products[index];
                          return _GridProductCard(
                            product: p,
                            onTap: () => _push(context, _buildItemDetailScreen(context, p)),
                            onAddToCart: () {
                              ProductStore.instance.addToCart(p);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Added ${p.name} to cart')),
                              );
                            },
                          );
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: AppBottomNav(
        currentIndex: 0, // Home tab is active on this screen
        onTap: (index) {
          switch (index) {
            case 0: // Home — already here, nothing to do
              break;
            case 1: // Browse
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => CategoryListScreen(
                    categoryTitle: 'Hardware Parts',
                    categorySubtitle: 'Everything you need, built to last.',
                    products: ProductStore.instance.products,
                    onLoadMore: () async => <Product>[],
                    onProductTap: (p) => _push(context, _buildItemDetailScreen(context, p)),
                    onFavoriteToggle: (p, fav) => ProductStore.instance.toggleFavorite(p.id, fav),
                    username: widget.username,
                  ),
                ),
              );
              break;
            case 2: // Favorites
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => FavoritesScreen(
                    favorites: ProductStore.instance.favorites,
                    username: widget.username,
                  ),
                ),
              );
              break;
            case 3: // Profile
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => ProfilePage(username: widget.username)),
              );
              break;
          }
        },
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _MenuTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white24),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: color.withValues(alpha: 0.2),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white60,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HorizontalProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onTap;
  final VoidCallback onAddToCart;

  const _HorizontalProductCard({
    required this.product,
    required this.onTap,
    required this.onAddToCart,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150,
      margin: const EdgeInsets.only(right: 12),
      child: Card(
        color: Colors.white.withValues(alpha: 0.12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 70,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white10,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.hardware, color: Colors.orangeAccent, size: 38),
                ),
                const SizedBox(height: 8),
                Text(
                  product.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
                Text(
                  '\$${product.price.toStringAsFixed(2)}',
                  style: const TextStyle(color: Colors.orangeAccent, fontWeight: FontWeight.w600),
                ),
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  height: 30,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orangeAccent,
                      padding: EdgeInsets.zero,
                    ),
                    onPressed: onAddToCart,
                    child: const Text('Add', style: TextStyle(fontSize: 12, color: Colors.black)),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _GridProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onTap;
  final VoidCallback onAddToCart;

  const _GridProductCard({
    required this.product,
    required this.onTap,
    required this.onAddToCart,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white.withValues(alpha: 0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.build_rounded, color: Colors.white70, size: 40),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                product.name,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
              ),
              Text(
                product.category,
                style: const TextStyle(color: Colors.white54, fontSize: 11),
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '\$${product.price.toStringAsFixed(2)}',
                    style: const TextStyle(color: Colors.orangeAccent, fontWeight: FontWeight.bold),
                  ),
                  InkWell(
                    onTap: onAddToCart,
                    child: const CircleAvatar(
                      radius: 14,
                      backgroundColor: Colors.orangeAccent,
                      child: Icon(Icons.add_shopping_cart, size: 14, color: Colors.black),
                    ),
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}