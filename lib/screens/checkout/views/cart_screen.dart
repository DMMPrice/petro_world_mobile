import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shop/constants.dart';
import 'package:shop/route/route_constants.dart';
import 'package:shop/providers/providers.dart';
import 'components/cart_item_card.dart';

class CartScreen extends ConsumerWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartAsyncValue = ref.watch(cartProvider);

    return Scaffold(
      body: cartAsyncValue.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error loading cart: $error')),
        data: (cartItems) {
          if (cartItems.isEmpty) {
            return Padding(
              padding: const EdgeInsets.all(defaultPadding),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.shopping_cart_outlined,
                        size: 64, color: greyColor),
                    const SizedBox(height: defaultPadding),
                    Text("Your cart is empty",
                        style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: defaultPadding / 2),
                    const Text("Looks like you haven't added anything yet.",
                        textAlign: TextAlign.center),
                    const SizedBox(height: defaultPadding),
                    SizedBox(
                      width: 200,
                      child: ElevatedButton(
                        onPressed: () {
                          if (Navigator.canPop(context)) {
                            Navigator.popUntil(context, ModalRoute.withName(entryPointScreenRoute));
                          } else {
                            Navigator.pushNamedAndRemoveUntil(
                                context, entryPointScreenRoute, (route) => false);
                          }
                        },
                        child: const Text("Start Shopping"),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          final originalSubtotal = cartItems.fold<double>(
            0,
            (sum, item) => sum + (item.product.price * item.quantity),
          );
          
          final productDiscount = cartItems.fold<double>(
            0,
            (sum, item) => sum + ((item.product.price - (item.product.priceAfterDiscount ?? item.product.price)) * item.quantity),
          );

          const couponDiscount = 0.0; // Dynamic coupon discount could be added here later
          final estimatedVat = (originalSubtotal - productDiscount - couponDiscount) * 0.05; // 5% VAT
          final total = (originalSubtotal - productDiscount - couponDiscount) + estimatedVat;

          return RefreshIndicator(
            onRefresh: () async => ref.refresh(cartProvider),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
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
                          if (item.id != null) {
                            ref.read(cartProvider.notifier).updateQuantity(item.id!, item.quantity + 1);
                          }
                        },
                        onDecrement: () {
                          if (item.quantity > 1 && item.id != null) {
                            ref.read(cartProvider.notifier).updateQuantity(item.id!, item.quantity - 1);
                          }
                        },
                        onRemove: () {
                          if (item.id != null) {
                            ref.read(cartProvider.notifier).removeFromCart(item.id!);
                          }
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
                        child: SvgPicture.asset("assets/icons/Coupon.svg",
                            colorFilter: const ColorFilter.mode(
                                blackColor40, BlendMode.srcIn)),
                      ),
                      filled: true,
                      fillColor: Theme.of(context).brightness == Brightness.dark
                          ? whiteColor.withOpacity(0.05)
                          : lightGreyColor,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(defaultBorderRadius),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: defaultPadding * 1.5),
                  Container(
                    padding: const EdgeInsets.all(defaultPadding),
                    decoration: BoxDecoration(
                      border: Border.all(color: Theme.of(context).dividerColor),
                      borderRadius: BorderRadius.circular(defaultBorderRadius),
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
                            Text("Subtotal",
                                style: Theme.of(context).textTheme.bodyMedium),
                            Text("₹${originalSubtotal.toStringAsFixed(0)}",
                                style: Theme.of(context).textTheme.titleSmall),
                          ],
                        ),
                        const SizedBox(height: defaultPadding / 2),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Shipping Fee",
                                style: Theme.of(context).textTheme.bodyMedium),
                            const Text("Free",
                                style: TextStyle(
                                    color: successColor,
                                    fontWeight: FontWeight.w500)),
                          ],
                        ),
                        const SizedBox(height: defaultPadding / 2),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Product Discount",
                                style: Theme.of(context).textTheme.bodyMedium),
                            Text("-₹${productDiscount.toStringAsFixed(0)}",
                                style: Theme.of(context).textTheme.titleSmall!.copyWith(color: successColor)),
                          ],
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: defaultPadding),
                          child: Divider(height: 1),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Total (Include of VAT)",
                                style: Theme.of(context)
                                    .textTheme
                                    .titleSmall
                                    ?.copyWith(color: blackColor40)),
                            Text("₹${total.toStringAsFixed(0)}",
                                style: Theme.of(context).textTheme.titleSmall),
                          ],
                        ),
                        const SizedBox(height: defaultPadding / 2),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Estimated VAT",
                                style: Theme.of(context).textTheme.bodyMedium),
                            Text("₹${estimatedVat.toStringAsFixed(0)}",
                                style: Theme.of(context).textTheme.titleSmall),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: defaultPadding * 2),
                ],
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: cartAsyncValue.maybeWhen(
        data: (cartItems) => cartItems.isEmpty
            ? null
            : SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: defaultPadding, vertical: defaultPadding / 2),
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, addressesScreenRoute);
                    },
                    child: const Text("Continue"),
                  ),
                ),
              ),
        orElse: () => null,
      ),
    );
  }
}
