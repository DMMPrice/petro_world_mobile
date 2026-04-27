class CategoryModel {
  final String id;
  final String title;
  final String? image, svgSrc;
  final List<CategoryModel>? subCategories;

  CategoryModel({
    required this.id,
    required this.title,
    this.image,
    this.svgSrc,
    this.subCategories,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'],
      title: json['title'],
      image: json['image_url'],
      svgSrc: json['svg_src'],
      subCategories: json['sub_categories'] != null
          ? (json['sub_categories'] as List)
              .map((e) => CategoryModel.fromJson(e))
              .toList()
          : null,
    );
  }
}

final List<CategoryModel> demoCategoriesWithImage = [
  CategoryModel(id: "1", title: "Hardware", image: "https://i.imgur.com/tXyOMMG.png"),
  CategoryModel(id: "2", title: "Essentials", image: "https://i.imgur.com/Lp0D6k5.png"),
  CategoryModel(id: "3", title: "Uniforms", image: "https://i.imgur.com/3mSE5sN.png"),
  CategoryModel(id: "4", title: "Safety", image: "https://i.imgur.com/5M89G2P.png"),
];

final List<CategoryModel> demoCategories = [
  CategoryModel(
    id: "1",
    title: "Hardware",
    svgSrc: "assets/icons/Category.svg",
    subCategories: [
      CategoryModel(id: "1-1", title: "Cam Locks"),
      CategoryModel(id: "1-2", title: "Hose Pipes"),
      CategoryModel(id: "1-3", title: "Funnels"),
      CategoryModel(id: "1-4", title: "Wires & Seals"),
    ],
  ),
  CategoryModel(
    id: "2",
    title: "Essentials",
    svgSrc: "assets/icons/Product.svg",
    subCategories: [
      CategoryModel(id: "2-1", title: "Measurement Kits"),
      CategoryModel(id: "2-2", title: "Storage Jars"),
      CategoryModel(id: "2-3", title: "Testing Equipment"),
      CategoryModel(id: "2-4", title: "Signage"),
    ],
  ),
  CategoryModel(
    id: "3",
    title: "Uniforms",
    svgSrc: "assets/icons/Profile.svg",
    subCategories: [
      CategoryModel(id: "3-1", title: "Filler Uniforms"),
      CategoryModel(id: "3-2", title: "Safety Jackets"),
    ],
  ),
  CategoryModel(
    id: "4",
    title: "Safety",
    svgSrc: "assets/icons/Lock.svg",
    subCategories: [
      CategoryModel(id: "4-1", title: "Fire Safety"),
      CategoryModel(id: "4-2", title: "Spill Kits"),
      CategoryModel(id: "4-3", title: "Traffic Control"),
      CategoryModel(id: "4-4", title: "Electrical Safety"),
    ],
  ),
];
