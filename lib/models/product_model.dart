class ProductModel {
  final String id;
  final String image, brandName, title;
  final double price;
  final double? priceAfterDiscount;
  final int? discountPercent;
  final String? category;
  final String? description;
  final double? rating;

  ProductModel({
    required this.id,
    required this.image,
    required this.brandName,
    required this.title,
    required this.price,
    this.priceAfterDiscount,
    this.discountPercent,
    this.category,
    this.description,
    this.rating,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'],
      title: json['title'],
      brandName: json['brand_name'] ?? '',
      price: (json['price'] as num).toDouble(),
      priceAfterDiscount: json['price_after_discount'] != null 
          ? (json['price_after_discount'] as num).toDouble() 
          : null,
      discountPercent: json['discount_percent'],
      image: json['image_url'] ?? '',
      category: json['category_id'], // or title if joined
      description: json['description'],
      rating: json['rating'] != null ? (json['rating'] as num).toDouble() : null,
    );
  }
}

List<ProductModel> demoProducts = [
  ProductModel(
    id: "1",
    image: "https://i.imgur.com/5M89G2P.png",
    title: "CO2 Fire Extinguisher 4.5kg",
    brandName: "FireGuard",
    price: 3500,
    category: "Safety",
  ),
  ProductModel(
    id: "2",
    image: "https://i.imgur.com/UM3GdWg.png",
    title: "Fire Bucket (Set of 4)",
    brandName: "SafetyFirst",
    price: 1200,
    category: "Safety",
  ),
  ProductModel(
    id: "3",
    image: "https://i.imgur.com/Lp0D6k5.png",
    title: "Fire Bucket Stand",
    brandName: "IronBuild",
    price: 1800,
    category: "Essentials",
  ),
  ProductModel(
    id: "4",
    image: "https://i.imgur.com/3mSE5sN.png",
    title: "Full Sleeve Filler Uniform",
    brandName: "StaffWear",
    price: 850,
    priceAfterDiscount: 750,
    discountPercent: 12,
    category: "Uniforms",
  ),
  ProductModel(
    id: "5",
    image: "https://i.imgur.com/tXyOMMG.png",
    title: "Cam Lock Male 2\"",
    brandName: "BrassFit",
    price: 450,
    category: "Hardware",
  ),
  ProductModel(
    id: "6",
    image: "https://i.imgur.com/h2LqppX.png",
    title: "Cam Lock Female 2\"",
    brandName: "BrassFit",
    price: 550,
    category: "Hardware",
  ),
  ProductModel(
    id: "7",
    image: "https://i.imgur.com/5M89G2P.png",
    title: "PVC Traffic Cone 750mm",
    brandName: "RoadSafety",
    price: 400,
    category: "Safety",
  ),
  ProductModel(
    id: "8",
    image: "https://i.imgur.com/UM3GdWg.png",
    title: "PVC Chain 6mm (10m)",
    brandName: "SecureLine",
    price: 650,
    category: "Safety",
  ),
  ProductModel(
    id: "9",
    image: "https://i.imgur.com/Lp0D6k5.png",
    title: "Spill Kit 20L",
    brandName: "CleanFlow",
    price: 2500,
    category: "Safety",
  ),
  ProductModel(
    id: "10",
    image: "https://i.imgur.com/3mSE5sN.png",
    title: "Discharge Hose Pipe 2\"",
    brandName: "FlexFlow",
    price: 3200,
    category: "Hardware",
  ),
  ProductModel(
    id: "11",
    image: "https://i.imgur.com/tXyOMMG.png",
    title: "Glass Jar 5L (NABL)",
    brandName: "LabStandard",
    price: 1200,
    category: "Essentials",
  ),
  ProductModel(
    id: "12",
    image: "https://i.imgur.com/h2LqppX.png",
    title: "Plastic Jar 5L",
    brandName: "PolyStrong",
    price: 350,
    category: "Essentials",
  ),
  ProductModel(
    id: "13",
    image: "https://i.imgur.com/5M89G2P.png",
    title: "Hydrometer with Case",
    brandName: "DensityTest",
    price: 1500,
    category: "Essentials",
  ),
  ProductModel(
    id: "14",
    image: "https://i.imgur.com/UM3GdWg.png",
    title: "Density Kit Box",
    brandName: "DensityTest",
    price: 4500,
    category: "Essentials",
  ),
  ProductModel(
    id: "15",
    image: "https://i.imgur.com/Lp0D6k5.png",
    title: "Cash Bag with Lock",
    brandName: "SecureCarry",
    price: 950,
    category: "Essentials",
  ),
  ProductModel(
    id: "16",
    image: "https://i.imgur.com/3mSE5sN.png",
    title: "Electric Insulating Mat",
    brandName: "SafeShock",
    price: 1800,
    category: "Safety",
  ),
  ProductModel(
    id: "17",
    image: "https://i.imgur.com/tXyOMMG.png",
    title: "Sign Board - No Smoking",
    brandName: "PetroSign",
    price: 250,
    category: "Essentials",
  ),
  ProductModel(
    id: "18",
    image: "https://i.imgur.com/h2LqppX.png",
    title: "Funnel (Kupi) Set",
    brandName: "BrassFit",
    price: 800,
    category: "Hardware",
  ),
];
