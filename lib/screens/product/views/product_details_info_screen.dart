import 'package:flutter/material.dart';

import '../../../constants.dart';

class ProductDetailsInfoScreen extends StatelessWidget {
  const ProductDetailsInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: defaultPadding),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: defaultPadding / 2),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(
                    width: 40,
                    child: BackButton(),
                  ),
                  Text(
                    "Product details",
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(width: 40),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(defaultPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Story",
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: defaultPadding / 2),
                    Text(
                      "A cool gray cap in soft corduroy. Watch me.' By buying cotton products from Lindex, you’re supporting more responsibly...",
                      style: TextStyle(
                        color: Theme.of(context).textTheme.bodyMedium!.color!.withValues(alpha: 0.7),
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: defaultPadding),
                    const Divider(),
                    const SizedBox(height: defaultPadding),
                    Text(
                      "Details",
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: defaultPadding / 2),
                    _buildBulletPoint(context, "Materials: 100% cotton, and lining Structured"),
                    _buildBulletPoint(context, "Adjustable cotton strap closure"),
                    _buildBulletPoint(context, "High quality embroidery stitching"),
                    _buildBulletPoint(context, "Head circumference: 21” - 24” / 54–62 cm"),
                    _buildBulletPoint(context, "Embroidery stitching"),
                    _buildBulletPoint(context, "One size fits most"),
                    const SizedBox(height: defaultPadding),
                    const Divider(),
                    const SizedBox(height: defaultPadding),
                    Text(
                      "Style Notes",
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: defaultPadding / 2),
                    Text(
                      "Style: Summer Hat\nDesign: Plain\nFabric: Jersey",
                      style: TextStyle(
                        color: Theme.of(context).textTheme.bodyMedium!.color!.withValues(alpha: 0.7),
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: defaultPadding * 2),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBulletPoint(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: defaultPadding / 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 6.0, right: 8.0, left: 4.0),
            child: CircleAvatar(
              radius: 2.5,
              backgroundColor: Theme.of(context).textTheme.bodyMedium!.color!.withValues(alpha: 0.5),
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: Theme.of(context).textTheme.bodyMedium!.color!.withValues(alpha: 0.7),
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
