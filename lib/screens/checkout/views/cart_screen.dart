import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shop/constants.dart';
import 'package:shop/models/product_model.dart';
import 'components/cart_item_card.dart';

class CartItemModel {
  final ProductModel product;
  int quantity;

  CartItemModel({required this.product, this.quantity = 1});
}

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  // Using demo data for now
  List<CartItemModel> cartItems = [
    CartItemModel(product: demoProducts[0], quantity: 1),
    CartItemModel(product: demoProducts[1], quantity: 2),
    CartItemModel(product: demoProducts[2], quantity: 1),
  ];

  double get subtotal {
    return cartItems.fold(
      0,
      (total, current) =>
          total +
          ((current.product.priceAfterDiscount ?? current.product.price) *
              current.quantity),
    );
  }

  double get discount => 10.0;
  double get estimatedVat => 5.0;

  double get total {
    return subtotal - discount + estimatedVat;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: cartItems.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.shopping_cart_outlined,
                      size: 64, color: greyColor),
                  const SizedBox(height: defaultPadding),
                  Text("Your cart is empty",
                      style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: defaultPadding / 2),
                  const Text("Looks like you haven't added anything yet."),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(defaultPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Review your order",
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: defaultPadding),
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: cartItems.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: defaultPadding),
                    itemBuilder: (context, index) {
                      final item = cartItems[index];
                      return CartItemCard(
                        image: item.product.image,
                        brandName: item.product.brandName,
                        title: item.product.title,
                        price: item.product.price,
                        priceAfterDiscount: item.product.priceAfterDiscount,
                        discountPercent: item.product.discountPercent,
                        quantity: item.quantity,
                        onIncrement: () {
                          setState(() {
                            item.quantity++;
                          });
                        },
                        onDecrement: () {
                          setState(() {
                            if (item.quantity > 1) {
                              item.quantity--;
                            }
                          });
                        },
                        onRemove: () {
                          setState(() {
                            cartItems.removeAt(index);
                          });
                        },
                      );
                    },
                  ),
                  const SizedBox(height: defaultPadding * 1.5),
                  Text(
                    "Your Coupon code",
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: defaultPadding),
                  TextFormField(
                    decoration: InputDecoration(
                      hintText: "Type coupon code",
                      prefixIcon: Padding(
                        padding: const EdgeInsets.all(defaultPadding * 0.75),
                        child: SvgPicture.asset("assets/icons/Coupon.svg", colorFilter: const ColorFilter.mode(blackColor40, BlendMode.srcIn)),
                      ),
                      filled: true,
                      fillColor: Theme.of(context).brightness == Brightness.dark
                          ? whiteColor.withOpacity(0.05)
                          : lightGreyColor,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(defaultBorderRadious),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: defaultPadding * 1.5),
                  Container(
                    padding: const EdgeInsets.all(defaultPadding),
                    decoration: BoxDecoration(
                      border: Border.all(color: Theme.of(context).dividerColor),
                      borderRadius: BorderRadius.circular(defaultBorderRadious),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Order Summary",
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        const SizedBox(height: defaultPadding),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Subtotal", style: Theme.of(context).textTheme.bodyMedium),
                            Text("\$${subtotal.toStringAsFixed(0)}", style: Theme.of(context).textTheme.titleSmall),
                          ],
                        ),
                        const SizedBox(height: defaultPadding / 2),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Shipping Fee", style: Theme.of(context).textTheme.bodyMedium),
                            const Text("Free", style: TextStyle(color: successColor, fontWeight: FontWeight.w500)),
                          ],
                        ),
                        const SizedBox(height: defaultPadding / 2),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Discount", style: Theme.of(context).textTheme.bodyMedium),
                            Text("\$${discount.toStringAsFixed(0)}", style: Theme.of(context).textTheme.titleSmall),
                          ],
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: defaultPadding),
                          child: Divider(height: 1),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Total (Include of VAT)", style: Theme.of(context).textTheme.titleSmall?.copyWith(color: blackColor40)),
                            Text("\$${total.toStringAsFixed(0)}", style: Theme.of(context).textTheme.titleSmall),
                          ],
                        ),
                        const SizedBox(height: defaultPadding / 2),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Estimated VAT", style: Theme.of(context).textTheme.bodyMedium),
                            Text("\$${estimatedVat.toStringAsFixed(0)}", style: Theme.of(context).textTheme.titleSmall),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: defaultPadding * 2),
                ],
              ),
            ),
      bottomNavigationBar: cartItems.isEmpty
          ? null
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: defaultPadding, vertical: defaultPadding / 2),
                child: ElevatedButton(
                  onPressed: () {
                    // TODO: Navigate to Checkout
                  },
                  child: const Text("Continue"),
                ),
              ),
            ),
    );
  }
}
