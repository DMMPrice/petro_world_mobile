import 'package:flutter/material.dart';
import 'package:shop/constants.dart';
import 'package:shop/models/product_model.dart';
import 'package:shop/components/product/product_card.dart';
import 'package:shop/route/screen_export.dart';

import 'components/offer_carousel_and_categories.dart';

import 'package:shop/services/supabase_service.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: FutureBuilder<List<ProductModel>>(
          future: SupabaseService.getProducts(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }
            final products = snapshot.data ?? [];

            return CustomScrollView(
              slivers: [
                const SliverToBoxAdapter(child: OffersCarouselAndCategories()),
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
                SliverPadding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: defaultPadding),
                  sliver: SliverGrid(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.6,
                      mainAxisSpacing: defaultPadding,
                      crossAxisSpacing: defaultPadding,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => ProductCard(
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
                      ),
                      childCount: products.length,
                    ),
                  ),
                ),
                const SliverToBoxAdapter(
                    child: SizedBox(height: defaultPadding)),
              ],
            );
          },
        ),
      ),
    );
  }
}
