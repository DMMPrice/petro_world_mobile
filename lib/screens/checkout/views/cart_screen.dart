import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shop/constants.dart';
import 'package:shop/route/route_constants.dart';
import 'package:shop/providers/providers.dart';
import 'package:shop/services/api_service.dart';
import 'components/cart_item_card.dart';

class CartScreen extends ConsumerWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartAsyncValue = ref.watch(cartProvider);

    return Scaffold(
      body: cartAsyncValue.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) =>
            Center(child: Text('Error loading cart: $error')),
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
                          ref.read(navigationProvider.notifier).setIndex(0);
                        },
                        child: const Text("Start Shopping"),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          final subtotal = cartItems.fold<double>(
            0,
            (sum, item) => sum + (item.product.price * item.quantity),
          );

          final productDiscount = cartItems.fold<double>(
            0,
            (sum, item) =>
                sum +
                ((item.product.price -
                        (item.product.priceAfterDiscount ??
                            item.product.price)) *
                    item.quantity),
          );

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
                            ref
                                .read(cartProvider.notifier)
                                .updateQuantity(item.id!, item.quantity + 1);
                          }
                        },
                        onDecrement: () {
                          if (item.quantity > 1 && item.id != null) {
                            ref
                                .read(cartProvider.notifier)
                                .updateQuantity(item.id!, item.quantity - 1);
                          }
                        },
                        onRemove: () {
                          if (item.id != null) {
                            ref
                                .read(cartProvider.notifier)
                                .removeFromCart(item.id!);
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
                  Consumer(
                    builder: (context, ref, child) {
                      final appliedCoupon = ref.watch(couponProvider);
                      final controller =
                          TextEditingController(text: appliedCoupon?.code);

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: controller,
                                  enabled: appliedCoupon == null,
                                  decoration: InputDecoration(
                                    hintText: "Type coupon code",
                                    prefixIcon: Padding(
                                      padding: const EdgeInsets.all(
                                          defaultPadding * 0.75),
                                      child: SvgPicture.asset(
                                          "assets/icons/Coupon.svg",
                                          colorFilter: const ColorFilter.mode(
                                              blackColor40, BlendMode.srcIn)),
                                    ),
                                    filled: true,
                                    fillColor: Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? whiteColor.withValues(alpha: 0.05)
                                        : lightGreyColor,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(
                                          defaultBorderRadius),
                                      borderSide: BorderSide.none,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: defaultPadding),
                              SizedBox(
                                width: 100,
                                height: 48,
                                child: ElevatedButton(
                                  onPressed: () async {
                                    if (appliedCoupon == null) {
                                      final error = await ref
                                          .read(couponProvider.notifier)
                                          .applyCoupon(controller.text.trim());
                                      if (error != null && context.mounted) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(content: Text(error)),
                                        );
                                      } else if (context.mounted) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                              content: Text(
                                                  "Coupon applied successfully!")),
                                        );
                                      }
                                    } else {
                                      ref
                                          .read(couponProvider.notifier)
                                          .removeCoupon();
                                      controller.clear();
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: appliedCoupon == null
                                        ? primaryColor
                                        : errorColor,
                                    padding: EdgeInsets.zero,
                                  ),
                                  child: Text(appliedCoupon == null
                                      ? "Apply"
                                      : "Remove"),
                                ),
                              ),
                            ],
                          ),
                          if (appliedCoupon != null) ...[
                            const SizedBox(height: 8),
                            Text(
                              "Applied: ${appliedCoupon.code} (${appliedCoupon.type == 'percentage' ? '${appliedCoupon.discount}%' : '₹${appliedCoupon.discount}'} off)",
                              style: const TextStyle(
                                  color: successColor,
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: defaultPadding * 1.5),
                  Container(
                    padding: const EdgeInsets.all(defaultPadding),
                    decoration: BoxDecoration(
                      border: Border.all(color: Theme.of(context).dividerColor),
                      borderRadius: BorderRadius.circular(defaultBorderRadius),
                    ),
                    child: Consumer(
                      builder: (context, ref, child) {
                        final appliedCoupon = ref.watch(couponProvider);
                        final shippingSettings =
                            ref.watch(shippingSettingsProvider);

                        double couponDiscount = 0.0;
                        if (appliedCoupon != null) {
                          if (appliedCoupon.type == 'percentage') {
                            couponDiscount = (subtotal - productDiscount) *
                                (appliedCoupon.discount / 100);
                          } else {
                            couponDiscount = appliedCoupon.discount;
                          }
                        }

                        final totalAfterProductDiscount =
                            subtotal - productDiscount;
                        final shippingFee = totalAfterProductDiscount >
                                shippingSettings.threshold
                            ? 0.0
                            : shippingSettings.fee;
                        final total = totalAfterProductDiscount +
                            shippingFee -
                            couponDiscount;

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Order Summary",
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall!
                                  .copyWith(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: defaultPadding),

                            // Subtotal
                            _SummaryRow(label: "Subtotal", value: subtotal),

                            // Product Discount
                            if (productDiscount > 0)
                              _SummaryRow(
                                  label: "Product Discount",
                                  value: -productDiscount,
                                  valueColor: successColor),

                            const Divider(height: 24),

                            // Total (Bag Total)
                            _SummaryRow(
                              label: "Bag Total",
                              value: totalAfterProductDiscount,
                              isBold: true,
                            ),

                            const SizedBox(height: 8),

                            // Shipping Fee
                            _SummaryRow(
                              label: "Shipping Fee",
                              value: shippingFee,
                              isShipping: true,
                            ),

                            // Coupon Discount
                            if (couponDiscount > 0)
                              _SummaryRow(
                                  label: "Coupon Discount",
                                  value: -couponDiscount,
                                  valueColor: successColor),

                            const Padding(
                              padding: EdgeInsets.symmetric(
                                  vertical: defaultPadding),
                              child: Divider(height: 1),
                            ),

                            // Grand Total
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Grand Total",
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium!
                                      .copyWith(fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  "₹${total.toStringAsFixed(0)}",
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium!
                                      .copyWith(
                                          color: primaryColor,
                                          fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ],
                        );
                      },
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
                child: Consumer(
                  builder: (context, ref, _) {
                    final appliedCoupon = ref.watch(couponProvider);
                    final shippingSettings =
                        ref.watch(shippingSettingsProvider);
                    final subtotal = cartItems.fold<double>(
                      0,
                      (sum, item) => sum + (item.product.price * item.quantity),
                    );
                    final productDiscount = cartItems.fold<double>(
                      0,
                      (sum, item) =>
                          sum +
                          ((item.product.price -
                                  (item.product.priceAfterDiscount ??
                                      item.product.price)) *
                              item.quantity),
                    );
                    final discountedSubtotal = subtotal - productDiscount;
                    final couponDiscount = appliedCoupon == null
                        ? 0.0
                        : appliedCoupon.type == 'percentage'
                            ? discountedSubtotal *
                                (appliedCoupon.discount / 100)
                            : appliedCoupon.discount;
                    final shippingFee =
                        discountedSubtotal > shippingSettings.threshold
                            ? 0.0
                            : shippingSettings.fee;
                    final total =
                        discountedSubtotal + shippingFee - couponDiscount;
                    final itemCount = cartItems.fold<int>(
                        0, (sum, item) => sum + item.quantity);

                    return Container(
                      padding: const EdgeInsets.fromLTRB(
                        defaultPadding,
                        10,
                        defaultPadding,
                        10,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context).scaffoldBackgroundColor,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
                            blurRadius: 12,
                            offset: const Offset(0, -4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '$itemCount item${itemCount == 1 ? '' : 's'}',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                                Text(
                                  '₹${total.toStringAsFixed(0)}',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium!
                                      .copyWith(fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            width: 180,
                            child: ElevatedButton(
                              onPressed: () {
                                if (!ApiService.instance.isLoggedIn) {
                                  Navigator.pushNamed(
                                      context, logInScreenRoute);
                                } else {
                                  Navigator.pushNamed(
                                      context, addressesScreenRoute);
                                }
                              },
                              child: const Text("Proceed to Checkout"),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
        orElse: () => null,
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final double value;
  final Color? valueColor;
  final bool isBold;
  final bool isShipping;

  const _SummaryRow({
    required this.label,
    required this.value,
    this.valueColor,
    this.isBold = false,
    this.isShipping = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                  fontWeight: isBold ? FontWeight.bold : null,
                ),
          ),
          Text(
            isShipping && value == 0
                ? "Free"
                : "₹${value.abs().toStringAsFixed(0)}",
            style: Theme.of(context).textTheme.titleSmall!.copyWith(
                  color: isShipping && value == 0 ? successColor : valueColor,
                  fontWeight: isBold || (isShipping && value == 0)
                      ? FontWeight.bold
                      : null,
                ),
          ),
        ],
      ),
    );
  }
}
