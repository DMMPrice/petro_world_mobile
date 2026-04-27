import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shop/constants.dart';
import 'package:shop/route/route_constants.dart';

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Orders"),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(defaultPadding),
              child: Text(
                "Orders history",
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ),
            OrderHistoryListTile(
              title: "Awaiting Payment",
              svgSrc: "assets/icons/Wallet.svg",
              badgeCount: 0,
              badgeColor: warningColor,
              press: () {
                Navigator.pushNamed(context, awaitingPaymentOrdersScreenRoute);
              },
            ),
            OrderHistoryListTile(
              title: "Processing",
              svgSrc: "assets/icons/Order.svg",
              badgeCount: 1,
              badgeColor: primaryColor,
              press: () {
                Navigator.pushNamed(context, orderProcessingScreenRoute);
              },
            ),
            OrderHistoryListTile(
              title: "Delivered",
              svgSrc: "assets/icons/Delivery.svg",
              badgeCount: 5,
              badgeColor: primaryColor,
              press: () {
                Navigator.pushNamed(context, deliveredOrdersScreenRoute);
              },
            ),
            OrderHistoryListTile(
              title: "Returned",
              svgSrc: "assets/icons/Return.svg",
              badgeCount: 2,
              badgeColor: primaryColor,
              press: () {
                Navigator.pushNamed(context, returnedOrdersScreenRoute);
              },
            ),
            Container(
              color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.5),
              child: OrderHistoryListTile(
                title: "Canceled",
                svgSrc: "assets/icons/Close-Circle.svg",
                badgeCount: 2,
                badgeColor: errorColor,
                press: () {
                  Navigator.pushNamed(context, cancledOrdersScreenRoute);
                },
                isShowDivider: false,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class OrderHistoryListTile extends StatelessWidget {
  const OrderHistoryListTile({
    super.key,
    required this.title,
    required this.svgSrc,
    required this.badgeCount,
    required this.badgeColor,
    required this.press,
    this.isShowDivider = true,
  });

  final String title, svgSrc;
  final int badgeCount;
  final Color badgeColor;
  final VoidCallback press;
  final bool isShowDivider;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          onTap: press,
          minLeadingWidth: 24,
          leading: SvgPicture.asset(
            svgSrc,
            height: 24,
            width: 24,
            colorFilter: ColorFilter.mode(
              Theme.of(context).iconTheme.color!,
              BlendMode.srcIn,
            ),
          ),
          title: Text(title, style: const TextStyle(fontSize: 14)),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (badgeCount > 0 || badgeColor == warningColor)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: badgeColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    badgeCount.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              const SizedBox(width: 8),
              SvgPicture.asset(
                "assets/icons/miniRight.svg",
                height: 16,
                colorFilter: ColorFilter.mode(
                  Theme.of(context).iconTheme.color!.withOpacity(0.4),
                  BlendMode.srcIn,
                ),
              ),
            ],
          ),
        ),
        if (isShowDivider) const Divider(height: 1),
      ],
    );
  }
}
