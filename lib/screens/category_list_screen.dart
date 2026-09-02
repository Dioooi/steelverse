import 'package:flutter/material.dart';
import '../models/product.dart';
import '../widgets/app_bottom_nav.dart';
import '../widgets/product_banner_header.dart';
import '../widgets/product_filter_bar.dart';
import '../widgets/product_list_tile.dart';

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
    this.filters = const ['filter 1', 'filter 2', 'Promotion'],
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

  bool _nameAscending = true;
  bool _priceAscending = true;

  @override
  void initState() {
    super.initState();
    _products = List.of(widget.products);
    _selectedFilter = widget.filters.isNotEmpty ? _getFilterLabel(widget.filters.first) : '';
  }

  String _getFilterLabel(String rawFilter) {
    final lower = rawFilter.toLowerCase();
    if (lower == 'filter 1' || lower.startsWith('name:')) {
      return _nameAscending ? 'Name: A-Z' : 'Name: Z-A';
    }
    if (lower == 'filter 2' || lower.startsWith('price:')) {
      return _priceAscending ? 'Price: Low-High' : 'Price: High-Low';
    }
    return rawFilter;
  }

  List<Product> get _visibleProducts {
    List<Product> list = List.of(_products);

    if (_selectedFilter.toLowerCase() == 'promotion') {
      return list.where((p) => p.hasPromo).toList();
    }

    if (_selectedFilter.startsWith('Name:')) {
      list.sort((a, b) => _nameAscending
          ? a.name.toLowerCase().compareTo(b.name.toLowerCase())
          : b.name.toLowerCase().compareTo(a.name.toLowerCase()));
    } else if (_selectedFilter.startsWith('Price:')) {
      list.sort((a, b) {
        final priceA = (a.hasPromo && a.promoPrice != null) ? a.promoPrice! : a.price;
        final priceB = (b.hasPromo && b.promoPrice != null) ? b.promoPrice! : b.price;
        return _priceAscending ? priceA.compareTo(priceB) : priceB.compareTo(priceA);
      });
    }

    return list;
  }

  void _handleFilterTap(String selectedLabel) {
    setState(() {
      if (selectedLabel.startsWith('Name:') || selectedLabel == 'filter 1') {
        if (_selectedFilter.startsWith('Name:')) {
          _nameAscending = !_nameAscending;
        }
        _selectedFilter = _getFilterLabel('filter 1');
      } else if (selectedLabel.startsWith('Price:') || selectedLabel == 'filter 2') {
        if (_selectedFilter.startsWith('Price:')) {
          _priceAscending = !_priceAscending;
        }
        _selectedFilter = _getFilterLabel('filter 2');
      } else {
        _selectedFilter = selectedLabel;
      }
    });

    widget.onFilterChanged?.call(_selectedFilter);
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
    final displayFilters = widget.filters.map((f) => _getFilterLabel(f)).toList();

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: SafeArea(
        top: false,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: ProductBannerHeader(
                title: widget.categoryTitle,
                subtitle: _selectedFilter.toLowerCase() == 'promotion'
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
                  filters: displayFilters,
                  selected: _selectedFilter,
                  onSelected: _handleFilterTap,
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
                          const Divider(height: 1, color: Colors.white12),
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
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.orangeAccent,
                    side: const BorderSide(color: Colors.orangeAccent),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                  ),
                  onPressed: widget.onLoadMore == null ? null : _handleLoadMore,
                  child: _loadingMore
                      ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.orangeAccent),
                  )
                      : const Text('View More Products'),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: AppBottomNav(
        currentIndex: 1, // Category list active tab
        onTap: (index) {
          if (index == 0) {
            // Index 0 represents the Home screen
            Navigator.of(context).popUntil((route) => route.isFirst);
          } else if (index == 2) {
            // Index 2 represents Favorites (if applicable)
            // Add navigation to FavoritesScreen here if needed
          } else if (index == 3) {
            // Index 3 represents Profile (if applicable)
            // Add navigation to ProfileScreen here if needed
          }
        },
      ),
    );
  }
}