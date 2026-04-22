import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Utility for responsive layout design
class ResponsiveLayout {
  // Breakpoints
  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 900;
  static const double wideBreakpoint = 1000;
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

  /// Check if current layout is desktop
  static bool isDesktop(BuildContext context) {
    return getScreenSize(context) == ScreenSize.desktop;
  }

  /// Get optimal grid columns for categories
  static int getCategoryGridColumns(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final width = size.width;
    final isLandscape = size.width > size.height;

    if (width >= 1400) return 5;
    if (width >= 1100) return 4;
    if (width >= 800) return isLandscape ? 4 : 3;
    if (width >= 600) return isLandscape ? 3 : 2;
    if (isLandscape && width >= 480) return 3;
    return 2;
  }

  /// Get optimal grid columns for presets/favorites
  static int getHorizontalScrollColumns(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width > desktopBreakpoint) return 4;  // Large desktop
    if (width > tabletBreakpoint) return 3;   // Desktop/tablet landscape
    if (width > mobileBreakpoint) return 2;   // Tablet portrait
    return 2;                                // Mobile
  }

  /// Get card padding based on screen size
  static EdgeInsets getCardPadding(BuildContext context) {
    if (isMobile(context)) {
      return const EdgeInsets.all(12);
    }
    return const EdgeInsets.all(24);
  }

  /// Get spacing between cards
  static double getCardSpacing(BuildContext context) {
    if (isMobile(context)) {
      return 8;
    }
    return 12;
  }

  /// Get optimal card aspect ratio
  static double getCardAspectRatio(
    BuildContext context, {
    double? availableWidth,
  }) {
    final size = MediaQuery.sizeOf(context);
    final width = availableWidth ?? size.width;
    final spacing = getCardSpacing(context);
    final columns = getCategoryGridColumns(context);
    final totalSpacing = spacing * (columns - 1);
    final cardWidth = math.max(0, (width - totalSpacing) / columns);
    final targetHeight = _getTargetCategoryCardHeight(context);

    if (cardWidth <= 0 || targetHeight <= 0) {
      return 1.2;
    }

    return cardWidth / targetHeight;
  }

  static double _getTargetCategoryCardHeight(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final width = size.width;
    final height = size.height;
    final isLandscape = width > height;

    final double baseHeight;
    if (width >= desktopBreakpoint) {
      baseHeight = 180;
    } else if (width >= tabletBreakpoint) {
      baseHeight = isLandscape ? 168 : 176;
    } else if (width >= mobileBreakpoint) {
      baseHeight = isLandscape ? 150 : 164;
    } else {
      baseHeight = isLandscape ? 132 : 156;
    }

    final maxHeightFraction = isLandscape ? 0.32 : 0.24;
    final minHeight = isLandscape ? 112.0 : 128.0;
    final maxHeight = height * maxHeightFraction;

    return math.max(minHeight, math.min(baseHeight, maxHeight));
  }

  /// Get font size multiplier
  static double getFontSizeMultiplier(BuildContext context) {
    final size = getScreenSize(context);
    switch (size) {
      case ScreenSize.mobile:
        return 0.9;
      case ScreenSize.tabletPortrait:
        return 1.0;
      case ScreenSize.tabletLandscape:
        return 1.0;
      case ScreenSize.desktop:
        return 1.1;
    }
  }

  /// Get section spacing
  static double getSectionSpacing(BuildContext context) {
    if (isMobile(context)) {
      return 12;
    }
    return 20;
  }

  /// Check if we should show compact layout
  static bool shouldUseCompactLayout(BuildContext context) {
    return isMobile(context);
  }

  /// Check if we should hide less important sections on mobile
  static bool shouldShowRecentConversionsInline(BuildContext context) {
    // On mobile, show recent conversions inline only if there's space
    final height = MediaQuery.of(context).size.height;
    return height > 700;
  }

  /// Get maximum items to show in horizontal scroll on mobile
  static int getMaxHorizontalItems(BuildContext context) {
    if (isMobile(context)) {
      return 3;  // Show fewer items on mobile to reduce scrolling
    }
    return 5;  // Show more on desktop
  }
}

/// Screen size categories
enum ScreenSize {
  mobile,
  tabletPortrait,
  tabletLandscape,
  desktop,
}
