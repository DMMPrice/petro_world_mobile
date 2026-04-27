import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shop/components/product/secondary_product_card.dart';
import 'package:shop/constants.dart';

import 'order_status_tracker.dart';

class OrderCard extends StatelessWidget {
  const OrderCard({
    super.key,
    required this.orderId,
    required this.date,
    required this.status,
    required this.products,
  });

  final String orderId;
  final String date;
  final OrderStatus status;
  final List<Map<String, dynamic>> products;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(
          horizontal: defaultPadding, vertical: defaultPadding / 2),
      padding: const EdgeInsets.all(defaultPadding),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Order $orderId",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Placed on $date",
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).textTheme.bodySmall!.color,
                    ),
                  ),
                ],
              ),
              IconButton(
                onPressed: () {},
                icon: SvgPicture.asset(
                  "assets/icons/miniRight.svg",
                  colorFilter: ColorFilter.mode(
                    Theme.of(context).iconTheme.color!,
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ],
          ),
          const Divider(height: 24),
          
          // Tracker
          OrderStatusTracker(status: status),
          
          const Divider(height: 24),
          
          // Items
          ...products.map((product) => Padding(
                padding: const EdgeInsets.only(bottom: defaultPadding),
                child: SecondaryProductCard(
                  image: product['image'],
                  brandName: product['brandName'],
                  title: product['title'],
                  price: product['price'],
                  priceAfterDiscount: product['priceAfterDiscount'],
                  discountPercent: product['discountPercent'],
                ),
              )),
        ],
      ),
    );
  }
}
