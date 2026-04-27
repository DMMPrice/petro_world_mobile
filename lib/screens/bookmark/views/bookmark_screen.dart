import 'package:flutter/material.dart';
import 'package:shop/components/product/product_card.dart';
import 'package:shop/models/product_model.dart';
import 'package:shop/route/route_constants.dart';

import '../../../constants.dart';

import 'package:shop/services/supabase_service.dart';

class BookmarkScreen extends StatelessWidget {
  const BookmarkScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List<ProductModel>>(
        future: SupabaseService.getWishlist(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final products = snapshot.data ?? [];

          if (products.isEmpty) {
            return const Center(child: Text("Your wishlist is empty."));
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
                    childAspectRatio: 0.6,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (BuildContext context, int index) {
                      return ProductCard(
                        image: products[index].image,
                        brandName: products[index].brandName,
                        title: products[index].title,
                        price: products[index].price,
                        priceAfterDiscount: products[index].priceAfterDiscount,
                        discountPercent: products[index].discountPercent,
                        press: () {
                          Navigator.pushNamed(
                              context, productDetailsScreenRoute,
                              arguments: products[index]);
                        },
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
