import 'package:flutter/material.dart';
import 'package:petro_world/models/product_model.dart';
import 'package:petro_world/models/cart_item_model.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import '../../constants.dart';
import '../network_image_with_loader.dart';

import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/providers.dart';

class ProductCard extends ConsumerStatefulWidget {
  const ProductCard({
    super.key,
    required this.productId,
    required this.image,
    required this.brandName,
    required this.title,
    required this.price,
    this.priceAfterDiscount,
    this.discountPercent,
    this.discountType,
    this.discountValue,
    this.rating,
    this.reviewCount,
    this.isBookmarked = false,
    this.onBookmarkTap,
    required this.press,
    this.product,
    this.description,
  });

  final String productId, image, brandName, title;
  final double price;
  final double? priceAfterDiscount;
  final int? discountPercent;
  final String? discountType;
  final double? discountValue;
  final double? rating;
  final int? reviewCount;
  final bool isBookmarked;
  final VoidCallback? onBookmarkTap;
  final VoidCallback press;
  final ProductModel? product;
  final String? description;

  @override
  ConsumerState<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends ConsumerState<ProductCard> {
  bool _addingToCart = false;
  BoxFit _imageFit = BoxFit.cover;

  String? get descriptionText => widget.description ?? widget.product?.description;

  @override
  void initState() {
    super.initState();
    _resolveImageFit();
  }

  @override
  void didUpdateWidget(covariant ProductCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.image != widget.image) {
      _resolveImageFit();
    }
  }

  Future<void> _resolveImageFit() async {
    final source = widget.image;
    final provider = _imageProviderFor(source);
    if (provider == null) {
      if (mounted) {
        setState(() => _imageFit = BoxFit.contain);
      }
      return;
    }

    final stream = provider.resolve(const ImageConfiguration());
    final completer = Completer<ImageInfo>();
    late final ImageStreamListener listener;
    listener = ImageStreamListener(
      (info, _) {
        if (!completer.isCompleted) completer.complete(info);
      },
      onError: (_, __) {
        if (!completer.isCompleted) {
          completer.completeError('image-load-failed');
        }
      },
    );

    stream.addListener(listener);
    try {
      final info = await completer.future.timeout(const Duration(seconds: 5));
      final w = info.image.width.toDouble();
      final h = info.image.height.toDouble();
      if (w <= 0 || h <= 0) return;

      final ratio = w / h;
      final nextFit =
          (ratio >= 0.85 && ratio <= 1.25) ? BoxFit.cover : BoxFit.contain;

      if (!mounted || source != widget.image) return;
      if (_imageFit != nextFit) {
        setState(() => _imageFit = nextFit);
      }
    } catch (_) {
      if (mounted && source == widget.image && _imageFit != BoxFit.contain) {
        setState(() => _imageFit = BoxFit.contain);
      }
    } finally {
      stream.removeListener(listener);
    }
  }

  ImageProvider? _imageProviderFor(String source) {
    if (source.isEmpty) return null;
    final bytes = _decodeDataImage(source);
    if (bytes != null) return MemoryImage(bytes);
    return NetworkImage(source);
  }

  Uint8List? _decodeDataImage(String value) {
    if (!value.startsWith('data:image/')) return null;
    final commaIndex = value.indexOf(',');
    if (commaIndex == -1) return null;
    try {
      return base64Decode(value.substring(commaIndex + 1));
    } catch (_) {
      return null;
    }
  }

  String? get discountLabel {
    final priceAfterDiscount = widget.priceAfterDiscount;
    if (priceAfterDiscount == null || priceAfterDiscount >= widget.price)
      return null;

    if (widget.discountPercent != null && widget.discountPercent! > 0) {
      return '${widget.discountPercent}% OFF';
    }
    if (widget.discountType == 'percentage' &&
        widget.discountValue != null &&
        widget.discountValue! > 0) {
      return '${widget.discountValue!.toInt()}% OFF';
    }
    if (widget.discountType == 'fixed' &&
        widget.discountValue != null &&
        widget.discountValue! > 0) {
      return '₹${widget.discountValue!.toInt()} OFF';
    }
    final pct =
        (((widget.price - priceAfterDiscount) / widget.price) * 100).round();
    if (pct > 0) return '$pct% OFF';
    return null;
  }

