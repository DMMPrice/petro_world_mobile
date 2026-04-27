import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../constants.dart';

class ShippingMethodsScreen extends StatelessWidget {
  const ShippingMethodsScreen({super.key});

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
                    "Shipping methods",
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  SizedBox(
                    width: 40,
                    child: IconButton(
                      icon: SvgPicture.asset(
                        "assets/icons/info.svg",
                        colorFilter: ColorFilter.mode(
                          Theme.of(context).iconTheme.color!,
                          BlendMode.srcIn,
                        ),
                      ),
                      onPressed: () {},
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(defaultPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildShippingCard(
                      context,
                      icon: "assets/icons/Shield.svg",
                      title: "Standard",
                      subtitle: "Arrives in 5–8 business days",
                      rows: [
                        {"label": "Order up to \$49.99:", "price": "\$4.95"},
                        {"label": "Orders \$50 and over:", "price": "Free"},
                      ],
                      bannerText: "Free with Shoplon Premier",
                      primaryColor: const Color(0xFF7B61FF), // Purple
                    ),
                    const SizedBox(height: defaultPadding),
                    _buildShippingCard(
                      context,
                      icon: "assets/icons/Diamond.svg",
                      title: "Express",
                      subtitle: "Arrives in 2–3 business days",
                      price: "\$14.95",
                      bannerText: "Free with Shoplon Premier",
                      primaryColor: const Color(0xFFBBE5ED), // Light Blue
                      bannerTextColor: Colors.black,
                    ),
                    const SizedBox(height: defaultPadding),
                    _buildShippingCard(
                      context,
                      title: "Rush",
                      subtitle: "Arrives in 1–2 business days",
                      price: "\$21.95",
                    ),
                    const SizedBox(height: defaultPadding),
                    _buildShippingCard(
                      context,
                      title: "Truck",
                      subtitle: "Arrives in 2–4 weeks once shipped",
                      price: "\$102.50",
                    ),
                    const SizedBox(height: defaultPadding * 1.5),
                    Text(
                      "Rush shipping may not be available for all orders depending on fulfillment location.",
                      style: TextStyle(
                        color: Theme.of(context).textTheme.bodyMedium!.color!.withOpacity(0.6),
                      ),
                    ),
                    const SizedBox(height: defaultPadding),
                    RichText(
                      text: TextSpan(
                        style: TextStyle(
                          color: Theme.of(context).textTheme.bodyMedium!.color!.withOpacity(0.6),
                        ),
                        children: const [
                          TextSpan(text: "Shipping outside of the US? See our "),
                          TextSpan(
                            text: "International shipping",
                            style: TextStyle(color: Color(0xFF7B61FF)), // Purple link
                          ),
                          TextSpan(text: " rates."),
                        ],
                      ),
                    ),
                    const SizedBox(height: defaultPadding),
                    Text(
                      "This item is available for delivery to one of our convenient Collection Points.",
                      style: TextStyle(
                        color: Theme.of(context).textTheme.bodyMedium!.color!.withOpacity(0.6),
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

  Widget _buildShippingCard(
    BuildContext context, {
    String? icon,
    required String title,
    required String subtitle,
    String? price,
    List<Map<String, String>>? rows,
    String? bannerText,
    Color? primaryColor,
    Color bannerTextColor = Colors.white,
  }) {
    final borderColor = primaryColor ?? Theme.of(context).dividerColor.withOpacity(0.1);
    
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: borderColor, width: 2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(defaultPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (icon != null) ...[
                      SvgPicture.asset(
                        icon,
                        height: 24,
                        colorFilter: ColorFilter.mode(
                          Theme.of(context).iconTheme.color!,
                          BlendMode.srcIn,
                        ),
                      ),
                      const SizedBox(width: defaultPadding / 2),
                    ],
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            subtitle,
                            style: TextStyle(
                              fontSize: 12,
                              color: Theme.of(context).textTheme.bodyMedium!.color!.withOpacity(0.5),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (price != null)
                      Text(
                        price,
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                  ],
                ),
                if (rows != null) ...[
                  const SizedBox(height: defaultPadding),
                  ...rows.map((row) => Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(row["label"]!),
                            Text(
                              row["price"]!,
                              style: const TextStyle(fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      )),
                ]
              ],
            ),
          ),
          if (bannerText != null && primaryColor != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: primaryColor,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(10),
                  bottomRight: Radius.circular(10),
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                bannerText,
                style: TextStyle(
                  color: bannerTextColor,
                  fontWeight: FontWeight.w500,
                  fontSize: 13,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
