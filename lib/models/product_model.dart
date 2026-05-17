class ProductModel {
  final String id;
  final String image, brandName, title;
  final List<String> gallery;
  final double price;
  final double? priceAfterDiscount;
  final int? discountPercent;
  final String? discountType;
  final double? discountValue;
  final String? category;
  final String? categoryTitle;
  final String? subCategoryId;
  final String? subCategoryTitle;
  final String? description;
  final double? rating;
  final int? reviewCount;

  ProductModel({
    required this.id,
    required this.image,
    required this.brandName,
    required this.title,
    this.gallery = const [],
    required this.price,
    this.priceAfterDiscount,
    this.discountPercent,
    this.category,
    this.categoryTitle,
    this.subCategoryId,
    this.subCategoryTitle,
    this.description,
    this.rating,
    this.reviewCount,
    this.discountType,
    this.discountValue,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    double price = _toDouble(json['price']) ?? 0.0;
    String? discountType = json['discount_type']?.toString();
    double? discountValue = _toDouble(json['discount_value']);

    double? priceAfterDiscount = _toDouble(json['price_after_discount']);
    int? discountPercent = _toInt(json['discount_percent']);

    // Local calculation if missing from DB
    if (priceAfterDiscount == null && discountType != null && discountValue != null) {
      if (discountType == 'percentage') {
        priceAfterDiscount = price * (1 - discountValue / 100);
      } else if (discountType == 'fixed') {
        priceAfterDiscount = (price - discountValue).clamp(0, price);
      }
    }

    if (discountPercent == null && discountType != null && discountValue != null) {
      if (discountType == 'percentage') {
        discountPercent = discountValue.toInt();
      } else if (discountType == 'fixed' && price > 0) {
        discountPercent = (((price - (priceAfterDiscount ?? price)) / price) * 100).round();
      }
    }

    // image_url is the canonical column; fall back to images[] or gallery_urls[]
    // which is where the seed data stores URLs.
    String rawImage = json['image_url']?.toString() ?? '';
    if (rawImage.isEmpty) {
      final imgs = json['images'];
      if (imgs is List && imgs.isNotEmpty) rawImage = imgs.first?.toString() ?? '';
    }
    if (rawImage.isEmpty) {
      final gal = json['gallery_urls'];
      if (gal is List && gal.isNotEmpty) rawImage = gal.first?.toString() ?? '';
    }

    // Gallery: merge images[] + gallery_urls[] deduplicated
    final Set<String> gallerySet = {};
    for (final src in [json['images'], json['gallery_urls']]) {
      if (src is List) {
        for (final u in src) {
          final s = u?.toString() ?? '';
          if (s.isNotEmpty) gallerySet.add(s);
        }
      }
    }
    final gallery = gallerySet.toList();

    return ProductModel(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      brandName: json['brand_name']?.toString() ?? '',
      price: price,
      priceAfterDiscount: priceAfterDiscount,
      discountPercent: discountPercent,
      image: rawImage,
      gallery: gallery,
      category: json['category_id']?.toString(),
      categoryTitle: json['categories'] != null
          ? (json['categories'] as Map<String, dynamic>)['title']?.toString()
          : json['category_title']?.toString(),
      subCategoryId: json['sub_category_id']?.toString(),
      subCategoryTitle: json['sub_categories'] != null
          ? (json['sub_categories'] is List
              ? (json['sub_categories'].isNotEmpty
                  ? (json['sub_categories'][0]['name'] ?? json['sub_categories'][0]['title'])?.toString()
                  : null)
              : (json['sub_categories']['name'] ?? json['sub_categories']['title'])?.toString())
          : json['sub_category_title']?.toString(),
      description: json['description']?.toString(),
      rating: _toDouble(json['rating']),
      reviewCount: _toInt(json['review_count']),
      discountType: discountType,
      discountValue: discountValue,
    );
  }

  /// Safely parse a value that may be num, String, or null into double.
  static double? _toDouble(dynamic v) {
    if (v == null) return null;
    if (v is num) return v.toDouble();
    if (v is String) return double.tryParse(v);
    return null;
  }

  /// Safely parse a value that may be int, String, or null into int.
  static int? _toInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    if (v is num) return v.toInt();
    if (v is String) return int.tryParse(v);
    return null;
  }

  double get effectivePrice {
    if (priceAfterDiscount != null) return priceAfterDiscount!;
    if (discountType == null || discountValue == null) return price;
    
    if (discountType == 'percentage') {
      return price * (1 - discountValue! / 100);
    } else if (discountType == 'fixed') {
      return (price - discountValue!).clamp(0, price);
    }
    return price;
  }

  bool get hasDiscount => priceAfterDiscount != null || (discountType != null && discountValue != null && discountValue! > 0);
}

