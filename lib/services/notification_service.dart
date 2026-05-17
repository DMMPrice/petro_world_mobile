import 'dart:async';
import '../models/notification_model.dart';
import 'api_service.dart';

/// Notification service backed entirely by the Express/Neon backend.
/// All Supabase Realtime has been replaced with periodic polling.
class NotificationService {
  // ── Read notifications ────────────────────────────────────────────────────

  static Future<List<NotificationModel>> getNotifications() async {
    return ApiService.instance.getNotifications();
  }

  // ── Mark read ─────────────────────────────────────────────────────────────

  static Future<void> markAsRead(String notificationId, NotificationType type) async {
    await ApiService.instance.markNotificationRead(notificationId);
  }

  static Future<void> markAllAsRead() async {
    await ApiService.instance.markAllNotificationsRead();
  }

  static Future<int> getUnreadCount() async {
    return ApiService.instance.getUnreadNotificationCount();
  }

  // ── Polled stream (replaces Supabase Realtime) ────────────────────────────

  /// Emits the unread notification count immediately and then every 30 seconds.
  static Stream<int> get unreadCountStream async* {
    if (!ApiService.instance.isLoggedIn) {
      yield 0;
      return;
    }
    while (true) {
      try {
        yield await getUnreadCount();
      } catch (_) {
        yield 0;
      }
      await Future.delayed(const Duration(seconds: 30));
    }
  }

  /// Emits the full notification list immediately and then every 30 seconds.
  static Stream<List<Map<String, dynamic>>> get realtimeNotifications async* {
    if (!ApiService.instance.isLoggedIn) {
      yield [];
      return;
    }
    while (true) {
      try {
        final list = await getNotifications();
        yield list.map((n) => n.toJson()).toList();
      } catch (_) {
        yield [];
      }
      await Future.delayed(const Duration(seconds: 30));
    }
  }

  // ── Admin helpers (no-ops — admin panel handles these via its own backend calls) ──

  static Future<void> sendGlobalNotification(String title, String message) async {
    // Admin panel sends notifications via POST /api/v1/admin/notifications
    // This method is left as a no-op on the mobile side.
  }

  static Future<void> sendIndividualNotification(
      String userId, String title, String message) async {
    // Same as above — handled by admin panel, not the mobile app.
  }
}
