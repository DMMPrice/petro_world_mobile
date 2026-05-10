import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/notification_model.dart';

class NotificationService {
  static final client = Supabase.instance.client;

  static Future<List<NotificationModel>> getNotifications() async {
    final user = client.auth.currentUser;
    if (user == null) return [];

    final response = await client
        .from('user_notifications')
        .select('*')
        .order('created_at', ascending: false);
    
    return (response as List).map((json) => NotificationModel.fromJson(json)).toList();
  }

  static Future<void> markAsRead(String notificationId, NotificationType type) async {
    final user = client.auth.currentUser;
    if (user == null) return;

    if (type == NotificationType.individual) {
      await client
          .from('notifications')
          .update({'is_read': true})
          .eq('id', notificationId);
    } else {
      await client
          .from('notification_reads')
          .upsert({
            'notification_id': notificationId,
            'user_id': user.id,
          });
    }
  }

  static Future<void> markAllAsRead() async {
    final user = client.auth.currentUser;
    if (user == null) return;

    final notifications = await getNotifications();
    final unread = notifications.where((n) => !n.isRead).toList();

    for (var n in unread) {
      await markAsRead(n.id, n.type);
    }
  }

  static Future<int> getUnreadCount() async {
    final notifications = await getNotifications();
    return notifications.where((n) => !n.isRead).length;
  }

  // Admin-only method
  static Future<void> sendGlobalNotification(String title, String message) async {
    await client.from('notifications').insert({
      'title': title,
      'message': message,
      'type': 'global',
    });
  }

  static Future<void> sendIndividualNotification(String userId, String title, String message) async {
    await client.from('notifications').insert({
      'user_id': userId,
      'title': title,
      'message': message,
      'type': 'individual',
    });
  }

  static Stream<int> get unreadCountStream {
    // We listen to both notifications and notification_reads
    return client
        .from('notifications')
        .stream(primaryKey: ['id'])
        .asyncMap((_) => getUnreadCount());
  }

  static Stream<List<Map<String, dynamic>>> get realtimeNotifications {
     return client
        .from('notifications')
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: false);
  }
}
