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
    double price = (json['price'] as num).toDouble();
    String? discountType = json['discount_type'];
    double? discountValue = json['discount_value'] != null ? (json['discount_value'] as num).toDouble() : null;

    double? priceAfterDiscount = json['price_after_discount'] != null 
        ? (json['price_after_discount'] as num).toDouble() 
        : null;
    
    int? discountPercent = json['discount_percent'];

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

    return ProductModel(
      id: json['id'],
      title: json['title'],
      brandName: json['brand_name'] ?? '',
      price: price,
      priceAfterDiscount: priceAfterDiscount,
      discountPercent: discountPercent,
      image: json['image_url'] ?? '',
      gallery: json['gallery_urls'] != null 
          ? List<String>.from(json['gallery_urls']) 
          : [],
      category: json['category_id'],
      categoryTitle: json['categories'] != null ? json['categories']['title'] : null,
      subCategoryId: json['sub_category_id'],
      subCategoryTitle: json['sub_categories'] != null 
          ? (json['sub_categories'] is List 
              ? (json['sub_categories'].isNotEmpty ? (json['sub_categories'][0]['name'] ?? json['sub_categories'][0]['title']) : null)
              : (json['sub_categories']['name'] ?? json['sub_categories']['title']))
          : null,
      description: json['description'],
      rating: json['rating'] != null ? (json['rating'] as num).toDouble() : null,
      reviewCount: json['review_count'] != null ? json['review_count'] as int : null,
      discountType: discountType,
      discountValue: discountValue,
    );
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

