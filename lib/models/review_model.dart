class ReviewModel {
  final String id;
  final String productId;
  final String userId;
  final int rating;
  final String comment;
  final DateTime createdAt;
  final String? userName;
  final String? userAvatar;

  ReviewModel({
    required this.id,
    required this.productId,
    required this.userId,
    required this.rating,
    required this.comment,
    required this.createdAt,
    this.userName,
    this.userAvatar,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    final profile = json['profiles'] as Map<String, dynamic>?;
    return ReviewModel(
      id: json['id'],
      productId: json['product_id'],
      userId: json['user_id'],
      rating: json['rating'],
      comment: json['comment'],
      createdAt: DateTime.parse(json['created_at']),
      userName: profile != null 
          ? "${profile['first_name'] ?? ''} ${profile['last_name'] ?? ''}".trim() 
          : "User",
      userAvatar: profile?['avatar_url'],
    );
  }
}
