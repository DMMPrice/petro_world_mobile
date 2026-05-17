import 'package:flutter/material.dart';
import '../../constants.dart';
import '../network_image_with_loader.dart';

class SecondaryProductCard extends StatelessWidget {
  const SecondaryProductCard({
    super.key,
    required this.image,
    required this.brandName,
    required this.title,
    required this.price,
    this.priceAfterDiscount,
    this.discountPercent,
    this.press,
  });

  final String image, brandName, title;
  final dynamic price;
  final dynamic priceAfterDiscount;
  final dynamic discountPercent;
  final VoidCallback? press;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: press,
      borderRadius: const BorderRadius.all(Radius.circular(defaultBorderRadius)),
      child: Container(
        padding: const EdgeInsets.all(defaultPadding / 2),
        decoration: BoxDecoration(
          border: Border.all(color: Theme.of(context).dividerColor.withValues(alpha: 0.1)),
          borderRadius: const BorderRadius.all(Radius.circular(defaultBorderRadius)),
        ),
        child: Row(
          children: [
            SizedBox(
              height: 80,
              width: 80,
              child: NetworkImageWithLoader(image, radius: defaultBorderRadius),
            ),
            const SizedBox(width: defaultPadding),
            Expanded(
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
                  const SizedBox(height: defaultPadding / 4),
                  Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context)
                        .textTheme
                        .titleSmall!
                        .copyWith(fontSize: 12),
                  ),
                  const SizedBox(height: defaultPadding / 4),
                  Row(
                    children: [
                      Text(
                        "₹${(priceAfterDiscount ?? price).toStringAsFixed(0)}",
                        style: const TextStyle(
                          color: primaryColor,
                          fontWeight: FontWeight.w500,
                          fontSize: 12,
                        ),
                      ),
                      if (priceAfterDiscount != null && priceAfterDiscount < price) ...[
                        const SizedBox(width: defaultPadding / 4),
                        Text(
                          "₹${price.toStringAsFixed(0)}",
                          style: TextStyle(
                            color: Theme.of(context)
                                .textTheme
                                .bodyMedium!
                                .color!
                                .withValues(alpha: 0.5),
                            fontSize: 10,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                      ],
                      if (priceAfterDiscount != null && priceAfterDiscount < price && discountPercent != null && discountPercent > 0) ...[
                        const SizedBox(width: defaultPadding / 2),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: defaultPadding / 4),
                          decoration: const BoxDecoration(
                            color: errorColor,
                            borderRadius: BorderRadius.all(
                                Radius.circular(defaultBorderRadius)),
                          ),
                          child: Text(
                            "$discountPercent% off",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 8,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
