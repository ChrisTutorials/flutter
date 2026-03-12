import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Utility for responsive layout design
/// 
/// Provides responsive design utilities to adapt layouts
/// across different screen sizes and orientations.
class ResponsiveLayout {
  // Breakpoints
  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 900;
  static const double desktopBreakpoint = 1200;

  /// Get the current screen size category
  static ScreenSize getScreenSize(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width > desktopBreakpoint) return ScreenSize.desktop;
    if (width > tabletBreakpoint) return ScreenSize.tabletLandscape;
    if (width > mobileBreakpoint) return ScreenSize.tabletPortrait;
    return ScreenSize.mobile;
  }

  /// Check if current layout is mobile
  static bool isMobile(BuildContext context) {
    return getScreenSize(context) == ScreenSize.mobile;
  }

  /// Check if current layout is tablet
  static bool isTablet(BuildContext context) {
    final size = getScreenSize(context);
    return size == ScreenSize.tabletPortrait || size == ScreenSize.tabletLandscape;
  }

  /// Check if current layout is desktop
  static bool isDesktop(BuildContext context) {
    return getScreenSize(context) == ScreenSize.desktop;
  }

  /// Check if device is in landscape orientation
  static bool isLandscape(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return size.width > size.height;
  }

  /// Get optimal grid columns for a responsive grid
  /// 
  /// [minColumns]: Minimum columns to show (default: 2)
  /// [maxColumns]: Maximum columns to show (default: 6)
  /// [columnWidth]: Target width for each column (default: 300)
  static int getGridColumns(BuildContext context, {
    int minColumns = 2,
    int maxColumns = 6,
    double columnWidth = 300,
  }) {
    final width = MediaQuery.of(context).size.width;
    final availableWidth = width - (getCardPadding(context).horizontal * 2);
    final spacing = getCardSpacing(context);
    
    // Calculate how many columns fit
    int columns = ((availableWidth + spacing) / (columnWidth + spacing)).floor();
    
    // Clamp between min and max
    return columns.clamp(minColumns, maxColumns);
  }

  /// Get optimal grid columns for horizontal scrolling content
  static int getHorizontalScrollColumns(BuildContext context, {
    int mobileColumns = 2,
    int tabletColumns = 3,
    int desktopColumns = 4,
  }) {
    final size = getScreenSize(context);
    switch (size) {
      case ScreenSize.desktop:
        return desktopColumns;
      case ScreenSize.tabletLandscape:
      case ScreenSize.tabletPortrait:
        return tabletColumns;
      case ScreenSize.mobile:
        return mobileColumns;
    }
  }

  /// Get card padding based on screen size
  static EdgeInsets getCardPadding(BuildContext context, {
    EdgeInsets mobile = const EdgeInsets.all(12),
    EdgeInsets desktop = const EdgeInsets.all(24),
  }) {
    return isMobile(context) ? mobile : desktop;
  }

  /// Get spacing between cards
  static double getCardSpacing(BuildContext context, {
    double mobile = 8,
    double desktop = 12,
  }) {
    return isMobile(context) ? mobile : desktop;
  }

  /// Get optimal card aspect ratio based on available space
  /// 
  /// [targetHeight]: Target height for the card
  /// [availableWidth]: Available width for the card (optional)
  /// [columns]: Number of columns (optional, will be calculated if not provided)
  static double getCardAspectRatio(
    BuildContext context, {
    required double targetHeight,
    double? availableWidth,
    int? columns,
  }) {
    final size = MediaQuery.sizeOf(context);
    final width = availableWidth ?? size.width;
    final spacing = getCardSpacing(context);
    final gridColumns = columns ?? getGridColumns(context);
    final totalSpacing = spacing * (gridColumns - 1);
    final cardWidth = math.max(0, (width - totalSpacing) / gridColumns);

    if (cardWidth <= 0 || targetHeight <= 0) {
      return 1.2;
    }

    return cardWidth / targetHeight;
  }

  /// Get font size multiplier based on screen size
  static double getFontSizeMultiplier(BuildContext context, {
    double mobile = 0.9,
    double tablet = 1.0,
    double desktop = 1.1,
  }) {
    final size = getScreenSize(context);
    switch (size) {
      case ScreenSize.mobile:
        return mobile;
      case ScreenSize.tabletPortrait:
      case ScreenSize.tabletLandscape:
        return tablet;
      case ScreenSize.desktop:
        return desktop;
    }
  }

  /// Get section spacing based on screen size
  static double getSectionSpacing(BuildContext context, {
    double mobile = 12,
    double desktop = 20,
  }) {
    return isMobile(context) ? mobile : desktop;
  }

  /// Check if we should use compact layout
  static bool shouldUseCompactLayout(BuildContext context) {
    return isMobile(context);
  }

  /// Get maximum items to show in horizontal scroll on mobile
  static int getMaxHorizontalItems(BuildContext context, {
    int mobile = 3,
    int desktop = 5,
  }) {
    return isMobile(context) ? mobile : desktop;
  }

  /// Scale a value based on screen size
  static double scaleValue(BuildContext context, double value, {
    double scaleFactor = 0.1,
  }) {
    final multiplier = getFontSizeMultiplier(context);
    return value * multiplier;
  }

  /// Get responsive padding
  static EdgeInsets getResponsivePadding(BuildContext context, {
    double mobile = 16,
    double tablet = 24,
    double desktop = 32,
  }) {
    final size = getScreenSize(context);
    switch (size) {
      case ScreenSize.mobile:
        return EdgeInsets.all(mobile);
      case ScreenSize.tabletPortrait:
      case ScreenSize.tabletLandscape:
        return EdgeInsets.all(tablet);
      case ScreenSize.desktop:
        return EdgeInsets.all(desktop);
    }
  }
}

/// Screen size categories
enum ScreenSize {
  mobile,
  tabletPortrait,
  tabletLandscape,
  desktop,
}
