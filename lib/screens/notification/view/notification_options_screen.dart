import 'package:flutter/material.dart';
import '../../../constants.dart';

class NotificationOptionsScreen extends StatefulWidget {
  const NotificationOptionsScreen({super.key});

  @override
  State<NotificationOptionsScreen> createState() => _NotificationOptionsScreenState();
}

class _NotificationOptionsScreenState extends State<NotificationOptionsScreen> {
  bool allowNotification = true;
  bool discountNotifications = true;
  bool storesNotifications = false;
  bool systemNotifications = false;
  bool locationNotifications = false;
  bool paymentNotifications = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Notifications"),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                allowNotification = true;
                discountNotifications = true;
                storesNotifications = false;
                systemNotifications = false;
                locationNotifications = false;
                paymentNotifications = false;
              });
            },
            child: const Text(
              "Reset",
              style: TextStyle(
                color: Color(0xFF7B61FF),
                fontWeight: FontWeight.w500,
              ),
            ),
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: defaultPadding),
            _buildSwitchTile(
              title: "Allow Notification",
              value: allowNotification,
              onChanged: (val) {
                setState(() {
                  allowNotification = val;
                });
              },
              showBorder: true,
            ),
            _buildSwitchTile(
              title: "Discount notifications",
              subtitle: "At a mauris volutpat cras vitae convallis gravida.",
              value: discountNotifications,
              onChanged: (val) {
                setState(() {
                  discountNotifications = val;
                });
              },
              showBorder: true,
            ),
            _buildSwitchTile(
              title: "Stores notifications",
              subtitle: "Tincidunt integer fringilla orci in non sed.",
              value: storesNotifications,
              onChanged: (val) {
                setState(() {
                  storesNotifications = val;
                });
              },
              showBorder: true,
            ),
            _buildSwitchTile(
              title: "System notifications",
              subtitle: "Tincidunt integer fringilla orci in non sed.",
              value: systemNotifications,
              onChanged: (val) {
                setState(() {
                  systemNotifications = val;
                });
              },
              showBorder: true,
            ),
            _buildSwitchTile(
              title: "Location notifications",
              subtitle: "Tincidunt integer fringilla orci in non sed.",
              value: locationNotifications,
              onChanged: (val) {
                setState(() {
                  locationNotifications = val;
                });
              },
              showBorder: true,
            ),
            _buildSwitchTile(
              title: "Payment notifications",
              subtitle: "Facilisis facilisis velit metus ipsum, vestibulum ipsum arcu, sem lectus.",
              value: paymentNotifications,
              onChanged: (val) {
                setState(() {
                  paymentNotifications = val;
                });
              },
              showBorder: false,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    String? subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    bool showBorder = false,
  }) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: defaultPadding, vertical: defaultPadding / 2),
          child: Row(
            crossAxisAlignment: subtitle != null ? CrossAxisAlignment.start : CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                          ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 13,
                          color: Theme.of(context).textTheme.bodyMedium!.color!.withValues(alpha: 0.4),
                          height: 1.4,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: defaultPadding),
              Switch.adaptive(
                value: value,
                onChanged: onChanged,
                activeTrackColor: Colors.white,
                inactiveTrackColor: const Color(0xFF7B61FF),
              ),
            ],
          ),
        ),
        if (showBorder)
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: defaultPadding),
            child: Divider(
              color: Color(0xFFF3F3F3),
              height: 16,
              thickness: 1,
            ),
          ),
      ],
    );
  }
}
