import 'package:flutter/material.dart';

class IconUtils {
  /// Returns an appropriate icon for a given category key or name.
  static IconData getIconForCategory(String categoryKey) {
    switch (categoryKey) {
      case 'straighten':
      case 'Length':
        return Icons.straighten;
      case 'scale':
      case 'Weight':
        return Icons.monitor_weight;
      case 'thermostat':
      case 'Temperature':
        return Icons.thermostat;
      case 'local_drink':
      case 'Volume':
        return Icons.local_drink;
      case 'crop_square':
      case 'Area':
        return Icons.crop_square;
      case 'speed':
      case 'Speed':
        return Icons.speed;
      case 'data':
      case 'Data':
        return Icons.data_object;
      case 'pressure':
      case 'Pressure':
        return Icons.compress;
      case 'restaurant':
      case 'Cooking':
        return Icons.restaurant_menu;
      case 'schedule':
      case 'Time':
        return Icons.schedule;
      case 'Currency':
        return Icons.currency_exchange_rounded;
      default:
        return Icons.category;
    }
  }
}
