import 'dart:convert';

import 'package:flutter/material.dart';

/// Supports Firestore demo JPEG data and older remote-image listings.
class PropertyImage extends StatelessWidget {
  const PropertyImage(
    this.source, {
    super.key,
    this.fit,
    this.width,
    this.height,
    this.errorBuilder,
  });
  final String source;
  final BoxFit? fit;
  final double? width;
  final double? height;
  final ImageErrorWidgetBuilder? errorBuilder;

  @override
  Widget build(BuildContext context) {
    if (source.startsWith('data:image/jpeg;base64,')) {
      try {
        return Image.memory(
          base64Decode(source.substring(23)),
          fit: fit,
          width: width,
          height: height,
          errorBuilder: errorBuilder,
        );
      } on FormatException catch (error, stack) {
        return errorBuilder?.call(context, error, stack) ??
            const SizedBox.shrink();
      }
    }
    return Image.network(
      source,
      fit: fit,
      width: width,
      height: height,
      errorBuilder: errorBuilder,
    );
  }
}
