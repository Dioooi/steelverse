import 'package:flutter/material.dart';
import '../models/product.dart';
import '../models/review.dart';
import '../state/product_store.dart';
import '../theme/app_theme.dart';
import '../widgets/favorite_button.dart';
import '../widgets/price_tag.dart';
import '../widgets/product_image.dart';
import '../widgets/rating_stars.dart';

class ItemDetailScreen extends StatefulWidget {
  final Product product;
  final List<Review> reviews;
  final VoidCallback? onAddToCart;
  final VoidCallback? onBuyNow;
  final ValueChanged<bool>? onFavoriteChanged;
  final VoidCallback? onCartTap;
  final VoidCallback? onShowAllImages;

  const ItemDetailScreen({
    super.key,
    required this.product,
    this.reviews = const [],
    this.onAddToCart,
    this.onBuyNow,
    this.onFavoriteChanged,
    this.onCartTap,
    this.onShowAllImages,
  });

  @override
  State<ItemDetailScreen> createState() => _ItemDetailScreenState();
}

class _ItemDetailScreenState extends State<ItemDetailScreen> {
  late bool _isFavorite;
  int _selectedImageIndex = 0;

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _isFavorite = widget.product.isFavorite;
  }

  @override
  void didUpdateWidget(covariant ItemDetailScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.product.isFavorite != oldWidget.product.isFavorite) {
      setState(() {
        _isFavorite = widget.product.isFavorite;
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _navigateToProduct(Product selectedProduct) {
    FocusScope.of(context).unfocus();
    _searchController.clear();
    setState(() {
      _searchQuery = '';
    });

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => ItemDetailScreen(
          product: selectedProduct,
          reviews: widget.reviews,
          onAddToCart: () {
            ProductStore.instance.addToCart(selectedProduct);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Added ${selectedProduct.name} to cart')),
            );
          },
          onCartTap: widget.onCartTap,
          onFavoriteChanged: (fav) {
            ProductStore.instance.toggleFavorite(selectedProduct.id, fav);
          },
          onBuyNow: widget.onBuyNow,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    final gallery = product.galleryImageUrls.isNotEmpty
        ? product.galleryImageUrls
        : [product.imageUrl ?? ''];

    final allProducts = ProductStore.instance.products;
    final searchResults = _searchQuery.isEmpty
        ? <Product>[]
        : allProducts
        .where((p) =>
    p.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        p.category.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: SizedBox(
          height: 40,
          child: TextField(
            controller: _searchController,
            style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
            onChanged: (val) {
              setState(() {
                _searchQuery = val.trim();
              });
            },
            decoration: InputDecoration(
              hintText: 'Search items...',
              hintStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
              prefixIcon: const Icon(Icons.search, size: 20, color: AppColors.textSecondary),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                icon: const Icon(Icons.clear, size: 18, color: AppColors.textSecondary),
                onPressed: () {
                  _searchController.clear();
                  setState(() {
                    _searchQuery = '';
                  });
                },
              )
                  : null,
              contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
              enabledBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: AppColors.divider),
                borderRadius: BorderRadius.circular(20),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: AppColors.primary),
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart_outlined, color: AppColors.textPrimary),
            onPressed: widget.onCartTap,
          ),
          IconButton(
            icon: const Icon(Icons.more_vert, color: AppColors.textPrimary),
            onPressed: () {},
          ),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 12),

                // Main Image & Thumbnails Rail
                SizedBox(
                  height: 260,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.divider),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: ProductImage(
                              imageUrl: gallery[_selectedImageIndex].isEmpty ? null : gallery[_selectedImageIndex],
                              assetPath: product.imageAsset,
                              width: double.infinity,
                              height: 260,
                              placeholderIcon: Icons.image_outlined,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      SizedBox(
                        width: 60,
                        child: ListView.separated(
                          itemCount: gallery.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 8),
                          itemBuilder: (context, i) {
                            final isSelected = i == _selectedImageIndex;
                            return GestureDetector(
                              onTap: () => setState(() => _selectedImageIndex = i),
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: isSelected ? AppColors.primary : AppColors.divider,
                                    width: isSelected ? 2 : 1,
                                  ),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(6),
                                  child: Opacity(
                                    opacity: isSelected ? 1.0 : 0.6,
                                    child: ProductImage(
                                      imageUrl: gallery[i].isEmpty ? null : gallery[i],
                                      width: 60,
                                      height: 60,
                                      placeholderIcon: Icons.image_outlined,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: widget.onShowAllImages,
                    child: const Text('Show all', style: TextStyle(color: AppColors.primary)),
                  ),
                ),
                const SizedBox(height: 8),
                PriceTag(
                  price: product.price,
                  promoPrice: product.promoPrice,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.primary),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    RatingStars(rating: product.rating, showValue: true),
                    const SizedBox(width: 8),
                    Text(
                      '(${product.reviewCount} reviews)',
                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Description Box
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.divider),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Description:',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        product.description.isNotEmpty ? product.description : 'No description provided yet.',
                        style: const TextStyle(fontSize: 14, height: 1.5, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Reviews Box
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.divider),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Reviews:',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                      ),
                      const SizedBox(height: 12),
                      if (widget.reviews.isEmpty)
                        const Text('No reviews yet.', style: TextStyle(color: AppColors.textSecondary))
                      else
                        ...widget.reviews.map((r) => _ReviewTile(review: r)),
                    ],
                  ),
                ),
                const SizedBox(height: 100),
              ],
            ),
          ),

          // Search Results Overlay
          if (_searchQuery.isNotEmpty)
            Positioned(
              top: 0,
              left: 16,
              right: 16,
              child: Material(
                elevation: 6,
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  constraints: const BoxConstraints(maxHeight: 250),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.divider),
                  ),
                  child: searchResults.isEmpty
                      ? const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text(
                      'No matching products found.',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  )
                      : ListView.separated(
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    itemCount: searchResults.length,
                    separatorBuilder: (_, __) => const Divider(height: 1, color: AppColors.divider),
                    itemBuilder: (context, index) {
                      final p = searchResults[index];
                      return ListTile(
                        leading: const Icon(Icons.build, color: AppColors.primary),
                        title: Text(
                          p.name,
                          style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                        ),
                        subtitle: Text(
                          '\$${p.price.toStringAsFixed(2)} - ${p.category}',
                          style: const TextStyle(color: AppColors.textSecondary),
                        ),
                        onTap: () => _navigateToProduct(p),
                      );
                    },
                  ),
                ),
              ),
            ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          decoration: const BoxDecoration(
            color: AppColors.surface,
            border: Border(top: BorderSide(color: AppColors.divider)),
          ),
          child: Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.divider),
                  borderRadius: BorderRadius.circular(12),
                  color: AppColors.surface,
                ),
                padding: const EdgeInsets.all(8),
                child: FavoriteButton(
                  isFavorite: _isFavorite,
                  onChanged: (fav) {
                    setState(() => _isFavorite = fav);
                    widget.onFavoriteChanged?.call(fav);
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textPrimary,
                    side: const BorderSide(color: AppColors.divider),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                  ),
                  onPressed: widget.onAddToCart,
                  icon: const Icon(Icons.shopping_cart_outlined, size: 18),
                  label: const Text('Add to Cart'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                  ),
                  onPressed: () {
                    widget.onAddToCart?.call();
                    widget.onBuyNow?.call();
                    widget.onCartTap?.call();
                  },
                  child: const Text('Buy now!', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReviewTile extends StatelessWidget {
  final Review review;
  const _ReviewTile({required this.review});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RatingStars(rating: review.rating, size: 14),
          const SizedBox(height: 2),
          Text(
            '(${review.date.day.toString().padLeft(2, '0')} '
                '${_month(review.date.month)} ${review.date.year})',
            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 4),
          Text(review.reviewerName, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppColors.textPrimary)),
          const SizedBox(height: 2),
          Text(review.comment, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
        ],
      ),
    );
  }

  String _month(int m) => const [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
  ][m - 1];
}