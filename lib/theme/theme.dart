import 'package:flutter/material.dart';

/// Responsive helper class for scaling UI elements based on screen width
class Responsive {
  static const double _mobileBreakpoint = 600;
  static const double _tabletBreakpoint = 900;
  static const double _desktopBreakpoint = 1200;
  static const double _largeDesktopBreakpoint = 1600;
  
  /// Get responsive font size based on screen width
  static double fontSize(BuildContext context, double baseFontSize) {
    final screenWidth = MediaQuery.of(context).size.width;
    
    if (screenWidth < _mobileBreakpoint) {
      // Mobile: base size
      return baseFontSize;
    } else if (screenWidth < _tabletBreakpoint) {
      // Tablet: 1.2x scale
      return baseFontSize * 1.2;  
    } else if (screenWidth < _desktopBreakpoint) {
      // Desktop: 1.4x scale  
      return baseFontSize * 1.4;
    } else {
      // Large desktop: 1.6x scale
      return baseFontSize * 1.6;
    }
  }
  
  /// Get responsive padding based on screen width
  static double padding(BuildContext context, double basePadding) {
    final screenWidth = MediaQuery.of(context).size.width;
    
    if (screenWidth < _mobileBreakpoint) {
      return basePadding;
    } else if (screenWidth < _tabletBreakpoint) {
      return basePadding * 1.3;
    } else if (screenWidth < _desktopBreakpoint) {
      return basePadding * 1.6;
    } else {
      return basePadding * 2.0;
    }
  }
  
  /// Get responsive grid columns based on screen width
  static int gridColumns(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    
    if (screenWidth < _mobileBreakpoint) {
      return 2; // Mobile: 2 columns
    } else if (screenWidth < _tabletBreakpoint) {
      return 3; // Tablet: 3 columns
    } else if (screenWidth < _desktopBreakpoint) {
      return 4; // Desktop: 4 columns
    } else {
      return 5; // Large desktop: 5 columns
    }
  }
  
  /// Get responsive horizontal padding for desktop layout
  static double horizontalPadding(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    print('screenWidth < _desktopBreakpoint:${screenWidth < _desktopBreakpoint}');
    if (screenWidth < _desktopBreakpoint) {

      return padding(context, 16);
    } else {
      // For desktop, add extra side padding to center content
      final maxContentWidth = 1200.0;
      final availableWidth = screenWidth - maxContentWidth;
      return availableWidth > 0 ? availableWidth / 2 : padding(context, 16);
    }
  }
  
  /// Get maximum content width for desktop layout
  static double maxContentWidth(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    
    if (screenWidth < _desktopBreakpoint) {
      return screenWidth;
    } else {
      return 1200.0; // Max content width for desktop
    }
  }
  
  /// Check if current screen is mobile
  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < _mobileBreakpoint;
  }
  
  /// Check if current screen is tablet
  static bool isTablet(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return screenWidth >= _mobileBreakpoint && screenWidth < _tabletBreakpoint;
  }
  
  /// Check if current screen is desktop
  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= _desktopBreakpoint;
  }
  
  /// Check if current screen is large desktop
  static bool isLargeDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= _largeDesktopBreakpoint;
  }
}

/// Color palette for the app
class AppColors {
  // Primary colors
  static const Color primary = Color(0xFF1367FF);
  static const Color primaryDark = Color(0xFF1976D2);
  static const Color primaryLight = Color(0xFFBBDEFB);
  
  // Secondary colors
  static const Color secondary = Color(0xFFFF9800);
  static const Color secondaryDark = Color(0xFFF57C00);
  
  // Accent colors
  static const Color accent = Color(0xFF4CAF50);
  static const Color accentDark = Color(0xFF388E3C);
  
  // Status colors
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFF9800);
  static const Color error = Color(0xFFF44336);
  static const Color info = Color(0xFF2196F3);
  
  // Veg/Non-veg colors
  static const Color veg = Color(0xFF4CAF50);
  static const Color nonVeg = Color(0xFFF44336);
  
  // Neutral colors
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color grey50 = Color(0xFFFAFAFA);
  static const Color grey100 = Color(0xFFF5F5F5);
  static const Color grey200 = Color(0xFFEEEEEE);
  static const Color grey300 = Color(0xFFE0E0E0);
  static const Color grey400 = Color(0xFFBDBDBD);
  static const Color grey500 = Color(0xFF9E9E9E);
  static const Color grey600 = Color(0xFF757575);
  static const Color grey700 = Color(0xFF616161);
  static const Color grey800 = Color(0xFF424242);
  static const Color grey900 = Color(0xFF212121);
  
  // Text colors
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textDisabled = Color(0xFFBDBDBD);
  
  // Background colors
  static const Color background = Color(0xFFFAFAFA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color card = Color(0xFFFFFFFF);
}

/// Dark theme colors
class AppColorsDark {
  // Primary colors
  static const Color primary = Color(0xFF90CAF9);
  static const Color primaryDark = Color(0xFF42A5F5);
  static const Color primaryLight = Color(0xFFE3F2FD);
  
