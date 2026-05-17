import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shop/constants.dart';
import 'package:shop/models/address_model.dart';
import 'package:shop/models/cart_item_model.dart';
import 'package:shop/providers/providers.dart';
import 'package:shop/route/route_constants.dart';
import 'package:shop/services/api_service.dart';

// Only import razorpay on non-web platforms
import 'payment_screen_native.dart' if (dart.library.html) 'payment_screen_web.dart';

/// Arguments passed to PaymentScreen via Navigator.
class PaymentScreenArgs {
  final String addressId;
  final AddressModel address;
  final List<CartItemModel> cartItems;
  final double total;
  final String? couponId;
  final double couponDiscount;
  final double subtotal; // Original price sum
  final double productDiscount;

  const PaymentScreenArgs({
    required this.addressId,
    required this.address,
    required this.cartItems,
    required this.total,
    this.couponId,
    this.couponDiscount = 0,
    required this.subtotal,
    required this.productDiscount,
  });
}

class PaymentScreen extends ConsumerStatefulWidget {
  final PaymentScreenArgs args;
  const PaymentScreen({super.key, required this.args});

  @override
  ConsumerState<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends ConsumerState<PaymentScreen> {
  // On web, default to COD since Razorpay native SDK doesn't support web
  String _selectedMethod = kIsWeb ? 'cod' : 'razorpay';
  bool _isLoading = false;

  // RazorpayController handles the platform-specific Razorpay lifecycle
  // (null on web, active on Android/iOS)
  RazorpayController? _rzpController;

  String? _pendingRazorpayOrderId;

  @override
  void initState() {
    super.initState();
    if (!kIsWeb) {
      _rzpController = RazorpayController(
        onSuccess: _handlePaymentSuccess,
        onError: _handlePaymentError,
        onWallet: _handleExternalWallet,
      );
    }
  }

  @override
  void dispose() {
    _rzpController?.dispose();
    super.dispose();
  }

  // ── Razorpay Callbacks ──────────────────────────────────────────

  Future<void> _handlePaymentSuccess(Map<String, String?> response) async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      await ApiService.instance.verifyRazorpayAndPlaceOrder(
        razorpayOrderId:   response['orderId']   ?? _pendingRazorpayOrderId ?? '',
        razorpayPaymentId: response['paymentId'] ?? '',
        razorpaySignature: response['signature'] ?? '',
        addressId:         widget.args.addressId,
        total:             widget.args.total,
        items:             widget.args.cartItems,
        couponId:          widget.args.couponId,
        couponDiscount:    widget.args.couponDiscount,
      );
      ref.invalidate(cartProvider);
      ref.read(couponProvider.notifier).removeCoupon();
      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(
        context,
        thanksForOrderScreenRoute,
        (route) => route.settings.name == entryPointScreenRoute,
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      _showError('Payment verified but order placement failed: $e');
    }
  }

  void _handlePaymentError(String message) {
    if (!mounted) return;
    setState(() => _isLoading = false);
    _pendingRazorpayOrderId = null;
    _showError(message.isNotEmpty ? message : 'Payment was not completed. Please try again.');
  }

