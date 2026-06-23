import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import '../../constants.dart';
import '../network_image_with_loader.dart';

class SecondaryProductCard extends StatefulWidget {
  const SecondaryProductCard({
    super.key,
    required this.image,
    required this.brandName,
    required this.title,
    required this.price,
    this.priceAfterDiscount,
    this.discountPercent,
    this.press,
  });

  final String image, brandName, title;
  final dynamic price;
  final dynamic priceAfterDiscount;
  final dynamic discountPercent;
  final VoidCallback? press;

  @override
  State<SecondaryProductCard> createState() => _SecondaryProductCardState();
}

class _SecondaryProductCardState extends State<SecondaryProductCard> {
  BoxFit _imageFit = BoxFit.cover;

  @override
  void initState() {
    super.initState();
    _resolveImageFit();
  }

  @override
  void didUpdateWidget(covariant SecondaryProductCard oldWidget) {
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

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: widget.press,
      borderRadius:
          const BorderRadius.all(Radius.circular(defaultBorderRadius)),
      child: Container(
        padding: const EdgeInsets.all(defaultPadding / 2),
        decoration: BoxDecoration(
          border: Border.all(
              color: Theme.of(context).dividerColor.withValues(alpha: 0.1)),
          borderRadius:
              const BorderRadius.all(Radius.circular(defaultBorderRadius)),
        ),
        child: Row(
          children: [
            SizedBox(
              height: 80,
              width: 80,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(defaultBorderRadius),
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
            const SizedBox(width: defaultPadding),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.brandName.toUpperCase(),
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium!
                        .copyWith(fontSize: 10),
                  ),
                  const SizedBox(height: defaultPadding / 4),
                  Text(
                    widget.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context)
                        .textTheme
                        .titleSmall!
                        .copyWith(fontSize: 12),
                  ),
                  const SizedBox(height: defaultPadding / 4),
                  Row(
                    children: [
                      Text(
                        "₹${(widget.priceAfterDiscount ?? widget.price).toStringAsFixed(0)}",
                        style: const TextStyle(
                          color: primaryColor,
                          fontWeight: FontWeight.w500,
                          fontSize: 12,
                        ),
                      ),
                      if (widget.priceAfterDiscount != null &&
                          widget.priceAfterDiscount < widget.price) ...[
                        const SizedBox(width: defaultPadding / 4),
                        Text(
                          "₹${widget.price.toStringAsFixed(0)}",
                          style: TextStyle(
                            color: Theme.of(context)
                                .textTheme
                                .bodyMedium!
                                .color!
                                .withValues(alpha: 0.5),
                            fontSize: 10,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                      ],
                      if (widget.priceAfterDiscount != null &&
                          widget.priceAfterDiscount < widget.price &&
                          widget.discountPercent != null &&
                          widget.discountPercent > 0) ...[
                        const SizedBox(width: defaultPadding / 2),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: defaultPadding / 4),
                          decoration: const BoxDecoration(
                            color: errorColor,
                            borderRadius: BorderRadius.all(
                                Radius.circular(defaultBorderRadius)),
                          ),
                          child: Text(
                            "${widget.discountPercent}% off",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 8,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
