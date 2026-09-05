import 'package:flutter/material.dart';
import '../models/product.dart';
import '../state/product_store.dart';
import '../theme/app_theme.dart';
import '../widgets/app_bottom_nav.dart';
import '../widgets/product_banner_header.dart';
import '../widgets/product_filter_bar.dart';
import '../widgets/product_list_tile.dart';
import 'favorites_screen.dart';
// HomeScreen currently lives in main.dart -- adjust this path if you later
// move it into its own file (e.g. 'home_screen.dart').
import '../main.dart';

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

  /// Used for the Profile tab if this screen owns its own bottom nav
  /// (no parent shell). Ignored if [onNavTap] is provided.
  final String username;

  /// If your app has a shared bottom-nav shell (e.g. an IndexedStack),
  /// pass a callback here and it takes over tab switching entirely.
  /// If null, this screen navigates on its own via Navigator.push.
  final void Function(int index)? onNavTap;

  const CategoryListScreen({
    super.key,
    required this.categoryTitle,
    this.categorySubtitle = 'Everything you need, built to last.',
    this.bannerImageUrl,
    this.filters = const ['filter 1', 'filter 2', 'Promotion'],
    required this.products,
    this.onLoadMore,
    this.onFilterChanged,
    this.onProductTap,
    this.onFavoriteToggle,
    this.username = 'Guest',
    this.onNavTap,
  });

  @override
  State<CategoryListScreen> createState() => _CategoryListScreenState();
}

class _CategoryListScreenState extends State<CategoryListScreen> {
  late List<Product> _products;
  late String _selectedFilter;
  bool _loadingMore = false;
  bool _hasMore = true;
  final ScrollController _scrollController = ScrollController();

  bool _nameAscending = true;
  bool _priceAscending = true;

  @override
  void initState() {
    super.initState();
    _products = List.of(widget.products);
    _selectedFilter = widget.filters.isNotEmpty ? _getFilterLabel(widget.filters.first) : '';
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (widget.onLoadMore == null || _loadingMore || !_hasMore) return;
    // Trigger the next page a little before hitting the true bottom so it
    // feels seamless instead of a hard stop-then-load.
    const threshold = 200.0;
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - threshold) {
      _handleLoadMore();
    }
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

  /// Natural sort: compares embedded numbers numerically instead of
  /// lexicographically, so "Item 2" sorts before "Item 10". Plain
  /// String.compareTo produced Item 1, Item 10, Item 2, Item 3... which is
  /// what looked like "filters not working."
  int _naturalCompare(String a, String b) {
    final chunker = RegExp(r'(\d+)|(\D+)');
    final aParts = chunker.allMatches(a).map((m) => m.group(0)!).toList();
    final bParts = chunker.allMatches(b).map((m) => m.group(0)!).toList();
    final len = aParts.length < bParts.length ? aParts.length : bParts.length;
    for (var i = 0; i < len; i++) {
      final an = int.tryParse(aParts[i]);
      final bn = int.tryParse(bParts[i]);
      final cmp = (an != null && bn != null)
          ? an.compareTo(bn)
          : aParts[i].compareTo(bParts[i]);
      if (cmp != 0) return cmp;
    }
    return aParts.length.compareTo(bParts.length);
  }

  List<Product> get _visibleProducts {
    // Always read favorite status from the store, not the locally cached
    // copy -- this screen's local _products can go stale if the user
    // favorites/unfavorites the same item from Favorites or Item Detail
    // and then comes back here without a full rebuild.
    final storeFavorites = {
      for (final p in ProductStore.instance.products) p.id: p.isFavorite,
    };
    List<Product> list = _products
        .map((p) => p.copyWith(isFavorite: storeFavorites[p.id] ?? p.isFavorite))
        .toList();

    if (_selectedFilter.toLowerCase() == 'promotion') {
      return list.where((p) => p.hasPromo).toList();
    }

    if (_selectedFilter.startsWith('Name:')) {
      list.sort((a, b) => _nameAscending
          ? _naturalCompare(a.name.toLowerCase(), b.name.toLowerCase())
          : _naturalCompare(b.name.toLowerCase(), a.name.toLowerCase()));
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
    if (widget.onLoadMore == null || _loadingMore || !_hasMore) return;
    setState(() => _loadingMore = true);
    try {
      final more = await widget.onLoadMore!();
      setState(() {
        _products.addAll(more);
        if (more.isEmpty) _hasMore = false;
      });
    } finally {
      if (mounted) setState(() => _loadingMore = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final visible = _visibleProducts;
    final displayFilters = widget.filters.map((f) => _getFilterLabel(f)).toList();

    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      body: SafeArea(
        top: false,
        child: CustomScrollView(
          controller: _scrollController,
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
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.25),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: ProductListTile(
                          product: product,
                          onTap: () => widget.onProductTap?.call(product),
                          onFavoriteChanged: (fav) {
                            // Persist to the single source of truth first --
                            // this is what was missing. Without it, toggling
                            // a favorite here never reached ProductStore, so
                            // Favorites and this screen drifted out of sync.
                            ProductStore.instance.toggleFavorite(product.id, fav);
                            setState(() {
                              _products[_products.indexOf(product)] =
                                  product.copyWith(isFavorite: fav);
                            });
                            widget.onFavoriteToggle?.call(product, fav);
                          },
                        ),
                      ),
                    );
                  },
                  childCount: visible.length,
                ),
              ),
            ),
            if (widget.onLoadMore != null)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Center(
                    child: _loadingMore
                        ? const SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                    )
                        : !_hasMore
                        ? const Text(
                      "You've reached the end",
                      style: TextStyle(color: AppColors.darkTextSecondary, fontSize: 13),
                    )
                        : const SizedBox.shrink(),
                  ),
                ),
              ),
          ],
        ),
      ),
      bottomNavigationBar: AppBottomNav(
        currentIndex: 1, // Browse/Category tab is active on this screen
        onTap: (index) {
          // If a parent shell owns navigation (e.g. an IndexedStack), let it
          // handle the tab switch instead of pushing new routes here.
          if (widget.onNavTap != null) {
            widget.onNavTap!(index);
            return;
          }

          switch (index) {
            case 0: // Home
            // popUntil(isFirst) would land on WelcomePage, not HomeScreen,
            // since HomeScreen is pushed *after* the welcome/login screen.
            // pushAndRemoveUntil clears the stack and lands on a fresh
            // HomeScreen instead -- same pattern ProfilePage's logout uses.
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => HomeScreen(username: widget.username)),
                    (route) => false,
              );
              break;
            case 1: // Browse — already here, nothing to do
              break;
            case 2: // Favorites
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => FavoritesScreen(
                    favorites: ProductStore.instance.favorites,
                    bannerImageUrl: widget.bannerImageUrl,
                    onProductTap: widget.onProductTap,
                    username: widget.username,
                  ),
                ),
              ).then((_) {
                if (mounted) setState(() {});
              });
              break;
          }
        },
      ),
    );
  }
}