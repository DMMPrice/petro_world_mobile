import 'package:flutter/material.dart';

import '../../../../constants.dart';
import 'categories.dart';
import 'banner_carousel.dart';

class BannerCarouselAndCategories extends StatelessWidget {
  const BannerCarouselAndCategories({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const BannerCarousel(),
        const SizedBox(height: defaultPadding / 2),
        Padding(
          padding: const EdgeInsets.all(defaultPadding),
          child: Text(
            "Categories",
            style: Theme.of(context).textTheme.titleSmall,
          ),
        ),
        const Categories(),
      ],
    );
  }
}
