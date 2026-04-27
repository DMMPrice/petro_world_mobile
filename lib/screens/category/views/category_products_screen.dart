import 'package:flutter/material.dart';
import 'package:shop/components/product/product_card.dart';
import 'package:shop/models/product_model.dart';
import 'package:shop/route/route_constants.dart';

import '../../../constants.dart';

import 'package:shop/services/supabase_service.dart';

class CategoryProductsScreen extends StatelessWidget {
  const CategoryProductsScreen({super.key, required this.category});

  final String category;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(category),
      ),
      body: SafeArea(
        child: FutureBuilder<List<ProductModel>>(
          future: SupabaseService.getProducts(categoryName: category),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }
            final products = snapshot.data ?? [];

            return products.isEmpty
                ? const Center(child: Text("No products found in this category"))
                : GridView.builder(
                    padding: const EdgeInsets.all(defaultPadding),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.6,
                      mainAxisSpacing: defaultPadding,
                      crossAxisSpacing: defaultPadding,
                    ),
                    itemCount: products.length,
                    itemBuilder: (context, index) => ProductCard(
                      image: products[index].image,
                      brandName: products[index].brandName,
                      title: products[index].title,
                      price: products[index].price,
                      priceAfterDiscount: products[index].priceAfterDiscount,
                      discountPercent: products[index].discountPercent,
                      press: () {
                        Navigator.pushNamed(context, productDetailsScreenRoute,
                            arguments: products[index]);
                      },
                    ),
                  );
          },
        ),
      ),
    );
  }
}
