import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import '../../../constants.dart';
import 'no_notification_screen.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  // Dummy notification data
  List<Map<String, dynamic>> notifications = [
    {
      "iconSrc": "assets/icons/Discount.svg",
      "color": const Color(0xFFEA6262), // Red
      "title": "Molestie libero neque sem cras enim, amet.",
      "time": "2 min ago",
      "isUnread": true,
    },
    {
      "iconSrc": "assets/icons/Shop.svg",
      "color": const Color(0xFFF1B721), // Yellow/Orange
      "title": "Egestas nisl sapien amet lectus molestie id euismod.",
      "time": "6 hours ago",
      "isUnread": true,
    },
    {
      "iconSrc": "assets/icons/Setting.svg",
      "color": const Color(0xFF407BFF), // Blue
      "title": "Ullamcorper ac ornare ipsum ut sed integer turpis felis viverra...",
      "time": "4 days ago",
      "isUnread": true,
    },
    {
      "iconSrc": "assets/icons/Location.svg",
      "color": const Color(0xFF90C24B), // Green
      "title": "Facilisis in proin ultrices in tincidunt adipiscing turpis praesent non.",
      "time": "5 day ago",
      "isUnread": true,
    },
    {
      "iconSrc": "assets/icons/Bag.svg",
      "color": const Color(0xFFFA8B4E), // Orange
      "title": "Pellentesque proin risus pellentesque odio a.",
      "time": "1 week ago",
      "isUnread": true,
    },
    {
      "iconSrc": "assets/icons/Discount.svg",
      "color": const Color(0xFFEA6262), // Red
      "title": "Enim, proin ac ut nullam nec.",
      "time": "1 week ago",
      "isUnread": true,
    },
    {
      "iconSrc": "assets/icons/Discount.svg",
      "color": const Color(0xFFEA6262), // Red
      "title": "Molestie libero neque sem cras enim, amet.",
      "time": "1 week ago",
      "isUnread": true,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Notifications"),
        actions: [
          if (notifications.isNotEmpty)
            TextButton(
              onPressed: () {
                setState(() {
                  notifications.clear();
                });
              },
              child: const Text("Clear all"),
            ),
        ],
      ),
      body: notifications.isEmpty
          ? const NoNotificationScreen()
          : ListView.builder(
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final notif = notifications[index];
                return _buildNotificationTile(
                  context,
                  iconSrc: notif["iconSrc"],
                  color: notif["color"],
                  title: notif["title"],
                  time: notif["time"],
                  isUnread: notif["isUnread"],
                  showBorder: index != notifications.length - 1,
                );
              },
            ),
    );
  }

  Widget _buildNotificationTile(
    BuildContext context, {
    required String iconSrc,
    required Color color,
    required String title,
    required String time,
    bool isUnread = false,
    bool showBorder = true,
  }) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: defaultPadding, vertical: defaultPadding / 2),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: color,
                    child: SvgPicture.asset(
                      iconSrc,
                      colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                      height: 20,
                    ),
                  ),
                  if (isUnread)
                    Positioned(
                      top: 0,
                      right: 0,
                      child: Container(
                        height: 12,
                        width: 12,
                        decoration: BoxDecoration(
                          color: const Color(0xFFEA6262), // Red dot
                          shape: BoxShape.circle,
                          border: Border.all(color: Theme.of(context).scaffoldBackgroundColor, width: 2),
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
                            fontWeight: FontWeight.w500,
                            height: 1.3,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      time,
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).textTheme.bodyMedium!.color!.withOpacity(0.5),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (showBorder)
          Padding(
            padding: const EdgeInsets.only(left: defaultPadding * 3.5 + 16, right: defaultPadding),
            child: Divider(
              color: Theme.of(context).dividerColor.withOpacity(0.05),
              height: 16,
            ),
          ),
      ],
    );
  }
}
