
enum NotificationType { global, individual }

class NotificationModel {
  final String id;
  final String title;
  final String message;
  final NotificationType type;
  final String? userId;
  final bool isRead;
  final DateTime createdAt;

  NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    this.userId,
    this.isRead = false,
    required this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'],
      title: json['title'],
      message: json['message'],
      type: json['type'] == 'global' ? NotificationType.global : NotificationType.individual,
      userId: json['user_id'],
      isRead: json['is_read'] ?? false,
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'type': type == NotificationType.global ? 'global' : 'individual',
      'user_id': userId,
      'is_read': isRead,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
