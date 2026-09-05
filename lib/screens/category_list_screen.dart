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
  /// Only holds items appended via onLoadMore -- the base catalog is read
  /// live from ProductStore.instance.products on every rebuild instead of
  /// a one-time snapshot, so new/removed products and categories show up
  /// immediately even while this screen is already open.
  final List<Product> _extraLoadedProducts = [];
  late String _selectedFilter;
  String _selectedCategory = 'All';
  bool _loadingMore = false;
  bool _hasMore = true;
  final ScrollController _scrollController = ScrollController();

  bool _nameAscending = true;
  bool _priceAscending = true;

  @override
  void initState() {
    super.initState();
    _selectedFilter = widget.filters.isNotEmpty ? _getFilterLabel(widget.filters.first) : '';
    _scrollController.addListener(_onScroll);
  }

  /// Category chips are derived from whatever categories actually exist in
  /// the current product list (plus "All"), instead of being hardcoded --
  /// so this keeps working if an admin adds a product in a new category.
  List<String> get _availableCategories {
    final allProducts = [...ProductStore.instance.products, ..._extraLoadedProducts];
    final categories = allProducts.map((p) => p.category).toSet().toList()..sort();
    return ['All', ...categories];
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
    // Read the base catalog live from the store every time, not a locally
    // cached snapshot -- this is what makes new/removed products and
    // favorite changes show up immediately, from any screen.
    final allProducts = [...ProductStore.instance.products, ..._extraLoadedProducts];
    List<Product> list = List.of(allProducts);

    if (_selectedCategory != 'All') {
      list = list.where((p) => p.category == _selectedCategory).toList();
    }

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
        _extraLoadedProducts.addAll(more);
        if (more.isEmpty) _hasMore = false;
      });
    } finally {
      if (mounted) setState(() => _loadingMore = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: ProductStore.instance,
      builder: (context, _) {
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
                        : _selectedCategory != 'All'
                        ? 'Showing: $_selectedCategory'
                        : widget.categorySubtitle,
                    bannerImageUrl: widget.bannerImageUrl,
                    onBack: () => Navigator.of(context).maybePop(),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
                    child: ProductFilterBar(
                      filters: _availableCategories,
                      selected: _selectedCategory,
                      onSelected: (category) => setState(() => _selectedCategory = category),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
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
                                // Persist to the single source of truth --
                                // AnimatedBuilder below listens to ProductStore
                                // directly, so this alone is enough to refresh
                                // the UI everywhere, not just on this screen.
                                ProductStore.instance.toggleFavorite(product.id, fav);
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
                    // Refresh so any favorites removed on that screen show up
                    // as unfavorited here immediately, not just on next rebuild.
                    if (mounted) setState(() {});
                  });
                  break;
              }
            },
          ),
        );
      },
    );
  }
}