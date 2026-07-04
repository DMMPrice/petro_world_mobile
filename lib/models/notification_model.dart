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
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      // Backend schema uses 'body'; keep 'message' for backward compatibility.
      message: (json['body'] ?? json['message'] ?? '').toString(),
      type: (json['type'] ?? json['user_id']) == 'global' ||
              json['user_id'] == null
          ? NotificationType.global
          : NotificationType.individual,
      userId: json['user_id']?.toString(),
      // Backend schema uses 'read'; keep 'is_read' for backward compatibility.
      isRead: (json['read'] ?? json['is_read'] ?? false) as bool,
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? '') ??
          DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'body': message,
      'type': type == NotificationType.global ? 'global' : 'individual',
      'user_id': userId,
      'read': isRead,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
