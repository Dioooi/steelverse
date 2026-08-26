/// Core product model used across category/browse, item detail, cart,
/// favorites, payment and refund screens.
///
/// [imageUrl] / [imageAsset] are intentionally nullable — leave them null
/// during development and the UI will render a neutral placeholder
/// (see `widgets/product_image.dart`). Once real product photos are ready,
/// just populate one of these two fields (network URL from backend, or a
/// bundled asset path) and every screen picks it up automatically.
class Product {
  final String id;
  final String name;
  final String description;
  final double price;

  /// Discounted / promo price. Null or >= [price] means "no promotion".
  final double? promoPrice;

  final double rating; // 0.0 - 5.0
  final int reviewCount;
  final String category;

  /// Network image URL — swap in once backend/CDN is ready.
  final String? imageUrl;

  /// Local bundled asset path (e.g. 'assets/images/item_1.png').
  final String? imageAsset;

  /// Additional gallery images for the item detail page.
  final List<String> galleryImageUrls;

  final bool isFavorite;
  final int stock;

  const Product({
    required this.id,
    required this.name,
    this.description = '',
    required this.price,
    this.promoPrice,
    this.rating = 0,
    this.reviewCount = 0,
    this.category = '',
    this.imageUrl,
    this.imageAsset,
    this.galleryImageUrls = const [],
    this.isFavorite = false,
    this.stock = 999,
  });

  bool get hasPromo => promoPrice != null && promoPrice! < price;

  double get displayPrice => hasPromo ? promoPrice! : price;

  Product copyWith({
    String? id,
    String? name,
    String? description,
    double? price,
    double? promoPrice,
    bool clearPromo = false,
    double? rating,
    int? reviewCount,
    String? category,
    String? imageUrl,
    String? imageAsset,
    List<String>? galleryImageUrls,
    bool? isFavorite,
    int? stock,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      promoPrice: clearPromo ? null : (promoPrice ?? this.promoPrice),
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      category: category ?? this.category,
      imageUrl: imageUrl ?? this.imageUrl,
      imageAsset: imageAsset ?? this.imageAsset,
      galleryImageUrls: galleryImageUrls ?? this.galleryImageUrls,
      isFavorite: isFavorite ?? this.isFavorite,
      stock: stock ?? this.stock,
    );
  }

  /// Maps directly onto a typical REST/Firestore product document.
  /// Adjust key names to match your backend contract when you wire it up.
  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'].toString(),
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0,
      promoPrice: json['promoPrice'] != null
          ? (json['promoPrice'] as num).toDouble()
          : null,
      rating: (json['rating'] as num?)?.toDouble() ?? 0,
      reviewCount: json['reviewCount'] as int? ?? 0,
      category: json['category'] as String? ?? '',
      imageUrl: json['imageUrl'] as String?,
      imageAsset: json['imageAsset'] as String?,
      galleryImageUrls: (json['galleryImageUrls'] as List?)
          ?.map((e) => e.toString())
          .toList() ??
          const [],
      isFavorite: json['isFavorite'] as bool? ?? false,
      stock: json['stock'] as int? ?? 999,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'price': price,
    'promoPrice': promoPrice,
    'rating': rating,
    'reviewCount': reviewCount,
    'category': category,
    'imageUrl': imageUrl,
    'imageAsset': imageAsset,
    'galleryImageUrls': galleryImageUrls,
    'isFavorite': isFavorite,
    'stock': stock,
  };
}