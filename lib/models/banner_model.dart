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
      id: json['id'],
      imageUrl: json['image_url'],
      title: json['title'],
      linkTo: json['link_to'],
      active: json['active'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'image_url': imageUrl,
      'title': title,
      'link_to': linkTo,
      'active': active,
    };
  }
}
