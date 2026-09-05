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
  /// Legacy/unused for display now -- reviews are sourced live from
  /// ProductStore.instance.reviewsFor(product.id) instead, since every
  /// product used to be forced to share this exact same list.
  final List<Review> reviews;
  final String username;
  final VoidCallback? onAddToCart;
  final VoidCallback? onBuyNow;
  final ValueChanged<bool>? onFavoriteChanged;
  final VoidCallback? onCartTap;
  final VoidCallback? onShowAllImages;

  const ItemDetailScreen({
    super.key,
    required this.product,
    this.reviews = const [],
    this.username = 'You',
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
          username: widget.username,
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

  void _openGallery(BuildContext context, List<String> gallery) {
    Navigator.of(context).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => _GalleryViewer(
          images: gallery,
          initialIndex: _selectedImageIndex,
          productName: widget.product.name,
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

    return AnimatedBuilder(
      animation: ProductStore.instance,
      builder: (context, _) {
        final reviews = ProductStore.instance.reviewsFor(product.id);
        final canReview = ProductStore.instance.hasPurchased(product.id);
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
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 640),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          product.name,
                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                        ),
                        const SizedBox(height: 12),

                        // Main Image & Thumbnails Rail
                        SizedBox(
                          height: 300,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: AspectRatio(
                                  aspectRatio: 1, // square product photo, not a wide banner
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
                                        height: double.infinity,
                                        placeholderIcon: Icons.image_outlined,
                                      ),
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
                        if (gallery.length > 1)
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: widget.onShowAllImages ?? () => _openGallery(context, gallery),
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
                        Wrap(
                          crossAxisAlignment: WrapCrossAlignment.center,
                          spacing: 8,
                          runSpacing: 4,
                          children: [
                            RatingStars(rating: product.rating, showValue: true),
                            Text(
                              // Uses the actual review list length, not
                              // product.reviewCount -- that stat is independent
                              // sample data and previously didn't match what was
                              // actually rendered below (e.g. said "27 reviews"
                              // while only ever showing the same 2 sample reviews).
                              '(${reviews.length} ${reviews.length == 1 ? 'review' : 'reviews'})',
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
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Reviews (${reviews.length}):',
                                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                                  ),
                                  if (canReview)
                                    TextButton.icon(
                                      onPressed: () => _openWriteReview(context, product.id),
                                      icon: const Icon(Icons.rate_review_outlined, size: 18, color: AppColors.primary),
                                      label: const Text('Write a Review', style: TextStyle(color: AppColors.primary)),
                                    ),
                                ],
                              ),
                              if (!canReview)
                                const Padding(
                                  padding: EdgeInsets.only(bottom: 4),
                                  child: Text(
                                    'Purchase this item to leave a review.',
                                    style: TextStyle(fontSize: 12, color: AppColors.textSecondary, fontStyle: FontStyle.italic),
                                  ),
                                ),
                              const SizedBox(height: 12),
                              if (reviews.isEmpty)
                                const Text('No reviews yet.', style: TextStyle(color: AppColors.textSecondary))
                              else
                                ...reviews.map((r) => _ReviewTile(review: r)),
                            ],
                          ),
                        ),
                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
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
      },
    );
  }

  void _openWriteReview(BuildContext context, String productId) {
    double rating = 5;
    final controller = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (sheetContext) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20, right: 20, top: 20,
            bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 20,
          ),
          child: StatefulBuilder(
            builder: (sheetContext, setSheetState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Write a Review',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (i) {
                      final starValue = i + 1;
                      return IconButton(
                        onPressed: () => setSheetState(() => rating = starValue.toDouble()),
                        icon: Icon(
                          starValue <= rating ? Icons.star_rounded : Icons.star_border_rounded,
                          color: AppColors.warning,
                          size: 32,
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: controller,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: 'Share what you think about this product...',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                      ),
                      onPressed: () {
                        if (controller.text.trim().isEmpty) return;
                        ProductStore.instance.addReview(
                          productId,
                          Review(
                            reviewerName: widget.username,
                            rating: rating,
                            date: DateTime.now(),
                            comment: controller.text.trim(),
                          ),
                        );
                        Navigator.of(sheetContext).pop();
                      },
                      child: const Text('Submit Review', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
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

/// Full-screen swipeable viewer opened by the "Show all" button -- a black
/// backdrop, one image per page, a page counter, and a close button.
class _GalleryViewer extends StatefulWidget {
  final List<String> images;
  final int initialIndex;
  final String productName;

  const _GalleryViewer({
    required this.images,
    required this.initialIndex,
    required this.productName,
  });

  @override
  State<_GalleryViewer> createState() => _GalleryViewerState();
}

class _GalleryViewerState extends State<_GalleryViewer> {
  late final PageController _controller;
  late int _index;

  @override
  void initState() {
    super.initState();
    _index = widget.initialIndex;
    _controller = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          '${widget.productName}  (${_index + 1}/${widget.images.length})',
          style: const TextStyle(color: Colors.white, fontSize: 15),
        ),
      ),
      body: PageView.builder(
        controller: _controller,
        itemCount: widget.images.length,
        onPageChanged: (i) => setState(() => _index = i),
        itemBuilder: (context, i) {
          final url = widget.images[i];
          return Center(
            child: InteractiveViewer(
              minScale: 1,
              maxScale: 4,
              child: url.isEmpty
                  ? const Icon(Icons.image_outlined, color: Colors.white38, size: 96)
                  : Image.network(
                url,
                fit: BoxFit.contain,
                loadingBuilder: (context, child, progress) {
                  if (progress == null) return child;
                  return const Center(
                    child: CircularProgressIndicator(color: Colors.white54),
                  );
                },
                errorBuilder: (context, error, stackTrace) =>
                const Icon(Icons.broken_image_outlined, color: Colors.white38, size: 96),
              ),
            ),
          );
        },
      ),
    );
  }
}