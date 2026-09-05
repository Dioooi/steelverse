import 'package:flutter/material.dart';
import '../models/product.dart';
import '../state/product_store.dart';
import '../theme/app_theme.dart';
import '../widgets/app_bottom_nav.dart';
import '../widgets/product_banner_header.dart';
import '../widgets/product_list_tile.dart';
import 'category_list_screen.dart';
import '../main.dart';

class FavoritesScreen extends StatefulWidget {
  final List<Product> favorites;
  final String? bannerImageUrl;
  final void Function(Product product)? onProductTap;
  final void Function(Product product)? onRemoveFavorite;
  final String username;

  const FavoritesScreen({
    super.key,
    required this.favorites,
    this.bannerImageUrl,
    this.onProductTap,
    this.onRemoveFavorite,
    this.username = 'Guest',
  });

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  late List<Product> _favorites;

  @override
  void initState() {
    super.initState();
    _favorites = List.of(widget.favorites);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        top: false,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: ProductBannerHeader(
                title: 'Favorites',
                bannerImageUrl: widget.bannerImageUrl,
                onBack: () => Navigator.of(context).maybePop(),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.primaryBackground,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: AppColors.primary.withValues(alpha: 0.4)),
                  ),
                  alignment: Alignment.center,
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.favorite_rounded, color: AppColors.primary, size: 20),
                      SizedBox(width: 8),
                      Text('Favorite Items', style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.primary)),
                    ],
                  ),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: _favorites.isEmpty
                  ? const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 40),
                  child: Center(
                    child: Text('No favorites yet', style: TextStyle(color: AppColors.textSecondary)),
                  ),
                ),
              )
                  : SliverList(
                delegate: SliverChildBuilderDelegate(
                      (context, i) {
                    final product = _favorites[i];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.divider),
                        ),
                        child: ProductListTile(
                          product: product,
                          onTap: () => widget.onProductTap?.call(product),
                          onFavoriteChanged: (fav) {
                            if (!fav) {
                              // Persist to the store first -- this is the part
                              // that was missing. Without it, the item only
                              // disappeared from this screen's local list and
                              // came right back the next time Favorites was
                              // opened, because ProductStore still thought
                              // isFavorite was true.
                              ProductStore.instance.toggleFavorite(product.id, false);
                              setState(() => _favorites.removeAt(i));
                              widget.onRemoveFavorite?.call(product);
                            }
                          },
                        ),
                      ),
                    );
                  },
                  childCount: _favorites.length,
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textPrimary,
                    side: const BorderSide(color: AppColors.divider),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                  ),
                  onPressed: () => Navigator.of(context).maybePop(),
                  child: const Text('Back to Item List', style: TextStyle(fontWeight: FontWeight.w600)),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: AppBottomNav(
        currentIndex: 2, // Favorites tab is active on this screen
        onTap: (index) {
          switch (index) {
            case 0: // Home
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => HomeScreen(username: widget.username)),
                    (route) => false,
              );
              break;
            case 1: // Browse
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => CategoryListScreen(
                    categoryTitle: 'Hardware Parts',
                    categorySubtitle: 'Full Inventory',
                    products: ProductStore.instance.products,
                    onProductTap: widget.onProductTap,
                    username: widget.username,
                  ),
                ),
              );
              break;
            case 2: // Favorites — already here, nothing to do
              break;
          }
        },
      ),
    );
  }
}