import 'package:flutter/material.dart';
import '../models/product.dart';
import '../widgets/product_banner_header.dart';
import '../widgets/product_list_tile.dart';

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
      backgroundColor: const Color(0xFF121212),
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
                    color: Colors.orangeAccent.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Colors.orangeAccent.withValues(alpha: 0.4)),
                  ),
                  alignment: Alignment.center,
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.favorite_rounded, color: Colors.orangeAccent, size: 20),
                      SizedBox(width: 8),
                      Text('Favorite Items', style: TextStyle(fontWeight: FontWeight.w600, color: Colors.orangeAccent)),
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
                    child: Text('No favorites yet', style: TextStyle(color: Colors.white54)),
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
                          color: Colors.white.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.white10),
                        ),
                        child: ProductListTile(
                          product: product,
                          onTap: () => widget.onProductTap?.call(product),
                          onFavoriteChanged: (fav) {
                            if (!fav) {
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
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white38),
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
    );
  }
}