  /// Returns the CartItemModel for this product if it is already in the cart.
  CartItemModel? _cartItem(List<CartItemModel> cart) {
    try {
      return cart.firstWhere((i) => i.product.id == widget.productId);
    } catch (_) {
      return null;
    }
  }

  Future<void> _increment(List<CartItemModel> cart) async {
    setState(() => _addingToCart = true);
    try {
      final item = _cartItem(cart);
      if (item == null) {
        await ref.read(cartProvider.notifier).addToCart(widget.productId, 1);
      } else {
        await ref
            .read(cartProvider.notifier)
            .updateQuantity(item.id!, item.quantity + 1);
      }
    } finally {
      if (mounted) setState(() => _addingToCart = false);
    }
  }

  Future<void> _decrement(List<CartItemModel> cart) async {
    final item = _cartItem(cart);
    if (item == null) return;
    setState(() => _addingToCart = true);
    try {
      if (item.quantity <= 1) {
        await ref.read(cartProvider.notifier).removeFromCart(item.id!);
      } else {
        await ref
            .read(cartProvider.notifier)
            .updateQuantity(item.id!, item.quantity - 1);
      }
    } finally {
      if (mounted) setState(() => _addingToCart = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cartAsync = ref.watch(cartProvider);
    final cart = cartAsync.value ?? [];
    final cartItem = _cartItem(cart);
    final qty = cartItem?.quantity ?? 0;

    return InkWell(
      onTap: widget.press,
      borderRadius:
          const BorderRadius.all(Radius.circular(defaultBorderRadius)),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: blackColor10),
          borderRadius:
              const BorderRadius.all(Radius.circular(defaultBorderRadius)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // â”€â”€ Image + overlays â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
            AspectRatio(
              aspectRatio: 1,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(defaultBorderRadius),
                      ),
                      child: Container(
                        color: const Color(0xFFF7F7F7),
                        child: NetworkImageWithLoader(
                          widget.image,
                          radius: 0,
                          fit: _imageFit,
                        ),
                      ),
                    ),
                  ),

                  // Discount badge
                  if (discountLabel != null)
                    Positioned(
                      left: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: const BoxDecoration(
                          color: errorColor,
                          borderRadius: BorderRadius.all(Radius.circular(4)),
                        ),
                        child: Text(
                          discountLabel!,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                  // Wishlist button
                  Positioned(
                    right: 8,
                    top: 8,
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: widget.onBookmarkTap,
                        customBorder: const CircleBorder(),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.9),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 4,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                          child: SvgPicture.asset(
                            widget.isBookmarked
                                ? 'assets/icons/heart-filled.svg'
                                : 'assets/icons/heart.svg',
                            height: 20,
                            width: 20,
                            colorFilter: ColorFilter.mode(
                              widget.isBookmarked
                                  ? const Color.fromARGB(255, 255, 0, 0)
                                  : blackColor,
                              BlendMode.srcIn,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // â”€â”€ Blinkit-style quantity stepper (bottom-right of image) â”€â”€
                  Positioned(
                    bottom: 8,
                    right: 8,
                    child: _QuantityStepper(
                      qty: qty,
                      loading: _addingToCart,
                      onAdd: () => _increment(cart),
                      onDecrement: () => _decrement(cart),
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (widget.brandName.isNotEmpty) ...[
                      Text(
                        widget.brandName,
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall!
                            .copyWith(color: blackColor40, fontSize: 11),
                      ),
                      const SizedBox(height: 4),
                    ],
                    Text(
                      widget.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: blackColor,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (descriptionText != null && descriptionText!.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        descriptionText!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: blackColor60,
                          fontSize: 13,
                        ),
                      ),
                    ],
                    const Spacer(),

                    // Rating + price row
                    Row(
                      children: [
                        Consumer(
                          builder: (context, ref, _) {
                            final reviewsAsync =
                                ref.watch(reviewsProvider(widget.productId));
                            final currentRating = reviewsAsync.maybeWhen(
                              data: (reviews) => reviews.isEmpty
                                  ? 0.0
                                  : reviews
                                          .map((r) => r.rating)
                                          .reduce((a, b) => a + b) /
                                      reviews.length,
                              orElse: () => widget.rating ?? 0.0,
                            );
                            final currentCount = reviewsAsync.maybeWhen(
                              data: (reviews) => reviews.length,
                              orElse: () => widget.reviewCount ?? 0,
                            );
                            return Row(
                              children: [
                                SvgPicture.asset(
                                  'assets/icons/Star_filled.svg',
                                  height: 12,
                                  colorFilter: const ColorFilter.mode(
                                      Color(0xFFFFAD33), BlendMode.srcIn),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  currentRating.toStringAsFixed(1),
                                  style: const TextStyle(
                                      fontSize: 12, color: blackColor60),
                                ),
                                const SizedBox(width: 4),
                                const Text('|',
                                    style: TextStyle(
                                        fontSize: 12, color: blackColor20)),
                                const SizedBox(width: 4),
                                Text(
                                  '$currentCount',
                                  style: const TextStyle(
                                      fontSize: 12, color: blackColor60),
                                ),
                              ],
                            );
                          },
                        ),
                        const Spacer(),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            if (discountLabel != null) ...[
                              Text(
                                '₹${widget.price.toStringAsFixed(0)}',
                                style: const TextStyle(
                                  color: blackColor40,
                                  decoration: TextDecoration.lineThrough,
                                  fontSize: 12,
                                ),
                              ),
                              Text(
                                '₹${widget.priceAfterDiscount!.toStringAsFixed(0)}',
                                style: const TextStyle(
                                  color: Color(0xFF5DA085),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                            ] else
                              Text(
                                '₹${widget.price.toStringAsFixed(0)}',
                                style: const TextStyle(
                                  color: blackColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// â”€â”€ Blinkit-style quantity stepper â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

class _QuantityStepper extends StatelessWidget {
  const _QuantityStepper({
    required this.qty,
    required this.loading,
    required this.onAdd,
    required this.onDecrement,
  });

  final int qty;
  final bool loading;
  final VoidCallback onAdd;
  final VoidCallback onDecrement;

  static const _h = 34.0;
  static const _green = Color(0xFF0C831F); // Blinkit green

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return Container(
        height: _h,
        width: _h,
        decoration: BoxDecoration(
          color: _green,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Center(
          child: SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Colors.white,
            ),
          ),
        ),
      );
    }

    if (qty == 0) {
      // Single "+" button
      return GestureDetector(
        onTap: onAdd,
        child: Container(
          height: _h,
          width: _h,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: _green, width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: const Icon(Icons.add, color: _green, size: 20),
        ),
      );
    }

    // "-  qty  +" stepper
    return Container(
      height: _h,
      decoration: BoxDecoration(
        color: _green,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Minus
          GestureDetector(
            onTap: onDecrement,
            child: const SizedBox(
              width: 30,
              height: _h,
              child: Icon(Icons.remove, color: Colors.white, size: 16),
            ),
          ),
          // Count
          Container(
            constraints: const BoxConstraints(minWidth: 26),
            alignment: Alignment.center,
            child: Text(
              '$qty',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
          // Plus
          GestureDetector(
            onTap: onAdd,
            child: const SizedBox(
              width: 30,
              height: _h,
              child: Icon(Icons.add, color: Colors.white, size: 16),
            ),
          ),
        ],
      ),
    );
  }
}
