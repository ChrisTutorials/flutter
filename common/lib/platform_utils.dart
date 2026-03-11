import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

/// Utility class for platform-specific checks
/// 
/// Provides convenient methods to detect the current platform
/// across mobile, desktop, and web environments.
class PlatformUtils {
  PlatformUtils._();

  /// Returns true if running on a mobile platform (Android or iOS)
  static bool get isMobile {
    return !kIsWeb && (Platform.isAndroid || Platform.isIOS);
  }

  /// Returns true if running on Android
  static bool get isAndroid => !kIsWeb && Platform.isAndroid;

  /// Returns true if running on iOS
  static bool get isIOS => !kIsWeb && Platform.isIOS;

  /// Returns true if running on Windows
  static bool get isWindows => !kIsWeb && Platform.isWindows;

  /// Returns true if running on macOS
  static bool get isMacOS => !kIsWeb && Platform.isMacOS;

  /// Returns true if running on Linux
  static bool get isLinux => !kIsWeb && Platform.isLinux;

  /// Returns true if running on a desktop platform
  static bool get isDesktop => !kIsWeb && (isWindows || isMacOS || isLinux);

  /// Returns true if running on web
  static bool get isWeb => kIsWeb;
}
