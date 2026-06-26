import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petro_world/constants.dart';
import 'package:petro_world/components/product/product_card.dart';
import 'package:petro_world/route/screen_export.dart';
import 'package:petro_world/components/shimmer_wrapper.dart';

import 'components/banner_carousel_and_categories.dart';
import 'package:petro_world/providers/providers.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsyncValue = ref.watch(productsProvider);
    final wishlistAsyncValue = ref.watch(wishlistProvider);

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            const SliverToBoxAdapter(child: BannerCarouselAndCategories()),
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(defaultPadding),
                child: Text(
                  "All Products",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            productsAsyncValue.when(
              loading: () =>
                  const SliverToBoxAdapter(child: ProductGridSkeleton()),
              error: (error, stack) => SliverToBoxAdapter(
                child: Center(child: Text('Error: $error')),
              ),
              data: (products) {
                if (products.isEmpty) {
                  return const SliverToBoxAdapter(
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.all(defaultPadding),
                        child: Text("No products found."),
                      ),
                    ),
                  );
                }

                return SliverPadding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: defaultPadding),
                  sliver: SliverGrid(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.7,
                      mainAxisSpacing: defaultPadding,
                      crossAxisSpacing: defaultPadding,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final product = products[index];
                        final isBookmarked = wishlistAsyncValue.maybeWhen(
                          data: (wishlist) =>
                              wishlist.any((p) => p.id == product.id),
                          orElse: () => false,
                        );

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
                          isBookmarked: isBookmarked,
                          onBookmarkTap: () {
                            ref
                                .read(wishlistProvider.notifier)
                                .toggleWishlist(product.id, product: product);
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
                );
              },
            ),
            const SliverToBoxAdapter(child: SizedBox(height: defaultPadding)),
          ],
        ),
      ),
    );
  }
}

class ProductGridSkeleton extends StatelessWidget {
  const ProductGridSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.7,
          mainAxisSpacing: defaultPadding,
          crossAxisSpacing: defaultPadding,
        ),
        itemCount: 4, // Show 4 skeletons initially
        itemBuilder: (context, index) => const ProductCardSkeleton(),
      ),
    );
  }
}

class ProductCardSkeleton extends StatelessWidget {
  const ProductCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: blackColor10),
        borderRadius: BorderRadius.circular(defaultBorderRadius),
      ),
      child: ShimmerWrapper(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final contentWidth = constraints.maxWidth;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AspectRatio(
                  aspectRatio: 1.25,
                  child: SkeletonBox(
                    width: double.infinity,
                    height: double.infinity,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SkeletonBox(width: contentWidth * 0.45, height: 10),
                      const SizedBox(height: 8),
                      SkeletonBox(width: contentWidth, height: 12),
                      const SizedBox(height: 4),
                      SkeletonBox(width: contentWidth * 0.7, height: 12),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child:
                                SkeletonBox(width: double.infinity, height: 12),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child:
                                SkeletonBox(width: double.infinity, height: 16),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
