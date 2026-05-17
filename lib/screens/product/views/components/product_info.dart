import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../constants.dart';
import 'product_availability_tag.dart';

class ProductInfo extends StatelessWidget {
  const ProductInfo({
    super.key,
    required this.title,
    required this.brand,
    required this.description,
    required this.rating,
    required this.numOfReviews,
    required this.isAvailable,
    required this.price,
    this.priceAfterDiscount,
    this.discountType,
    this.discountValue,
  });

  final String title, brand, description;
  final double rating;
  final int numOfReviews;
  final bool isAvailable;
  final double price;
  final double? priceAfterDiscount;
  final String? discountType;
  final double? discountValue;

  String? get discountLabel {
    // Only show discount if priceAfterDiscount is genuinely lower than price
    if (priceAfterDiscount == null || priceAfterDiscount! >= price) {
      return null;
    }

    if (discountType == 'percentage' && discountValue != null && discountValue! > 0) {
      return "${discountValue!.toInt()}% OFF";
    }
    if (discountType == 'fixed' && discountValue != null && discountValue! > 0) {
      return "₹${discountValue!.toInt()} OFF";
    }
    
    // Final fallback: calculate percent from price difference
    int calculatedPercent = (((price - priceAfterDiscount!) / price) * 100).round();
    if (calculatedPercent > 0) return "$calculatedPercent% OFF";
    
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.all(defaultPadding),
      sliver: SliverToBoxAdapter(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              brand.toUpperCase(),
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: defaultPadding / 2),
            Text(
              title,
              maxLines: 2,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: defaultPadding / 2),
            Row(
              children: [
                Text(
                  "₹${(priceAfterDiscount ?? price).toStringAsFixed(0)}",
                  style: const TextStyle(
                    color: Color(0xFF5DA085),
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
                if (discountLabel != null && priceAfterDiscount != null && priceAfterDiscount! < price) ...[
                  const SizedBox(width: 10),
                  Text(
                    "₹${price.toStringAsFixed(0)}",
                    style: const TextStyle(
                      color: blackColor40,
                      decoration: TextDecoration.lineThrough,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(width: 10),
                  if (discountLabel != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: errorColor.withValues(alpha: 0.1),
                        borderRadius: const BorderRadius.all(Radius.circular(4)),
                      ),
                      child: Text(
                        discountLabel!,
                        style: const TextStyle(
                          color: errorColor,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ],
            ),
            const SizedBox(height: defaultPadding),
            Row(
              children: [
                ProductAvailabilityTag(isAvailable: isAvailable),
                const Spacer(),
                SvgPicture.asset("assets/icons/Star_filled.svg"),
                const SizedBox(width: defaultPadding / 4),
                Text(
                  "$rating ",
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                Text("($numOfReviews Reviews)")
              ],
            ),
            const SizedBox(height: defaultPadding),
            Text(
              "Product info",
              style: Theme.of(context)
                  .textTheme
                  .titleMedium!
                  .copyWith(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: defaultPadding / 2),
            Text(
              description,
              style: const TextStyle(height: 1.4),
            ),
            const SizedBox(height: defaultPadding / 2),
          ],
        ),
      ),
    );
  }
}
