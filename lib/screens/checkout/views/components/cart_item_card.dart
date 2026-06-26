import 'package:flutter/material.dart';
import 'package:petro_world/components/network_image_with_loader.dart';
import 'package:petro_world/constants.dart';

class CartItemCard extends StatelessWidget {
  const CartItemCard({
    super.key,
    required this.image,
    required this.brandName,
    required this.title,
    required this.price,
    this.priceAfterDiscount,
    this.discountPercent,
    required this.quantity,
    this.onIncrement,
    this.onDecrement,
    this.onRemove,
  });

  final String image, brandName, title;
  final double price;
  final double? priceAfterDiscount;
  final int? discountPercent;
  final int quantity;
  final VoidCallback? onIncrement;
  final VoidCallback? onDecrement;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 114,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).dividerColor),
        borderRadius: const BorderRadius.all(Radius.circular(defaultBorderRadius)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AspectRatio(
            aspectRatio: 1.15,
            child: Stack(
              children: [
                NetworkImageWithLoader(image, radius: defaultBorderRadius),
                if (discountPercent != null)
                  Positioned(
                    right: defaultPadding / 2,
                    top: defaultPadding / 2,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: defaultPadding / 2),
                      height: 16,
                      decoration: const BoxDecoration(
                        color: errorColor,
                        borderRadius: BorderRadius.all(
                            Radius.circular(defaultBorderRadius)),
                      ),
                      child: Text(
                        "$discountPercent% off",
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w500),
                      ),
                    ),
                  )
              ],
            ),
          ),
          const SizedBox(width: defaultPadding / 4),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(defaultPadding / 2),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    brandName.toUpperCase(),
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium!
                        .copyWith(fontSize: 10),
                  ),
                  const SizedBox(height: defaultPadding / 2),
                  Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context)
                        .textTheme
                        .titleSmall!
                        .copyWith(fontSize: 12),
                  ),
                  const Spacer(),
                  priceAfterDiscount != null && priceAfterDiscount! < price
                      ? Row(
                          children: [
                            Text(
                              "₹${priceAfterDiscount!.toStringAsFixed(0)}",
                              style: const TextStyle(
                                color: Color(0xFF31B0D8),
                                fontWeight: FontWeight.w500,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(width: defaultPadding / 4),
                            Text(
                              "₹${price.toStringAsFixed(0)}",
                              style: TextStyle(
                                color: Theme.of(context)
                                    .textTheme
                                    .bodyMedium!
                                    .color,
                                fontSize: 10,
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                          ],
                        )
                      : Text(
                          "₹${price.toStringAsFixed(0)}",
                          style: const TextStyle(
                            color: Color(0xFF31B0D8),
                            fontWeight: FontWeight.w500,
                            fontSize: 12,
                          ),
                        ),
                ],
              ),
            ),
          ),
          // Actions
          Padding(
            padding: const EdgeInsets.symmetric(vertical: defaultPadding / 4),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                IconButton(
                  onPressed: onRemove,
                  icon: const Icon(Icons.close, size: 16),
                  color: errorColor,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Theme.of(context).dividerColor),
                    borderRadius: BorderRadius.circular(defaultBorderRadius),
                  ),
                  child: Row(
                    children: [
                      InkWell(
                        onTap: onDecrement,
                        child: const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          child: Icon(Icons.remove, size: 14),
                        ),
                      ),
                      Text(
                        "$quantity",
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      InkWell(
                        onTap: onIncrement,
                        child: const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          child: Icon(Icons.add, size: 14),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
