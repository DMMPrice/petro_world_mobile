import 'package:flutter/material.dart';
import 'package:shop/models/product_model.dart';

import '../../constants.dart';
import '../network_image_with_loader.dart';

import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/providers.dart';

class ProductCard extends StatelessWidget {
  const ProductCard({
    super.key,
    required this.productId,
    required this.image,
    required this.brandName,
    required this.title,
    required this.price,
    this.priceAfterDiscount,
    this.discountPercent,
    this.discountType,
    this.discountValue,
    this.rating,
    this.reviewCount,
    this.isBookmarked = false,
    this.onBookmarkTap,
    required this.press,
    this.product,
  });
  final String productId, image, brandName, title;
  final double price;
  final double? priceAfterDiscount;
  final int? discountPercent;
  final String? discountType;
  final double? discountValue;
  final double? rating;
  final int? reviewCount;
  final bool isBookmarked;
  final VoidCallback? onBookmarkTap;
  final VoidCallback press;
  final ProductModel? product;

  String? get discountLabel {
    // Only show discount if priceAfterDiscount is genuinely lower than price
    if (priceAfterDiscount == null || priceAfterDiscount! >= price) {
      return null;
    }

    if (discountPercent != null && discountPercent! > 0) {
      return "$discountPercent% OFF";
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
    return InkWell(
      onTap: press,
      borderRadius: const BorderRadius.all(Radius.circular(defaultBorderRadius)),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: blackColor10),
          borderRadius: const BorderRadius.all(Radius.circular(defaultBorderRadius)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 1,
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(defaultBorderRadius),
                    ),
                    child: NetworkImageWithLoader(image, radius: 0),
                  ),
                  if (discountLabel != null)
                    Positioned(
                      left: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: const BoxDecoration(
                          color: errorColor,
                          borderRadius: BorderRadius.all(Radius.circular(4)),
                        ),
                        child: Text(
                          discountLabel!,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  Positioned(
                    right: 8,
                    top: 8,
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: onBookmarkTap,
                        customBorder: const CircleBorder(),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.9),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 4,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                          child: SvgPicture.asset(
                            isBookmarked 
                              ? "assets/icons/heart-filled.svg" 
                              : "assets/icons/heart.svg",
                            height: 20,
                            width: 20,
                            colorFilter: ColorFilter.mode(
                              isBookmarked ? const Color.fromARGB(255, 255, 0, 0) : blackColor, 
                              BlendMode.srcIn
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      brandName,
                      style: Theme.of(context).textTheme.bodySmall!.copyWith(
                            color: blackColor40,
                            fontSize: 11,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: blackColor,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        Consumer(
                          builder: (context, ref, child) {
                            final reviewsAsync = ref.watch(reviewsProvider(productId));
                            final currentRating = reviewsAsync.maybeWhen(
                              data: (reviews) => reviews.isEmpty 
                                  ? 0.0 
                                  : reviews.map((r) => r.rating).reduce((a, b) => a + b) / reviews.length,
                              orElse: () => rating ?? 0.0,
                            );
                            final currentReviewCount = reviewsAsync.maybeWhen(
                              data: (reviews) => reviews.length,
                              orElse: () => reviewCount ?? 0,
                            );

                            return Row(
                              children: [
                                SvgPicture.asset(
                                  "assets/icons/Star_filled.svg",
                                  height: 12,
                                  colorFilter: const ColorFilter.mode(
                                      Color(0xFFFFAD33), BlendMode.srcIn),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  currentRating.toStringAsFixed(1),
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: blackColor60,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                const Text(
                                  "|",
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: blackColor20,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  "$currentReviewCount",
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: blackColor60,
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                        const Spacer(),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            if (discountLabel != null) ...[
                              Text(
                                "₹$price",
                                style: const TextStyle(
                                  color: blackColor40,
                                  decoration: TextDecoration.lineThrough,
                                  fontSize: 12,
                                ),
                              ),
                              Text(
                                "₹${priceAfterDiscount!.toStringAsFixed(0)}",
                                style: const TextStyle(
                                  color: Color(0xFF5DA085),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                            ] else
                              Text(
                                "₹${price.toStringAsFixed(0)}",
                                style: const TextStyle(
                                  color: blackColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
