import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

/// Utility class for handling base64 images
class ImageUtils {
  /// Convert base64 string to Uint8List
  static Uint8List? base64ToUint8List(String base64String) {
    try {
      if (base64String.isEmpty) return null;
      
      // Remove data URL prefix if present
      String cleanBase64 = base64String;
      if (base64String.contains(',')) {
        cleanBase64 = base64String.split(',')[1];
      }
      
      return base64Decode(cleanBase64);
    } catch (e) {
      // Silently handle errors to avoid performance impact
      return null;
    }
  }

  /// Create an Image widget from base64 string or network URL
  /// Priority: base64 -> imageUrl -> error widget
  static Widget buildImageFromBase64(
    String base64String, {
    String? imageUrl,
    double? width,
    double? height,
    BoxFit fit = BoxFit.cover,
    Widget? placeholder,
    Widget? errorWidget,
    bool gaplessPlayback = true,
    int? cacheWidth,
    int? cacheHeight,
  }) {
    // Try base64 first (existing behavior)
    if (base64String.isNotEmpty) {
      final imageData = base64ToUint8List(base64String);
      
      if (imageData != null) {
        return Image.memory(
          imageData,
          width: width,
          height: height,
          fit: fit,
          gaplessPlayback: gaplessPlayback,
          cacheWidth: cacheWidth,
          cacheHeight: cacheHeight,
          errorBuilder: (context, error, stackTrace) {
            return errorWidget ?? _buildDefaultErrorWidget(width, height);
          },
        );
      }
    }
    
    // Fallback to network image if imageUrl is provided
    if (imageUrl != null && imageUrl.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: imageUrl,
        width: width,
        height: height,
        fit: fit,
        memCacheWidth: cacheWidth,
        memCacheHeight: cacheHeight,
        fadeInDuration: const Duration(milliseconds: 200),
        fadeOutDuration: const Duration(milliseconds: 100),
        placeholder: placeholder != null ? (context, url) => placeholder : null,
        errorWidget: errorWidget != null
            ? (context, url, error) => errorWidget
            : (context, url, error) => _buildDefaultErrorWidget(width, height),
      );
    }
    
    // Show error widget if both are unavailable
    return errorWidget ?? _buildDefaultErrorWidget(width, height);
  }

  /// Create a circular image from base64 string or network URL
  /// Priority: base64 -> imageUrl -> error widget
  static Widget buildCircularImageFromBase64(
    String base64String, {
    String? imageUrl,
    double? size,
    Widget? placeholder,
    Widget? errorWidget,
    bool gaplessPlayback = true,
    int? cacheWidth,
    int? cacheHeight,
  }) {
    // Try base64 first (existing behavior)
    if (base64String.isNotEmpty) {
      final imageData = base64ToUint8List(base64String);
      
      if (imageData != null) {
        return ClipOval(
          child: Image.memory(
            imageData,
            width: size,
            height: size,
            fit: BoxFit.cover,
            gaplessPlayback: gaplessPlayback,
            cacheWidth: cacheWidth,
            cacheHeight: cacheHeight,
            errorBuilder: (context, error, stackTrace) {
              return errorWidget ?? _buildDefaultCircularErrorWidget(size);
            },
          ),
        );
      }
    }
    
    // Fallback to network image if imageUrl is provided
    if (imageUrl != null && imageUrl.isNotEmpty) {
      return ClipOval(
        child: CachedNetworkImage(
          imageUrl: imageUrl,
          width: size,
          height: size,
          fit: BoxFit.cover,
          memCacheWidth: cacheWidth,
          memCacheHeight: cacheHeight,
          fadeInDuration: const Duration(milliseconds: 200),
          fadeOutDuration: const Duration(milliseconds: 100),
          placeholder: placeholder != null ? (context, url) => placeholder : null,
          errorWidget: errorWidget != null 
              ? (context, url, error) => errorWidget
              : (context, url, error) => _buildDefaultCircularErrorWidget(size),
        ),
      );
    }
    
    // Show error widget if both are unavailable
    return errorWidget ?? _buildDefaultCircularErrorWidget(size);
  }

  /// Build default error widget
  static Widget _buildDefaultErrorWidget(double? width, double? height) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        Icons.image_not_supported,
        color: Colors.grey[400],
        size: width != null ? width * 0.4 : 32,
      ),
    );
  }

  /// Build default circular error widget
  static Widget _buildDefaultCircularErrorWidget(double? size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        shape: BoxShape.circle,
      ),
      child: Icon(
        Icons.person,
        color: Colors.grey[400],
        size: size != null ? size * 0.4 : 32,
      ),
    );
  }


  /// Check if base64 string is valid
  static bool isValidBase64(String base64String) {
    try {
      if (base64String.isEmpty) return false;
      
      String cleanBase64 = base64String;
      if (base64String.contains(',')) {
        cleanBase64 = base64String.split(',')[1];
      }
      
      base64Decode(cleanBase64);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Get image format from base64 string
  static String? getImageFormat(String base64String) {
    try {
      if (base64String.isEmpty) return null;
      
      String dataUrl = base64String;
      if (!base64String.contains(',')) {
        // Assume it's a raw base64 string, try to detect format
        final imageData = base64Decode(base64String);
        if (imageData.length >= 4) {
          // Check magic bytes
          if (imageData[0] == 0xFF && imageData[1] == 0xD8) return 'jpeg';
          if (imageData[0] == 0x89 && imageData[1] == 0x50 && imageData[2] == 0x4E && imageData[3] == 0x47) return 'png';
          if (imageData[0] == 0x47 && imageData[1] == 0x49 && imageData[2] == 0x46) return 'gif';
          if (imageData[0] == 0x52 && imageData[1] == 0x49 && imageData[2] == 0x46 && imageData[3] == 0x46) return 'webp';
        }
        return null;
      }
      
      final mimeType = dataUrl.split(',')[0].split(':')[1].split(';')[0];
      switch (mimeType) {
        case 'image/jpeg':
          return 'jpeg';
        case 'image/png':
          return 'png';
        case 'image/gif':
          return 'gif';
        case 'image/webp':
          return 'webp';
        default:
          return null;
      }
    } catch (e) {
      return null;
    }
  }
}