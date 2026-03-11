import 'package:flutter/material.dart';

/// Common button styles for the app
class ButtonStyles {
  ButtonStyles._();

  /// Standard full-width filled button style
  static ButtonStyle get fullWidthButton =>
      FilledButton.styleFrom(minimumSize: const Size(double.infinity, 56));

  /// Full-width filled button with custom icon
  static ButtonStyle fullWidthButtonWithIcon({IconData? icon}) =>
      FilledButton.styleFrom(minimumSize: const Size(double.infinity, 56));
}
