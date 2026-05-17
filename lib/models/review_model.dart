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
    final profile = json['profiles'] as Map<String, dynamic>?
        ?? json['user'] as Map<String, dynamic>?;
    final rawRating = json['rating'];
    final rating = rawRating is int
        ? rawRating
        : (rawRating is num ? rawRating.toInt() : int.tryParse(rawRating?.toString() ?? '') ?? 0);
    return ReviewModel(
      id: json['id']?.toString() ?? '',
      productId: json['product_id']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? '',
      rating: rating,
      comment: json['comment']?.toString() ?? '',
      createdAt: DateTime.parse(json['created_at'].toString()),
      userName: profile != null
          ? "${profile['first_name'] ?? profile['firstName'] ?? ''} ${profile['last_name'] ?? profile['lastName'] ?? ''}".trim()
          : "User",
      userAvatar: profile?['avatar_url']?.toString(),
    );
  }
}
