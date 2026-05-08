import 'product_model.dart';

class CartItemModel {
  final ProductModel product;
  int quantity;
  final String? id; // Supabase cart item ID

  CartItemModel({required this.product, this.quantity = 1, this.id});
}