  void _handleExternalWallet(String walletName) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('External wallet selected: $walletName')),
    );
  }

  // ── Pay Online via Razorpay ─────────────────────────────────────

  Future<void> _initiateRazorpayPayment() async {
    if (kIsWeb || _rzpController == null) {
      _showError('Online payment is only available on the mobile app.');
      return;
    }

    setState(() => _isLoading = true);
    try {
      final receipt = 'pw_${DateTime.now().millisecondsSinceEpoch}';
      final orderData = await ApiService.instance.createRazorpayOrder(
        totalAmount: widget.args.total,
        receipt:     receipt,
      );

      _pendingRazorpayOrderId = orderData['razorpay_order_id']?.toString() ?? '';

      // Prefill customer info
      final profile = await ApiService.instance.getProfile();
      final user = ApiService.instance.currentUser;

      final String prefillName =
          profile?['full_name']?.toString() ?? widget.args.address.name;
      final String prefillEmail = user?.email ?? '';
      final String prefillContact =
          profile?['phone']?.toString() ?? widget.args.address.phoneNumber;

      final options = <String, dynamic>{
        'key': orderData['key_id'],
        'amount': orderData['amount'],
        'currency': orderData['currency'] ?? 'INR',
        'order_id': _pendingRazorpayOrderId,
        'name': 'PetroWorld',
        'description': '${widget.args.cartItems.length} item(s)',
        'prefill': {
          'name': prefillName,
          'email': prefillEmail,
          'contact': prefillContact,
        },
        'theme': {'color': '#1a1a2e'},
        'send_sms_hash': true,
        'remember_customer': true,
      };

      setState(() => _isLoading = false);
      _rzpController!.open(options);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      _showError('Could not initiate payment: $e');
    }
  }

  // ── COD ─────────────────────────────────────────────────────────

  Future<void> _placeCodOrder() async {
    setState(() => _isLoading = true);
    try {
      await ApiService.instance.placeOrder(
        addressId: widget.args.addressId,
        total: widget.args.total,
        items: widget.args.cartItems,
        paymentMethod: 'Cash on Delivery',
        couponId: widget.args.couponId,
        couponDiscount: widget.args.couponDiscount,
      );
      ref.invalidate(cartProvider);
      ref.read(couponProvider.notifier).removeCoupon();
      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(
        context,
        thanksForOrderScreenRoute,
        (route) => route.settings.name == entryPointScreenRoute,
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      _showError('Failed to place order: $e');
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: Colors.red.shade700,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // ── UI ──────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final args = widget.args;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Order Summary Card ───────────────────────────────────
            _SectionCard(
              title: 'Order Summary',
              isDark: isDark,
              child: Column(
                children: [
                  ...args.cartItems.map((item) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                '${item.product.title} × ${item.quantity}',
                                style: theme.textTheme.bodyMedium,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Text(
                              '₹${((item.product.priceAfterDiscount ?? item.product.price) * item.quantity).toStringAsFixed(0)}',
                              style: theme.textTheme.titleSmall,
                            ),
                          ],
                        ),
                      )),
                  const Divider(height: 20),
                  
                  // Subtotal
                  _SummaryRow(label: 'Subtotal', value: args.subtotal),
                  
                  // Product Discount
                  if (args.productDiscount > 0)
                    _SummaryRow(
                      label: 'Product Discount',
                      value: -args.productDiscount,
                      valueColor: successColor,
                    ),
                  
                  const Divider(height: 20),
                  
                  // Bag Total
                  _SummaryRow(
                    label: 'Bag Total',
                    value: args.subtotal - args.productDiscount,
                    isBold: true,
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Shipping Fee
                  Consumer(
                    builder: (context, ref, child) {
                      final settings = ref.watch(shippingSettingsProvider);
                      final bagTotal = args.subtotal - args.productDiscount;
                      final shippingFee = bagTotal > settings.threshold ? 0.0 : settings.fee;
                      return _SummaryRow(
                        label: 'Shipping Fee',
                        value: shippingFee,
                        isShipping: true,
                      );
                    },
                  ),
                  
                  // Coupon Discount
                  if (args.couponDiscount > 0)
                    _SummaryRow(
                      label: 'Coupon Discount',
                      value: -args.couponDiscount,
                      valueColor: successColor,
                    ),
                    
                  const Divider(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Grand Total',
                          style: theme.textTheme.titleMedium!
                              .copyWith(fontWeight: FontWeight.bold)),
                      Text(
                        '₹${args.total.toStringAsFixed(0)}',
                        style: theme.textTheme.titleMedium!.copyWith(
                          color: primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: defaultPadding),

            // ── Delivery Address ─────────────────────────────────────
            _SectionCard(
              title: 'Delivering To',
              isDark: isDark,
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: primaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child:
                        const Icon(Icons.location_on, color: primaryColor, size: 20),
                  ),
                  const SizedBox(width: defaultPadding),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(args.address.name,
                            style: theme.textTheme.titleSmall),
                        const SizedBox(height: 2),
                        Text(
                          '${args.address.address}, ${args.address.city}, ${args.address.state} – ${args.address.pincode}',
                          style: theme.textTheme.bodySmall,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: defaultPadding),

            // ── Payment Method ───────────────────────────────────────
            Text('Select Payment Method',
                style: theme.textTheme.titleSmall),
            const SizedBox(height: defaultPadding / 2),

            // Razorpay option — only selectable on mobile
            _PaymentOption(
              value: 'razorpay',
              groupValue: _selectedMethod,
              onChanged: kIsWeb
                  ? null // disabled on web
                  : (v) => setState(() => _selectedMethod = v!),
              icon: Icons.credit_card_rounded,
              iconColor: kIsWeb ? Colors.grey : const Color(0xFF072654),
              title: 'Pay Online',
              subtitle: kIsWeb
                  ? 'Available on Android & iOS app only'
                  : 'Cards, UPI, Net Banking, Wallets via Razorpay',
              badge: kIsWeb ? null : 'RECOMMENDED',
              badgeColor: primaryColor,
              isDark: isDark,
              disabled: kIsWeb,
            ),

            const SizedBox(height: defaultPadding / 2),

            _PaymentOption(
              value: 'cod',
              groupValue: _selectedMethod,
              onChanged: (v) => setState(() => _selectedMethod = v!),
              icon: Icons.payments_rounded,
              iconColor: Colors.green.shade700,
              title: 'Cash on Delivery',
              subtitle: 'Pay when your order arrives',
              isDark: isDark,
            ),

            const SizedBox(height: defaultPadding * 2),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: defaultPadding, vertical: defaultPadding / 2),
          child: ElevatedButton(
            onPressed: _isLoading
                ? null
                : () {
                    if (_selectedMethod == 'razorpay') {
                      _initiateRazorpayPayment();
                    } else {
                      _placeCodOrder();
                    }
                  },
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 52),
            ),
            child: _isLoading
                ? const SizedBox(
                    height: 22,
                    width: 22,
                    child: CircularProgressIndicator(
                        strokeWidth: 2.5, color: Colors.white),
                  )
                : Text(
                    _selectedMethod == 'razorpay'
                        ? 'Pay ₹${widget.args.total.toStringAsFixed(0)}'
                        : 'Place Order (COD)',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16),
                  ),
          ),
        ),
      ),
    );
  }
}

