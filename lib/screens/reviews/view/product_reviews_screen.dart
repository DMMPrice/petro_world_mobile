import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:petro_world/models/product_model.dart';
import 'package:petro_world/models/review_model.dart';
import 'package:petro_world/providers/providers.dart';
import 'package:intl/intl.dart';
import 'package:petro_world/services/api_service.dart';
import '../../../components/review_card.dart';
import '../../../constants.dart';

class ProductReviewsScreen extends ConsumerWidget {
  final ProductModel product;

  const ProductReviewsScreen({super.key, required this.product});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reviewsAsyncValue = ref.watch(reviewsProvider(product.id));
    final currentSort = ref.watch(reviewSortProvider);

    return Scaffold(
      appBar: AppBar(
        title: reviewsAsyncValue.when(
          data: (reviews) => Text("Reviews (${reviews.length})"),
          loading: () => const Text("Reviews (...)"),
          error: (_, __) => const Text("Reviews"),
        ),
      ),
      body: reviewsAsyncValue.when(
        data: (reviews) {
          final currentUserId = ref.watch(userIdProvider);
          final userReviewIndex = reviews.indexWhere((r) => r.userId == currentUserId);
          final hasReviewed = userReviewIndex != -1;
          final userReview = hasReviewed 
              ? reviews[userReviewIndex] 
              : ReviewModel(
                  id: "",
                  productId: "",
                  userId: "",
                  rating: 5,
                  comment: "",
                  createdAt: DateTime.now(),
                );

          if (reviews.isEmpty) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Center(child: Text("No reviews yet")),
                const SizedBox(height: defaultPadding),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
                  child: ElevatedButton(
                    onPressed: () => _showWriteReviewDialog(context, ref),
                    child: const Text("Write a review"),
                  ),
                ),
              ],
            );
          }

          // Sort reviews
          final sortedReviews = List<ReviewModel>.from(reviews);
          switch (currentSort) {
            case ReviewSort.mostRecent:
              sortedReviews.sort((a, b) => b.createdAt.compareTo(a.createdAt));
              break;
            case ReviewSort.highestRated:
              sortedReviews.sort((a, b) => b.rating.compareTo(a.rating));
              break;
            case ReviewSort.lowestRated:
              sortedReviews.sort((a, b) => a.rating.compareTo(b.rating));
              break;
          }

          int fiveStar = reviews.where((r) => r.rating == 5).length;
          int fourStar = reviews.where((r) => r.rating == 4).length;
          int threeStar = reviews.where((r) => r.rating == 3).length;
          int twoStar = reviews.where((r) => r.rating == 2).length;
          int oneStar = reviews.where((r) => r.rating == 1).length;

          double averageRating = reviews.isEmpty 
              ? 0 
              : reviews.map((r) => r.rating).reduce((a, b) => a + b) / reviews.length;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(defaultPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ReviewCard(
                  rating: averageRating,
                  numOfReviews: reviews.length,
                  numOfFiveStar: fiveStar,
                  numOfFourStar: fourStar,
                  numOfThreeStar: threeStar,
                  numOfTwoStar: twoStar,
                  numOfOneStar: oneStar,
                ),
                const SizedBox(height: defaultPadding * 1.5),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _showWriteReviewDialog(
                      context, 
                      ref,
                      initialRating: userReview.rating,
                      initialComment: userReview.comment,
                    ),
                    child: Text(hasReviewed ? "Edit your review" : "Write a review"),
                  ),
                ),
                const SizedBox(height: defaultPadding),
                Row(
                  children: [
                    PopupMenuButton<ReviewSort>(
                      initialValue: currentSort,
                      onSelected: (ReviewSort result) {
                        ref.read(reviewSortProvider.notifier).setSort(result);
                      },
                      itemBuilder: (BuildContext context) => <PopupMenuEntry<ReviewSort>>[
                        const PopupMenuItem<ReviewSort>(
                          value: ReviewSort.mostRecent,
                          child: Text('Most recent'),
                        ),
                        const PopupMenuItem<ReviewSort>(
                          value: ReviewSort.highestRated,
                          child: Text('Highest Rated'),
                        ),
                        const PopupMenuItem<ReviewSort>(
                          value: ReviewSort.lowestRated,
                          child: Text('Lowest Rated'),
                        ),
                      ],
                      child: Row(
                        children: [
                          Text(
                            _getSortLabel(currentSort),
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
                    ),
                  ],
                ),
                const SizedBox(height: defaultPadding),
                ...sortedReviews.map((review) => _buildUserReview(
                      context,
                      name: review.userName ?? "User",
                      time: DateFormat.yMMMd().format(review.createdAt),
                      rating: review.rating.toDouble(),
                      text: review.comment,
                    )),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text("Error: $error")),
      ),
    );
  }

  String _getSortLabel(ReviewSort sort) {
    switch (sort) {
      case ReviewSort.mostRecent:
        return "Most recent";
      case ReviewSort.highestRated:
        return "Highest Rated";
      case ReviewSort.lowestRated:
        return "Lowest Rated";
    }
  }

  void _showWriteReviewDialog(
    BuildContext context, 
    WidgetRef ref, {
    int initialRating = 5,
    String initialComment = "",
  }) {
    int selectedRating = initialRating;
    final TextEditingController commentController = TextEditingController(text: initialComment);
    bool isLoading = false;
    String? errorMessage;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => StatefulBuilder(
        builder: (context, setState) => Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
            top: 20,
            left: 20,
            right: 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Write a Review",
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              if (errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Text(
                    errorMessage!,
                    style: const TextStyle(color: Colors.red, fontSize: 12),
                  ),
                ),
              const Text("Rate the product:"),
              const SizedBox(height: 10),
              RatingBar.builder(
                initialRating: selectedRating.toDouble(),
                minRating: 1,
                direction: Axis.horizontal,
                allowHalfRating: false,
                itemCount: 5,
                itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
                itemBuilder: (context, _) => const Icon(
                  Icons.star,
                  color: Colors.amber,
                ),
                onRatingUpdate: (rating) {
                  setState(() {
                    selectedRating = rating.toInt();
                  });
                },
              ),
              const SizedBox(height: 20),
              TextField(
                controller: commentController,
                maxLines: 4,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: "Write your review here...",
                  hintStyle: const TextStyle(color: Colors.grey),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isLoading ? null : () async {
                    final comment = commentController.text.trim();
                    
                    setState(() {
                      isLoading = true;
                      errorMessage = null;
                    });

                    try {
                      await ApiService.instance.addReview(
                        product.id,
                        selectedRating,
                        comment.isEmpty ? "" : comment, // Send empty string if no comment
                      );
                      
                      // Refresh reviews list
                      ref.invalidate(reviewsProvider(product.id));
                      
                      if (context.mounted) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Review submitted successfully"),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                    } catch (e) {
                      setState(() {
                        isLoading = false;
                        errorMessage = "Failed to submit: $e";
                      });
                    }
                  },
                  child: isLoading 
                    ? const SizedBox(
                        height: 20, 
                        width: 20, 
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                      )
                    : const Text("Submit Review"),
                ),
              ),
            ],
          ),
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
                backgroundColor: Theme.of(context).dividerColor.withValues(alpha: 0.1),
                child: Text(
                  name.isNotEmpty ? name.substring(0, 1) : "U",
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
                        color: Theme.of(context)
                            .textTheme
                            .bodyMedium!
                            .color!
                            .withValues(alpha: 0.5),
                      ),
                    ),
                  ],
                ),
              ),
              RatingBar.builder(
                initialRating: rating,
                itemSize: 16,
                itemPadding: const EdgeInsets.only(right: 2),
                unratedColor: Theme.of(context)
                    .textTheme
                    .bodyLarge!
                    .color!
                    .withValues(alpha: 0.08),
                glow: false,
                ignoreGestures: true,
                onRatingUpdate: (value) {},
                itemBuilder: (context, index) =>
                    SvgPicture.asset("assets/icons/Star_filled.svg"),
              ),
            ],
          ),
          if (text.isNotEmpty) ...[
            const SizedBox(height: defaultPadding),
            Text(
              text,
              style: TextStyle(
                height: 1.5,
                color: Theme.of(context).textTheme.bodyMedium!.color!,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
