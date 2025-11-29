import 'package:flutter/material.dart';

/// Stub implementation for non-web platforms
Widget buildWebImageElement(
  String imageUrl, {
  double? width,
  double? height,
  BoxFit fit = BoxFit.cover,
}) {
  // This should never be called on non-web platforms
  throw UnsupportedError('buildWebImageElement is only supported on web');
}

