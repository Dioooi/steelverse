import 'package:flutter/material.dart';
import '../models/product.dart';
import '../theme/app_theme.dart';
import '../widgets/product_banner_header.dart';
import '../widgets/product_list_tile.dart';

/// Corresponds to the "Favorites" screen: banner header, "Favorite items"
/// pill, list with filled hearts (tap to remove), "Back to Item List".
class FavoritesScreen extends StatefulWidget {
  final List<Product> favorites;
  final String? bannerImageUrl;
  final void Function(Product product)? onProductTap;
  final void Function(Product product)? onRemoveFavorite;

  const FavoritesScreen({
    super.key,
    required this.favorites,
    this.bannerImageUrl,
    this.onProductTap,
    this.onRemoveFavorite,
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
                    color: AppColors.lilac,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  alignment: Alignment.center,
                  child: const Text('Favorite items', style: TextStyle(fontWeight: FontWeight.w600)),
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
                    return Column(
                      children: [
                        ProductListTile(
                          product: product,
                          onTap: () => widget.onProductTap?.call(product),
                          onFavoriteChanged: (fav) {
                            if (!fav) {
                              setState(() => _favorites.removeAt(i));
                              widget.onRemoveFavorite?.call(product);
                            }
                          },
                        ),
                        if (i != _favorites.length - 1)
                          const Divider(height: 1, color: AppColors.divider),
                      ],
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
                  onPressed: () => Navigator.of(context).maybePop(),
                  child: const Text('Back to Item List'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}