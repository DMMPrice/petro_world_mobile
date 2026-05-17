import 'product_model.dart';

class CartItemModel {
  final ProductModel product;
  int quantity;
  final String? id; // Cart item ID from backend

  CartItemModel({required this.product, this.quantity = 1, this.id});
}
