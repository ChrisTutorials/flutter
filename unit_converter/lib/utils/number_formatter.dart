import 'package:intl/intl.dart';

class NumberFormatter {
  static String formatCompact(double value) {
    if (value.abs() >= 1000) {
      return NumberFormat.compact().format(value);
    }
    return NumberFormat('0.######').format(value);
  }

  static String formatPrecise(double value) {
    if (value == value.truncateToDouble()) {
      return value.toInt().toString();
    }
    return NumberFormat('0.########').format(value);
  }

  /// Formats a number, showing as integer if it's a whole number,
  /// otherwise showing up to 8 decimal places.
  static String formatNumber(double value) {
    if (value == value.truncateToDouble()) {
      return value.toInt().toString();
    }
    return NumberFormat('0.########').format(value);
  }
}
