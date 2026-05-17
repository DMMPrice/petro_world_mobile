class BannerModel {
  final String id;
  final String imageUrl;
  final String? title;
  final String? linkTo;
  final bool active;

  BannerModel({
    required this.id,
    required this.imageUrl,
    this.title,
    this.linkTo,
    required this.active,
  });

  factory BannerModel.fromJson(Map<String, dynamic> json) {
    return BannerModel(
      id: json['id']?.toString() ?? '',
      imageUrl: json['image_url']?.toString() ?? '',
      title: json['title']?.toString(),
      // Backend schema uses 'link', not 'link_to'
      linkTo: (json['link'] ?? json['link_to'])?.toString(),
      active: json['active'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'image_url': imageUrl,
      'title': title,
      'link': linkTo,
      'active': active,
    };
  }
}