// ── Helper Widgets ────────────────────────────────────────────────

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;
  final bool isDark;

  const _SectionCard({
    required this.title,
    required this.child,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(defaultPadding),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.05)
            : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(defaultBorderRadius),
        border: Border.all(
          color: isDark ? Colors.white12 : Colors.grey.shade200,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: Theme.of(context)
                  .textTheme
                  .titleSmall!
                  .copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: defaultPadding),
          child,
        ],
      ),
    );
  }
}

class _PaymentOption extends StatelessWidget {
  final String value;
  final String groupValue;
  final ValueChanged<String?>? onChanged;
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final String? badge;
  final Color? badgeColor;
  final bool isDark;
  final bool disabled;

  const _PaymentOption({
    required this.value,
    required this.groupValue,
    required this.onChanged,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    this.badge,
    this.badgeColor,
    required this.isDark,
    this.disabled = false,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = value == groupValue;
    final theme = Theme.of(context);

    return Opacity(
      opacity: disabled ? 0.45 : 1.0,
      child: GestureDetector(
        onTap: disabled ? null : () => onChanged?.call(value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(defaultPadding),
          decoration: BoxDecoration(
            color: isSelected
                ? primaryColor.withValues(alpha: 0.08)
                : isDark
                    ? Colors.white.withValues(alpha: 0.04)
                    : Colors.grey.shade50,
            borderRadius: BorderRadius.circular(defaultBorderRadius),
            border: Border.all(
              color: isSelected
                  ? primaryColor
                  : (isDark ? Colors.white12 : Colors.grey.shade200),
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: iconColor, size: 22),
              ),
              const SizedBox(width: defaultPadding),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(title,
                            style: theme.textTheme.titleSmall!.copyWith(
                              fontWeight: FontWeight.w600,
                            )),
                        if (badge != null) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: (badgeColor ?? primaryColor)
                                  .withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              badge!,
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                color: badgeColor ?? primaryColor,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(subtitle,
                        style: theme.textTheme.bodySmall!
                            .copyWith(color: Colors.grey)),
                  ],
                ),
              ),
              RadioGroup<String>(
                groupValue: groupValue,
                onChanged: (val) {
                  if (!disabled && onChanged != null) {
                    onChanged!(val);
                  }
                },
                child: Radio<String>(
                  value: value,
                  activeColor: primaryColor,
                ),
              ),
            ],
          ),
        ),
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
