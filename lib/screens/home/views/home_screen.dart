import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petro_world/constants.dart';
import 'package:petro_world/components/product/product_card.dart';
import 'package:petro_world/route/screen_export.dart';
import 'package:petro_world/components/shimmer_wrapper.dart';

import 'components/banner_carousel_and_categories.dart';
import 'package:petro_world/providers/providers.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_loadMoreNearBottom);
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_loadMoreNearBottom)
      ..dispose();
    super.dispose();
  }

  void _loadMoreNearBottom() {
    if (!_scrollController.hasClients) return;
    if (_scrollController.position.extentAfter < 700) {
      ref.read(homeProductsProvider.notifier).loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final productsAsyncValue = ref.watch(homeProductsProvider);
    final wishlistAsyncValue = ref.watch(wishlistProvider);
    final selectedCategory = ref.watch(homeSelectedCategoryProvider);

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          controller: _scrollController,
          cacheExtent: 900,
          slivers: [
            const SliverToBoxAdapter(child: BannerCarouselAndCategories()),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(defaultPadding),
                child: Text(
                  selectedCategory ?? "All Products",
                  style: const TextStyle(
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
              data: (pagedProducts) {
                final products = pagedProducts.items;
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
            productsAsyncValue.maybeWhen(
              data: (pagedProducts) {
                if (!pagedProducts.isLoadingMore &&
                    pagedProducts.loadMoreError == null) {
                  return const SliverToBoxAdapter(
                    child: SizedBox(height: defaultPadding),
                  );
                }

                return SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: defaultPadding,
                    ),
                    child: Center(
                      child: pagedProducts.loadMoreError != null
                          ? TextButton(
                              onPressed: () => ref
                                  .read(homeProductsProvider.notifier)
                                  .loadMore(),
                              child: const Text('Retry loading products'),
                            )
                          : const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                    ),
                  ),
                );
              },
              orElse: () => const SliverToBoxAdapter(
                  child: SizedBox(height: defaultPadding)),
            ),
          ],
        ),
      ),
    );
  }
}

class ProductGridSkeleton extends StatefulWidget {
  const ProductGridSkeleton({super.key});

  @override
  State<ProductGridSkeleton> createState() => _ProductGridSkeletonState();
}

class _ProductGridSkeletonState extends State<ProductGridSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  Timer? _delayTimer;
  bool _showDelayLoader = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();
    _delayTimer = Timer(const Duration(milliseconds: 1400), () {
      if (mounted) {
        setState(() => _showDelayLoader = true);
      }
    });
  }

  @override
  void dispose() {
    _delayTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
      child: Column(
        children: [
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.7,
              mainAxisSpacing: defaultPadding,
              crossAxisSpacing: defaultPadding,
            ),
            itemCount: 4,
            itemBuilder: (context, index) => const ProductCardSkeleton(),
          ),
          AnimatedSwitcher(
            duration: defaultDuration,
            switchInCurve: Curves.easeOutCubic,
            switchOutCurve: Curves.easeInCubic,
            child: _showDelayLoader
                ? Padding(
                    key: const ValueKey('delayed-home-loader'),
                    padding: const EdgeInsets.only(top: 6, bottom: 18),
                    child: _DelayedLoadingIndicator(controller: _controller),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

class _DelayedLoadingIndicator extends StatelessWidget {
  const _DelayedLoadingIndicator({required this.controller});

  final Animation<double> controller;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var index = 0; index < 3; index++)
              Transform.translate(
                offset: Offset(
                  0,
                  math.sin((controller.value * math.pi * 2) + index * 0.75) * 3,
                ),
                child: Container(
                  width: 7,
                  height: 7,
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  decoration: BoxDecoration(
                    color: Color.lerp(
                      primaryColor,
                      navyColor,
                      index / 2,
                    ),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            const SizedBox(width: 10),
            const Text(
              'Loading is taking a little longer',
              style: TextStyle(
                color: blackColor60,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        );
      },
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
