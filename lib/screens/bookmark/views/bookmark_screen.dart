import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petro_world/components/product/product_card.dart';
import 'package:petro_world/route/route_constants.dart';
import 'package:petro_world/providers/providers.dart';

import '../../../constants.dart';

class BookmarkScreen extends ConsumerWidget {
  const BookmarkScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wishlistAsyncValue = ref.watch(wishlistProvider);

    return Scaffold(
      body: wishlistAsyncValue.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (products) {
          if (products.isEmpty) {
            return Padding(
              padding: const EdgeInsets.all(defaultPadding),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.favorite_border,
                        size: 64, color: greyColor),
                    const SizedBox(height: defaultPadding),
                    Text("Your wishlist is empty",
                        style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: defaultPadding / 2),
                    const Text("Looks like you haven't added anything yet.",
                        textAlign: TextAlign.center),
                    const SizedBox(height: defaultPadding),
                    SizedBox(
                      width: 200,
                      child: ElevatedButton(
                        onPressed: () {
                          ref.read(navigationProvider.notifier).setIndex(0);
                        },
                        child: const Text("Start Shopping"),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return CustomScrollView(
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.symmetric(
                    horizontal: defaultPadding, vertical: defaultPadding),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 200.0,
                    mainAxisSpacing: defaultPadding,
                    crossAxisSpacing: defaultPadding,
                    childAspectRatio: 0.7,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (BuildContext context, int index) {
                      final product = products[index];
                      return ProductCard(
                        productId: product.id,
                        image: product.image,
                        brandName: product.brandName,
                        title: product.title,
                        price: product.price,
                        priceAfterDiscount: product.priceAfterDiscount,
                        discountPercent: product.discountPercent,
                        discountType: product.discountType,
                        discountValue: product.discountValue,
                        rating: product.rating,
                        reviewCount: product.reviewCount,
                        isBookmarked: true,
                        onBookmarkTap: () {
                          ref.read(wishlistProvider.notifier).toggleWishlist(product.id, product: product);
                        },
                        press: () {
                          Navigator.pushNamed(
                              context, productDetailsScreenRoute,
                              arguments: product);
                        },
                        product: product,
                      );
                    },
                    childCount: products.length,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
