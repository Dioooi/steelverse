import 'package:flutter/material.dart';
import '../models/product.dart';
import '../models/review.dart';
import '../theme/app_theme.dart';
import '../widgets/favorite_button.dart';
import '../widgets/price_tag.dart';
import '../widgets/product_image.dart';
import '../widgets/rating_stars.dart';

/// Corresponds to the "Item X" screen: main image + thumbnail strip with
/// "Show all", description block, reviews list, and a bottom action bar
/// (favorite / Add to Cart / Buy now).
///
/// [product.galleryImageUrls] drives the thumbnail strip — leave it empty
/// during development and a single placeholder + a couple of empty
/// placeholder slots are shown, matching the Figma's greyscale mock.
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

  @override
  void initState() {
    super.initState();
    _isFavorite = widget.product.isFavorite;
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    final gallery = product.galleryImageUrls.isNotEmpty
        ? product.galleryImageUrls
        : [product.imageUrl ?? ''];

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
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
        actions: [
          IconButton(icon: const Icon(Icons.shopping_cart_outlined), onPressed: widget.onCartTap),
          IconButton(icon: const Icon(Icons.more_vert), onPressed: () {}),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(product.name,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),

            // Main image + vertical thumbnail rail.
            SizedBox(
              height: 260,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: ProductImage(
                      imageUrl: gallery[_selectedImageIndex].isEmpty
                          ? null
                          : gallery[_selectedImageIndex],
                      assetPath: product.imageAsset,
                      width: double.infinity,
                      height: 260,
                      placeholderIcon: Icons.image_outlined,
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 60,
                    child: ListView.separated(
                      itemCount: gallery.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, i) {
                        return GestureDetector(
                          onTap: () => setState(() => _selectedImageIndex = i),
                          child: Opacity(
                            opacity: i == _selectedImageIndex ? 1 : 0.6,
                            child: ProductImage(
                              imageUrl: gallery[i].isEmpty ? null : gallery[i],
                              width: 60,
                              height: 60,
                              placeholderIcon: Icons.image_outlined,
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
                child: const Text('Show all'),
              ),
            ),
            const SizedBox(height: 8),
            PriceTag(
              price: product.price,
              promoPrice: product.promoPrice,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                RatingStars(rating: product.rating, showValue: true),
                const SizedBox(width: 8),
                Text('(${product.reviewCount} reviews)',
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
              ],
            ),
            const SizedBox(height: 20),

            const Text('Description:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(
              product.description.isNotEmpty
                  ? product.description
                  : 'No description provided yet.',
              style: const TextStyle(fontSize: 14, height: 1.5, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 24),

            const Text('Review:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            if (widget.reviews.isEmpty)
              const Text('No reviews yet.', style: TextStyle(color: AppColors.textSecondary))
            else
              ...widget.reviews.map((r) => _ReviewTile(review: r)),
            const SizedBox(height: 100), // leave room for bottom action bar
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.divider),
                  borderRadius: BorderRadius.circular(12),
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
                  onPressed: widget.onAddToCart,
                  icon: const Icon(Icons.shopping_cart_outlined),
                  label: const Text('Add to Cart'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton(
                  onPressed: widget.onBuyNow,
                  child: const Text('Buy now!'),
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
      padding: const EdgeInsets.only(bottom: 16),
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
          Text(review.reviewerName, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
          const SizedBox(height: 2),
          Text(review.comment, style: const TextStyle(fontSize: 13)),
        ],
      ),
    );
  }

  String _month(int m) => const [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
  ][m - 1];
}