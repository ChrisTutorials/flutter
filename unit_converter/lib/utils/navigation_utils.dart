import 'package:flutter/material.dart';

/// Utility class for navigation helpers
class NavigationUtils {
  NavigationUtils._();

  /// Pushes a new screen onto the navigation stack
  static Future<T?> pushScreen<T>(
    BuildContext context,
    Widget screen, {
    bool fullscreenDialog = false,
  }) {
    return Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => screen,
        fullscreenDialog: fullscreenDialog,
      ),
    );
  }

  /// Pops the current screen from the navigation stack
  static void pop<T>(BuildContext context, [T? result]) {
    Navigator.pop(context, result);
  }

  /// Pushes a screen and returns when it's popped
  static Future<T?> pushAndAwait<T>(
    BuildContext context,
    Widget screen, {
    bool fullscreenDialog = false,
  }) {
    return Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => screen,
        fullscreenDialog: fullscreenDialog,
      ),
    );
  }

  /// Pushes a screen and executes a callback when it's popped
  static Future<T?> pushWithCallback<T>(
    BuildContext context,
    Widget screen,
    VoidCallback onPop, {
    bool fullscreenDialog = false,
  }) {
    return Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => screen,
        fullscreenDialog: fullscreenDialog,
      ),
    ).then((result) {
      onPop();
      return result;
    });
  }

  /// Pushes a replacement screen onto the navigation stack
  static Future<T?> pushReplacement<T, TO>(
    BuildContext context,
    Widget screen, {
    TO? result,
  }) {
    return Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => screen),
      result: result,
    );
  }

  /// Pushes and removes all previous screens until a condition is met
  static Future<T?> pushAndRemoveUntil<T>(
    BuildContext context,
    Widget screen, {
    RoutePredicate? predicate,
  }) {
    return Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => screen),
      predicate ?? (route) => false,
    );
  }
}
