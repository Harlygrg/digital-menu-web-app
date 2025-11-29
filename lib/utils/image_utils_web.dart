import 'package:flutter/material.dart';
import 'dart:ui_web' as ui_web;
import 'dart:html' as html;

/// Web-specific implementation using HTML img element
Widget buildWebImageElement(
  String imageUrl, {
  double? width,
  double? height,
  BoxFit fit = BoxFit.cover,
}) {
  // Generate a unique view ID for this image
  final viewId = 'img-${imageUrl.hashCode}-${DateTime.now().millisecondsSinceEpoch}';
  
  // Register the view factory
  // ignore: undefined_prefixed_name
  ui_web.platformViewRegistry.registerViewFactory(
    viewId,
    (int viewId) {
      final imgElement = html.ImageElement()
        ..src = imageUrl
        ..style.width = '100%'
        ..style.height = '100%'
        ..style.objectFit = _getObjectFit(fit)
        ..style.display = 'block';
      
      return imgElement;
    },
  );
  
  return SizedBox(
    width: width,
    height: height,
    child: HtmlElementView(viewType: viewId),
  );
}

/// Convert BoxFit to CSS object-fit value
String _getObjectFit(BoxFit fit) {
  switch (fit) {
    case BoxFit.contain:
      return 'contain';
    case BoxFit.cover:
      return 'cover';
    case BoxFit.fill:
      return 'fill';
    case BoxFit.fitWidth:
      return 'scale-down';
    case BoxFit.fitHeight:
      return 'scale-down';
    case BoxFit.none:
      return 'none';
    case BoxFit.scaleDown:
      return 'scale-down';
  }
}

