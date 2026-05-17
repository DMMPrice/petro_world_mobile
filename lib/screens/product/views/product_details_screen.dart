import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shop/components/app_bottom_navigation_bar.dart';
import 'package:shop/models/product_model.dart';
import 'package:shop/components/custom_modal_bottom_sheet.dart';
import 'package:shop/components/product/product_card.dart';
import 'package:shop/constants.dart';
import 'package:shop/screens/product/views/product_returns_screen.dart';
import 'package:shop/route/screen_export.dart';
import 'package:shop/providers/providers.dart';
import 'package:shop/services/supabase_service.dart';
import 'components/notify_me_card.dart';
import 'components/product_images.dart';
import 'components/product_info.dart';
import 'components/product_list_tile.dart';
import '../../../components/review_card.dart';
import 'components/product_quantity.dart';

class ProductDetailsScreen extends ConsumerStatefulWidget {
  const ProductDetailsScreen(
      {super.key, required this.product, this.isProductAvailable = true});

  final ProductModel product;
  final bool isProductAvailable;

  @override
  ConsumerState<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends ConsumerState<ProductDetailsScreen> {
  int _quantity = 1;
  bool _isAddingToCart = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(recentlyViewedProvider.notifier).addProduct(widget.product.id);
    });
  }

  Future<void> _addToCart({bool navigateToCart = false}) async {
    final user = SupabaseService.client.auth.currentUser;
    if (navigateToCart && user == null) {
      Navigator.pushNamed(context, logInScreenRoute);
      return;
    }
    setState(() => _isAddingToCart = true);
    try {
      await ref.read(cartProvider.notifier).addToCart(widget.product.id, _quantity);
      if (!mounted) return;

      if (navigateToCart) {
        ref.read(navigationProvider.notifier).setIndex(3);
        Navigator.popUntil(context, (route) => route.isFirst);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("${widget.product.title} added to cart"),
            action: SnackBarAction(
              label: "View Cart",
              onPressed: () {
                ref.read(navigationProvider.notifier).setIndex(3);
                Navigator.popUntil(context, (route) => route.isFirst);
              },
            ),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    } finally {
      if (mounted) {
        setState(() => _isAddingToCart = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final wishlistAsyncValue = ref.watch(wishlistProvider);
    final isBookmarked = wishlistAsyncValue.maybeWhen(
      data: (wishlist) => wishlist.any((p) => p.id == widget.product.id),
      orElse: () => false,
    );

    final reviewsAsyncValue = ref.watch(reviewsProvider(widget.product.id));
    final dynamicRating = reviewsAsyncValue.maybeWhen(
      data: (reviews) => reviews.isEmpty 
          ? 0.0 
          : reviews.map((r) => r.rating).reduce((a, b) => a + b) / reviews.length,
      orElse: () => widget.product.rating ?? 0.0,
    );
    final dynamicReviewCount = reviewsAsyncValue.maybeWhen(
      data: (reviews) => reviews.length,
      orElse: () => widget.product.reviewCount ?? 0,
    );

    return Scaffold(
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          widget.isProductAvailable
              ? Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: defaultPadding,
                      vertical: defaultPadding / 2),
                  decoration: BoxDecoration(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, -5),
                      )
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _isAddingToCart ? null : () => _addToCart(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: warningColor,
                            foregroundColor: blackColor,
                            minimumSize: const Size(double.infinity, 48),
                          ),
                          child: _isAddingToCart
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: blackColor),
                                )
                              : const Text("Add to Cart"),
                        ),
                      ),
                      const SizedBox(width: defaultPadding),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _isAddingToCart
                              ? null
                              : () => _addToCart(navigateToCart: true),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            foregroundColor: Colors.white,
                            minimumSize: const Size(double.infinity, 48),
                          ),
                          child: const Text("Buy Now"),
                        ),
                      ),
                    ],
                  ),
                )
              : NotifyMeCard(
                  isNotify: false,
                  onChanged: (value) {},
                ),
          const AppBottomNavigationBar(),
        ],
      ),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              floating: true,
              actions: [
                IconButton(
                  onPressed: () {
                    ref.read(wishlistProvider.notifier).toggleWishlist(widget.product.id, product: widget.product);
                  },
                  icon: SvgPicture.asset(
                    isBookmarked ? "assets/icons/heart-filled.svg" : "assets/icons/heart.svg",
                    colorFilter: ColorFilter.mode(
                      isBookmarked ? const Color.fromARGB(255, 255, 0, 0) : Theme.of(context).textTheme.bodyLarge!.color!,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              ],
            ),
            ProductImages(
              images: {
                if (widget.product.image.isNotEmpty) widget.product.image,
                ...widget.product.gallery
              }.toList(),
            ),
            ProductInfo(
              brand: widget.product.brandName,
              title: widget.product.title,
              isAvailable: widget.isProductAvailable,
              description: widget.product.description ??
                  "High-quality petroleum equipment designed for reliability and safety. Engineered to meet industry standards and provide long-lasting performance in demanding environments.",
              rating: dynamicRating,
              numOfReviews: dynamicReviewCount,
              price: widget.product.price,
              priceAfterDiscount: widget.product.priceAfterDiscount,
              discountType: widget.product.discountType,
              discountValue: widget.product.discountValue,
            ),
            if (widget.isProductAvailable)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
                  child: ProductQuantity(
                    numOfItem: _quantity,
                    onIncrement: () => setState(() => _quantity++),
                    onDecrement: () => setState(() {
                      if (_quantity > 1) _quantity--;
                    }),
                  ),
                ),
              ),
            const SliverToBoxAdapter(child: SizedBox(height: defaultPadding)),
            // ProductListTile(
            //   svgSrc: "assets/icons/Product.svg",
            //   title: "Product Details",
            //   press: () {
            //     customModalBottomSheet(
            //       context,
            //       height: MediaQuery.of(context).size.height * 0.92,
            //       child: const ProductDetailsInfoScreen(),
            //     );
            //   },
            // ),
            ProductListTile(
              svgSrc: "assets/icons/Delivery.svg",
              title: "Shipping Information",
              press: () {
                customModalBottomSheet(
                  context,
                  height: MediaQuery.of(context).size.height * 0.92,
                  child: const ShippingMethodsScreen(),
                );
              },
            ),
            ProductListTile(
              svgSrc: "assets/icons/Return.svg",
              title: "Returns",
              isShowBottomBorder: true,
              press: () {
                customModalBottomSheet(
                  context,
                  height: MediaQuery.of(context).size.height * 0.92,
                  child: const ProductReturnsScreen(),
                );
              },
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(defaultPadding),
                child: reviewsAsyncValue.when(
                  data: (reviews) {
                    int fiveStar = reviews.where((r) => r.rating == 5).length;
                    int fourStar = reviews.where((r) => r.rating == 4).length;
                    int threeStar = reviews.where((r) => r.rating == 3).length;
                    int twoStar = reviews.where((r) => r.rating == 2).length;
                    int oneStar = reviews.where((r) => r.rating == 1).length;

                    return ReviewCard(
                      rating: dynamicRating,
                      numOfReviews: reviews.length,
                      numOfFiveStar: fiveStar,
                      numOfFourStar: fourStar,
                      numOfThreeStar: threeStar,
                      numOfTwoStar: twoStar,
                      numOfOneStar: oneStar,
                    );
                  },
                  loading: () => const SizedBox(
                    height: 100,
                    child: Center(child: CircularProgressIndicator()),
                  ),
                  error: (error, stack) => ReviewCard(
                    rating: widget.product.rating ?? 0,
                    numOfReviews: widget.product.reviewCount ?? 0,
                  ),
                ),
              ),
            ),
            ProductListTile(
              svgSrc: "assets/icons/Chat.svg",
              title: "Reviews",
              isShowBottomBorder: true,
              press: () {
                Navigator.pushNamed(
                  context, 
                  productReviewsScreenRoute,
                  arguments: widget.product,
                );
              },
            ),
            const SliverToBoxAdapter(
              child: SizedBox(height: defaultPadding),
            ),
            SliverToBoxAdapter(
              child: Consumer(
                builder: (context, ref, child) {
                  final collaborativeProductsAsync = ref.watch(collaborativeRecommendationsProvider(widget.product));
                  final wishlistAsyncValue = ref.watch(wishlistProvider);

                  return collaborativeProductsAsync.when(
                    data: (products) {
                      if (products.isEmpty) return const SizedBox.shrink();
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
                            child: Text(
                              "Customers also viewed",
                              style: Theme.of(context).textTheme.titleSmall,
                            ),
                          ),
                          const SizedBox(height: defaultPadding),
                          SizedBox(
                            height: 240,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
                              itemCount: products.length,
                              itemBuilder: (context, index) {
                                final product = products[index];
                                final isItemBookmarked = wishlistAsyncValue.maybeWhen(
                                  data: (wishlist) => wishlist.any((p) => p.id == product.id),
                                  orElse: () => false,
                                );

                                return Padding(
                                  padding: const EdgeInsets.only(right: defaultPadding),
                                  child: SizedBox(
                                    width: 140,
                                    child: ProductCard(
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
                                      isBookmarked: isItemBookmarked,
                                      onBookmarkTap: () {
                                        ref.read(wishlistProvider.notifier).toggleWishlist(product.id, product: product);
                                      },
                                      press: () {
                                        Navigator.pushReplacementNamed(context, productDetailsScreenRoute,
                                            arguments: product);
                                      },
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: defaultPadding * 1.5),
                        ],
                      );
                    },
                    loading: () => const SizedBox.shrink(),
                    error: (e, s) => const SizedBox.shrink(),
                  );
                },
              ),
            ),
            SliverToBoxAdapter(
              child: Consumer(
                builder: (context, ref, child) {
                  final relatedProductsAsync = ref.watch(relatedProductsProvider(widget.product));

                  return relatedProductsAsync.when(
                    data: (products) {
                      if (products.isEmpty) return const SizedBox.shrink();
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
                            child: Text(
                              "You may also like",
                              style: Theme.of(context).textTheme.titleSmall,
                            ),
                          ),
                          const SizedBox(height: defaultPadding),
                          SizedBox(
                            height: 240,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
                              itemCount: products.length,
                              itemBuilder: (context, index) {
                                final product = products[index];
                                final isItemBookmarked = wishlistAsyncValue.maybeWhen(
                                  data: (wishlist) => wishlist.any((p) => p.id == product.id),
                                  orElse: () => false,
                                );

                                return Padding(
                                  padding: const EdgeInsets.only(right: defaultPadding),
                                  child: SizedBox(
                                    width: 140,
                                    child: ProductCard(
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
                                      isBookmarked: isItemBookmarked,
                                      onBookmarkTap: () {
                                        ref.read(wishlistProvider.notifier).toggleWishlist(product.id, product: product);
                                      },
                                      press: () {
                                        Navigator.pushReplacementNamed(context, productDetailsScreenRoute,
                                            arguments: product);
                                      },
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      );
                    },
                    loading: () => const SizedBox.shrink(),
                    error: (e, s) => const SizedBox.shrink(),
                  );
                },
              ),
            ),
            // Recently Viewed Section
            SliverToBoxAdapter(
              child: Consumer(
                builder: (context, ref, child) {
                  final recentlyViewedAsync = ref.watch(recentlyViewedProvider);
                  final wishlistAsyncValue = ref.watch(wishlistProvider);

                  return recentlyViewedAsync.when(
                    data: (products) {
                      // Filter out the current product from recently viewed
                      final filteredProducts = products.where((p) => p.id != widget.product.id).toList();
                      if (filteredProducts.isEmpty) return const SizedBox.shrink();

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: defaultPadding),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
                            child: Text(
                              "Recently Viewed",
                              style: Theme.of(context).textTheme.titleSmall,
                            ),
                          ),
                          const SizedBox(height: defaultPadding),
                          SizedBox(
                            height: 240,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
                              itemCount: filteredProducts.length,
                              itemBuilder: (context, index) {
                                final p = filteredProducts[index];
                                final isItemBookmarked = wishlistAsyncValue.maybeWhen(
                                  data: (wishlist) => wishlist.any((item) => item.id == p.id),
                                  orElse: () => false,
                                );

                                return Padding(
                                  padding: const EdgeInsets.only(right: defaultPadding),
                                  child: SizedBox(
                                    width: 140,
                                    child: ProductCard(
                                      productId: p.id,
                                      image: p.image,
                                      brandName: p.brandName,
                                      title: p.title,
                                      price: p.price,
                                      priceAfterDiscount: p.priceAfterDiscount,
                                      discountPercent: p.discountPercent,
                                      discountType: p.discountType,
                                      discountValue: p.discountValue,
                                      rating: p.rating,
                                      reviewCount: p.reviewCount,
                                      isBookmarked: isItemBookmarked,
                                      onBookmarkTap: () {
                                        ref.read(wishlistProvider.notifier).toggleWishlist(p.id, product: p);
                                      },
                                      press: () {
                                        Navigator.pushReplacementNamed(context, productDetailsScreenRoute,
                                            arguments: p);
                                      },
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      );
                    },
                    loading: () => const SizedBox.shrink(),
                    error: (e, s) => const SizedBox.shrink(),
                  );
                },
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: defaultPadding * 2)),
          ],
        ),
      ),
    );
  }
}
