import 'package:flutter/material.dart';
import '../models/product.dart';
import '../theme/app_theme.dart';
import '../widgets/app_bottom_nav.dart';
import '../widgets/product_banner_header.dart';
import '../widgets/product_filter_bar.dart';
import '../widgets/product_list_tile.dart';

/// Corresponds to the "Category 1" screens in the Figma — both the plain
/// listing and the "Promotion" filter state (struck-through price + promo
/// price) are handled by the same screen: just tap the "Promotion" chip.
///
/// Wire-up notes for whoever connects this to real data:
/// - Pass an initial [products] page from your API/repository.
/// - [onLoadMore] is called when "View More Product" is tapped — return
///   the next page and this screen appends it (simple client-side
///   pagination stub; swap for real infinite-scroll/cursor paging later).
/// - [onFilterChanged] lets a parent re-fetch from the backend per filter
///   instead of filtering client-side, if preferred.
class CategoryListScreen extends StatefulWidget {
  final String categoryTitle;
  final String? categorySubtitle;
  final String? bannerImageUrl;
  final List<String> filters;
  final List<Product> products;
  final Future<List<Product>> Function()? onLoadMore;
  final void Function(String filter)? onFilterChanged;
  final void Function(Product product)? onProductTap;
  final void Function(Product product, bool isFavorite)? onFavoriteToggle;

  const CategoryListScreen({
    super.key,
    required this.categoryTitle,
    this.categorySubtitle,
    this.bannerImageUrl,
    this.filters = const ['filter 1', 'filter 2'],
    required this.products,
    this.onLoadMore,
    this.onFilterChanged,
    this.onProductTap,
    this.onFavoriteToggle,
  });

  @override
  State<CategoryListScreen> createState() => _CategoryListScreenState();
}

class _CategoryListScreenState extends State<CategoryListScreen> {
  late List<Product> _products;
  late String _selectedFilter;
  bool _loadingMore = false;

  @override
  void initState() {
    super.initState();
    _products = List.of(widget.products);
    _selectedFilter = widget.filters.isNotEmpty ? widget.filters.first : '';
  }

  bool get _isPromotionFilter => _selectedFilter.toLowerCase() == 'promotion';

  List<Product> get _visibleProducts {
    if (!_isPromotionFilter) return _products;
    return _products.where((p) => p.hasPromo).toList();
  }

  Future<void> _handleLoadMore() async {
    if (widget.onLoadMore == null || _loadingMore) return;
    setState(() => _loadingMore = true);
    try {
      final more = await widget.onLoadMore!();
      setState(() => _products.addAll(more));
    } finally {
      if (mounted) setState(() => _loadingMore = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final visible = _visibleProducts;

    return Scaffold(
      body: SafeArea(
        top: false,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: ProductBannerHeader(
                title: widget.categoryTitle,
                subtitle: _isPromotionFilter
                    ? 'Promotion Included'
                    : widget.categorySubtitle,
                bannerImageUrl: widget.bannerImageUrl,
                onBack: () => Navigator.of(context).maybePop(),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
                child: ProductFilterBar(
                  filters: widget.filters,
                  selected: _selectedFilter,
                  onSelected: (f) {
                    setState(() => _selectedFilter = f);
                    widget.onFilterChanged?.call(f);
                  },
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                      (context, i) {
                    final product = visible[i];
                    return Column(
                      children: [
                        ProductListTile(
                          product: product,
                          onTap: () => widget.onProductTap?.call(product),
                          onFavoriteChanged: (fav) {
                            setState(() {
                              _products[_products.indexOf(product)] =
                                  product.copyWith(isFavorite: fav);
                            });
                            widget.onFavoriteToggle?.call(product, fav);
                          },
                        ),
                        if (i != visible.length - 1)
                          const Divider(height: 1, color: AppColors.divider),
                      ],
                    );
                  },
                  childCount: visible.length,
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: OutlinedButton(
                  onPressed: widget.onLoadMore == null ? null : _handleLoadMore,
                  child: _loadingMore
                      ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                      : const Text('View More Product'),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: AppBottomNav(currentIndex: 1, onTap: (_) {}),
    );
  }
}