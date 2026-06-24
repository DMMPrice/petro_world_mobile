import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petro_world/components/product/product_card.dart';
import 'package:petro_world/models/product_model.dart';
import 'package:petro_world/route/route_constants.dart';
import 'package:petro_world/providers/providers.dart';

import '../../../constants.dart';

import 'package:petro_world/services/api_service.dart';

class CategoryProductsScreen extends ConsumerWidget {
  const CategoryProductsScreen({super.key, required this.category});

  final String category;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wishlistAsyncValue = ref.watch(wishlistProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(category),
      ),
      body: FutureBuilder<List<ProductModel>>(
        future: ApiService.instance.getProducts(categoryName: category),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }
          final products = snapshot.data ?? [];
          return products.isEmpty
              ? const Center(child: Text("No products found in this category"))
              : GridView.builder(
                  padding: const EdgeInsets.all(defaultPadding),
                  itemCount: products.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.55,
                    mainAxisSpacing: defaultPadding,
                    crossAxisSpacing: defaultPadding,
                  ),
                  itemBuilder: (context, index) {
                    final product = products[index];
                    final isBookmarked = wishlistAsyncValue.maybeWhen(
                      data: (wishlist) => wishlist.any((p) => p.id == product.id),
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
                        Navigator.pushNamed(context, productDetailsScreenRoute,
                            arguments: product);
                      },
                      product: product,
                    );
                  },
                );
        },
      ),
    );
  }
}