  // Secondary colors
  static const Color secondary = Color(0xFFFFB74D);
  static const Color secondaryDark = Color(0xFFFF9800);
  
  // Accent colors
  static const Color accent = Color(0xFF81C784);
  static const Color accentDark = Color(0xFF4CAF50);
  
  // Status colors
  static const Color success = Color(0xFF81C784);
  static const Color warning = Color(0xFFFFB74D);
  static const Color error = Color(0xFFE57373);
  static const Color info = Color(0xFF64B5F6);
  
  // Veg/Non-veg colors
  static const Color veg = Color(0xFF81C784);
  static const Color nonVeg = Color(0xFFE57373);
  
  // Neutral colors
  static const Color white = Color(0xFF121212);
  static const Color black = Color(0xFFFFFFFF);
  static const Color grey50 = Color(0xFF1E1E1E);
  static const Color grey100 = Color(0xFF2C2C2C);
  static const Color grey200 = Color(0xFF3A3A3A);
  static const Color grey300 = Color(0xFF484848);
  static const Color grey400 = Color(0xFF565656);
  static const Color grey500 = Color(0xFF9E9E9E);
  static const Color grey600 = Color(0xFF757575);
  static const Color grey700 = Color(0xFF616161);
  static const Color grey800 = Color(0xFF424242);
  static const Color grey900 = Color(0xFF212121);
  
  // Text colors
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFB3B3B3);
  static const Color textDisabled = Color(0xFF666666);
  
  // Background colors
  static const Color background = Color(0xFF121212);
  static const Color surface = Color(0xFF1E1E1E);
  static const Color card = Color(0xFF2C2C2C);
}

/// App theme configuration
class AppTheme {
  /// Light theme
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: const ColorScheme.light(
      primary: AppColors.primary,
      secondary: AppColors.secondary,
      surface: AppColors.surface,
      error: AppColors.error,
      onPrimary: AppColors.white,
      onSecondary: AppColors.white,
      onSurface: AppColors.textPrimary,
      onError: AppColors.white,
      outline: AppColors.grey700,
      tertiary: AppColors.black
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.primary,
      foregroundColor: AppColors.white,
      elevation: 0,
      centerTitle: true,
    ),
    cardTheme: CardThemeData(
      color: AppColors.card,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    ),
    textTheme: const TextTheme(
      headlineLarge: TextStyle(
        color: AppColors.textPrimary,
        fontWeight: FontWeight.bold,
      ),
      headlineMedium: TextStyle(
        color: AppColors.textPrimary,
        fontWeight: FontWeight.bold,
      ),
      headlineSmall: TextStyle(
        color: AppColors.textPrimary,
        fontWeight: FontWeight.bold,
      ),
      titleLarge: TextStyle(
        color: AppColors.textPrimary,
        fontWeight: FontWeight.w600,
      ),
      titleMedium: TextStyle(
        color: AppColors.textPrimary,
        fontWeight: FontWeight.w600,
      ),
      titleSmall: TextStyle(
        color: AppColors.textPrimary,
        fontWeight: FontWeight.w600,
      ),
      bodyLarge: TextStyle(
        color: AppColors.textPrimary,
      ),
      bodyMedium: TextStyle(
        color: AppColors.textPrimary,
      ),
      bodySmall: TextStyle(
        color: AppColors.textSecondary,
      ),
    ),
  );
  
  /// Dark theme
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: const ColorScheme.dark(
      primary: AppColorsDark.primary,
      secondary: AppColorsDark.secondary,
      surface: AppColorsDark.surface,
      error: AppColorsDark.error,
      onPrimary: AppColorsDark.black,
      onSecondary: AppColorsDark.black,
      onSurface: AppColorsDark.textPrimary,
      onError: AppColorsDark.black,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColorsDark.primary,
      foregroundColor: AppColorsDark.black,
      elevation: 0,
      centerTitle: true,
    ),
    cardTheme: CardThemeData(
      color: AppColorsDark.card,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColorsDark.primary,
        foregroundColor: AppColorsDark.black,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    ),
    textTheme: const TextTheme(
      headlineLarge: TextStyle(
        color: AppColorsDark.textPrimary,
        fontWeight: FontWeight.bold,
      ),
      headlineMedium: TextStyle(
        color: AppColorsDark.textPrimary,
        fontWeight: FontWeight.bold,
      ),
      headlineSmall: TextStyle(
        color: AppColorsDark.textPrimary,
        fontWeight: FontWeight.bold,
      ),
      titleLarge: TextStyle(
        color: AppColorsDark.textPrimary,
        fontWeight: FontWeight.w600,
      ),
      titleMedium: TextStyle(
        color: AppColorsDark.textPrimary,
        fontWeight: FontWeight.w600,
      ),
      titleSmall: TextStyle(
        color: AppColorsDark.textPrimary,
        fontWeight: FontWeight.w600,
      ),
      bodyLarge: TextStyle(
        color: AppColorsDark.textPrimary,
      ),
      bodyMedium: TextStyle(
        color: AppColorsDark.textPrimary,
      ),
      bodySmall: TextStyle(
        color: AppColorsDark.textSecondary,
      ),
    ),
  );
}
