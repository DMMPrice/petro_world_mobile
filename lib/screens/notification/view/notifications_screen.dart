import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import '../../../constants.dart';
import '../../../models/notification_model.dart';
import '../../../services/notification_service.dart';
import 'no_notification_screen.dart';
import 'package:timeago/timeago.dart' as timeago;

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  List<NotificationModel> notifications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchNotifications();
  }

  Future<void> _fetchNotifications() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final data = await NotificationService.getNotifications();
      setState(() {
        notifications = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error fetching notifications: $e")),
        );
      }
    }
  }

  Future<void> _markAsRead(NotificationModel notification) async {
    if (notification.isRead) return;

    try {
      await NotificationService.markAsRead(notification.id, notification.type);
      // Update local state
      setState(() {
        final index = notifications.indexWhere((n) => n.id == notification.id);
        if (index != -1) {
          notifications[index] = NotificationModel(
            id: notification.id,
            title: notification.title,
            message: notification.message,
            type: notification.type,
            userId: notification.userId,
            isRead: true,
            createdAt: notification.createdAt,
          );
        }
      });
    } catch (e) {
      // Silently handle marking notifications as read
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Notifications"),
        centerTitle: true,
        actions: [
          if (notifications.any((n) => !n.isRead))
            TextButton(
              onPressed: () async {
                await NotificationService.markAllAsRead();
                _fetchNotifications();
              },
              child: const Text("Mark all read"),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : notifications.isEmpty
              ? const NoNotificationScreen()
              : RefreshIndicator(
                  onRefresh: _fetchNotifications,
                  child: ListView.builder(
                    itemCount: notifications.length,
                    itemBuilder: (context, index) {
                      final notif = notifications[index];
                      return GestureDetector(
                        onTap: () => _markAsRead(notif),
                        child: _buildNotificationTile(
                          context,
                          type: notif.type,
                          title: notif.title,
                          message: notif.message,
                          time: timeago.format(notif.createdAt),
                          isRead: notif.isRead,
                          showBorder: index != notifications.length - 1,
                        ),
                      );
                    },
                  ),
                ),
    );
  }

  Widget _buildNotificationTile(
    BuildContext context, {
    required NotificationType type,
    required String title,
    required String message,
    required String time,
    bool isRead = false,
    bool showBorder = true,
  }) {
    // Determine icon and color based on type or content (simplified for now)
    final Color color =
        type == NotificationType.global ? primaryColor : navyColor;
    final String iconSrc = type == NotificationType.global
        ? "assets/icons/Notification.svg"
        : "assets/icons/Info.svg";

    return Column(
      children: [
        Container(
          color: isRead ? null : primaryColor.withValues(alpha: 0.03),
          child: Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: defaultPadding, vertical: defaultPadding),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: color.withValues(alpha: 0.1),
                      child: SvgPicture.asset(
                        iconSrc,
                        colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
                        height: 24,
                      ),
                    ),
                    if (!isRead)
                      Positioned(
                        top: 0,
                        right: 0,
                        child: Container(
                          height: 12,
                          width: 12,
                          decoration: BoxDecoration(
                            color: primaryColor,
                            shape: BoxShape.circle,
                            border: Border.all(
                                color:
                                    Theme.of(context).scaffoldBackgroundColor,
                                width: 2),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: defaultPadding),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.titleSmall!.copyWith(
                              fontWeight:
                                  isRead ? FontWeight.w500 : FontWeight.bold,
                              color: isRead ? null : navyColor,
                              height: 1.3,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        message,
                        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                              color: blackColor60,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        time,
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context)
                              .textTheme
                              .bodyMedium!
                              .color!
                              .withValues(alpha: 0.4),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        if (showBorder)
          Padding(
            padding: const EdgeInsets.only(
                left: defaultPadding * 3.5 + 16, right: defaultPadding),
            child: Divider(
              color: Theme.of(context).dividerColor.withValues(alpha: 0.05),
              height: 1,
            ),
          ),
      ],
    );
  }
}
