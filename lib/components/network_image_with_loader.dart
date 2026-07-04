import 'dart:convert';
import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../constants.dart';
import 'skleton/skelton.dart';

class NetworkImageWithLoader extends StatelessWidget {
  final BoxFit fit;

  const NetworkImageWithLoader(
    this.src, {
    super.key,
    this.fit = BoxFit.cover,
    this.radius = defaultPadding,
  });

  final String src;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final imageSource = src.trim();

    // If URL is missing show a placeholder immediately — no network call needed
    if (imageSource.isEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.all(Radius.circular(radius)),
        child: _placeholder(),
      );
    }

    final dataImage = _decodeDataImage(imageSource);
    if (dataImage != null) {
      return ClipRRect(
        borderRadius: BorderRadius.all(Radius.circular(radius)),
        child: Image.memory(
          dataImage,
          fit: fit,
          errorBuilder: (_, __, ___) => _placeholder(),
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.all(Radius.circular(radius)),
      child: CachedNetworkImage(
        fit: fit,
        imageUrl: imageSource,
        imageBuilder: (context, imageProvider) => Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: imageProvider,
              fit: fit,
            ),
          ),
        ),
        placeholder: (context, url) => const Skeleton(),
        errorWidget: (context, url, error) => _placeholder(),
      ),
    );
  }

  Uint8List? _decodeDataImage(String value) {
    final trimmedValue = value.trim();
    if (!trimmedValue.toLowerCase().startsWith('data:image/')) return null;
    final commaIndex = trimmedValue.indexOf(',');
    if (commaIndex == -1) return null;

    try {
      final base64Payload =
          trimmedValue.substring(commaIndex + 1).replaceAll(RegExp(r'\s+'), '');
      return base64Decode(base64Payload);
    } catch (_) {
      return null;
    }
  }

  /// A soft grey box with a product icon — shown when image URL is empty or fails.
  Widget _placeholder() {
    return Container(
      color: const Color(0xFFF3F4F6),
      child: Center(
        child: Icon(
          Icons.inventory_2_outlined,
          size: 40,
          color: Colors.grey.shade300,
        ),
      ),
    );
  }
}
