import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/theme.dart';

/// Helper class for managing dynamic category icons loaded from JSON
class CategoryIconHelper {
  // Cache for loaded category data
  static List<Map<String, dynamic>>? _categoryData;
  static bool _isInitialized = false;

  /// Load and cache category data from JSON file
  static Future<void> loadCategoryData() async {
    if (_isInitialized) {
      return; // Already loaded
    }

    try {
      // Load JSON file from assets
      final jsonString = await rootBundle.loadString('assets/data/category_icons.json');
      final Map<String, dynamic> jsonData = json.decode(jsonString);
      
      // Extract categories array
      _categoryData = List<Map<String, dynamic>>.from(jsonData['categories'] ?? []);
      _isInitialized = true;
      
// debugPrint('✅ Category icon data loaded successfully: ${_categoryData?.length} categories');
    } catch (e) {
// debugPrint('❌ Error loading category icon data: $e');
      _categoryData = [];
      _isInitialized = true;
    }
  }

  /// Get category icon widget based on category name
  /// 
  /// Searches for matching keywords in the loaded JSON data and returns
  /// an Icon widget with the appropriate icon and color.
  /// Falls back to a default icon if no match is found.
  static Widget getCategoryIcon(String categoryName, BuildContext context) {
    // Ensure data is loaded
    if (!_isInitialized || _categoryData == null) {
// debugPrint('⚠️ Category data not loaded yet, using default icon');
      return _getDefaultIcon(context);
    }

    // Convert to lowercase for case-insensitive matching
    final lowerCategoryName = categoryName.toLowerCase();
    
    // Search for matching category
    for (final category in _categoryData!) {
      final keywords = List<String>.from(category['keywords'] ?? []);
      
      // Check if any keyword matches
      for (final keyword in keywords) {
        if (lowerCategoryName.contains(keyword.toLowerCase())) {
          final iconName = category['icon'] as String?;
          final colorHex = category['color'] as String?;
          
          if (iconName != null) {
// debugPrint('🎯 Matched "$categoryName" → $iconName');
            
            return Icon(
              _getIconData(iconName),
              size: Responsive.padding(context, 24),
              color: colorHex != null ? _hexToColor(colorHex) : Colors.grey,
            );
          }
        }
      }
    }

    // No match found, return default icon
// debugPrint('🔍 No match found for "$categoryName", using default icon');
    return _getDefaultIcon(context);
  }

  /// Get default icon when no match is found
  static Widget _getDefaultIcon(BuildContext context) {
    return Icon(
      Icons.restaurant_menu,
      size: Responsive.padding(context, 24),
      color: Colors.grey,
    );
  }

  /// Map icon name (string) to Material Icons IconData
  static IconData _getIconData(String iconName) {
    switch (iconName.toLowerCase()) {
      case 'restaurant':
        return Icons.restaurant;
      case 'kebab_dining':
        return Icons.kebab_dining;
      case 'set_meal':
        return Icons.set_meal;
      case 'local_drink':
        return Icons.local_drink;
      case 'soup_kitchen':
        return Icons.soup_kitchen;
      case 'eco':
        return Icons.eco;
      case 'fastfood':
        return Icons.fastfood;
      case 'cake':
        return Icons.cake;
      case 'local_pizza':
        return Icons.local_pizza;
      case 'lunch_dining':
        return Icons.lunch_dining;
      case 'ramen_dining':
        return Icons.ramen_dining;
      case 'rice_bowl':
        return Icons.rice_bowl;
      case 'bakery_dining':
        return Icons.bakery_dining;
      case 'outdoor_grill':
        return Icons.outdoor_grill;
      case 'breakfast_dining':
        return Icons.breakfast_dining;
      case 'flatware':
        return Icons.flatware;
      case 'tapas':
        return Icons.tapas;
      case 'local_fire_department':
        return Icons.local_fire_department;
      case 'child_care':
        return Icons.child_care;
      case 'restaurant_menu':
        return Icons.restaurant_menu;
      case 'emoji_food_beverage':
        return Icons.emoji_food_beverage;
      case 'spa':
        return Icons.spa;
      case 'coffee':
        return Icons.coffee;
      case 'local_cafe':
        return Icons.local_cafe;
      default:
// debugPrint('⚠️ Unknown icon name: $iconName, using default');
        return Icons.restaurant_menu;
    }
  }

  /// Convert hex color string (e.g., "#FF5733") to Color object
  static Color _hexToColor(String hexString) {
    try {
      // Remove # if present
      final buffer = StringBuffer();
      if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
      buffer.write(hexString.replaceFirst('#', ''));
      return Color(int.parse(buffer.toString(), radix: 16));
    } catch (e) {
// debugPrint('⚠️ Error parsing color "$hexString": $e');
      return Colors.grey;
    }
  }

  /// Clear cached data (useful for testing or hot reload)
  static void clearCache() {
    _categoryData = null;
    _isInitialized = false;
// debugPrint('🗑️ Category icon cache cleared');
  }
}

