import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../components/review_card.dart';
import '../../../constants.dart';

class ProductReviewsScreen extends StatelessWidget {
  const ProductReviewsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Reviews (104)"),
        actions: [
          IconButton(
            onPressed: () {},
            icon: SvgPicture.asset(
              "assets/icons/Filter.svg",
              colorFilter: ColorFilter.mode(
                Theme.of(context).iconTheme.color!,
                BlendMode.srcIn,
              ),
            ),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const ReviewCard(
              rating: 4.8,
              numOfReviews: 104,
              numOfFiveStar: 80,
              numOfFourStar: 15,
              numOfThreeStar: 5,
              numOfTwoStar: 3,
              numOfOneStar: 1,
            ),
            const SizedBox(height: defaultPadding * 1.5),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {},
                child: const Text("Write a review"),
              ),
            ),
            const SizedBox(height: defaultPadding),
            Row(
              children: [
                Text(
                  "Most recent",
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(width: 8),
                SvgPicture.asset(
                  "assets/icons/miniDown.svg",
                  colorFilter: ColorFilter.mode(
                    Theme.of(context).iconTheme.color!,
                    BlendMode.srcIn,
                  ),
                ),
              ],
            ),
            const SizedBox(height: defaultPadding),
            _buildUserReview(
              context,
              name: "Jane Doe",
              time: "2 days ago",
              rating: 5,
              text:
                  "I absolutely love this product! The quality is amazing and it looks exactly like the pictures. I've been wearing it non-stop since I got it.",
            ),
            _buildUserReview(
              context,
              name: "John Smith",
              time: "1 week ago",
              rating: 4,
              text:
                  "Great fit and comfortable. Only giving 4 stars because shipping took a bit longer than expected.",
            ),
            _buildUserReview(
              context,
              name: "Emily Clark",
              time: "2 weeks ago",
              rating: 5,
              text: "Highly recommend! The material is soft and the color is vibrant.",
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserReview(
    BuildContext context, {
    required String name,
    required String time,
    required double rating,
    required String text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: defaultPadding * 1.5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: Theme.of(context).dividerColor.withOpacity(0.1),
                child: Text(
                  name.substring(0, 1),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: defaultPadding / 2),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    Text(
                      time,
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).textTheme.bodyMedium!.color!.withOpacity(0.5),
                      ),
                    ),
                  ],
                ),
              ),
              RatingBar.builder(
                initialRating: rating,
                itemSize: 16,
                itemPadding: const EdgeInsets.only(right: 2),
                unratedColor: Theme.of(context).textTheme.bodyLarge!.color!.withOpacity(0.08),
                glow: false,
                ignoreGestures: true,
                onRatingUpdate: (value) {},
                itemBuilder: (context, index) => SvgPicture.asset("assets/icons/Star_filled.svg"),
              ),
            ],
          ),
          const SizedBox(height: defaultPadding),
          Text(
            text,
            style: TextStyle(
              height: 1.5,
              color: Theme.of(context).textTheme.bodyMedium!.color!.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }
}
