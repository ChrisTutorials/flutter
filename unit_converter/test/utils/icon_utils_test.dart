import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:unit_converter/utils/icon_utils.dart';

void main() {
  group('IconUtils', () {
    test('should return straighten icon for Length category', () {
      expect(IconUtils.getIconForCategory('Length'), Icons.straighten);
    });

    test('should return straighten icon for straighten key', () {
      expect(IconUtils.getIconForCategory('straighten'), Icons.straighten);
    });

    test('should return monitor_weight icon for Weight category', () {
      expect(IconUtils.getIconForCategory('Weight'), Icons.monitor_weight);
    });

    test('should return monitor_weight icon for scale key', () {
      expect(IconUtils.getIconForCategory('scale'), Icons.monitor_weight);
    });

    test('should return thermostat icon for Temperature category', () {
      expect(IconUtils.getIconForCategory('Temperature'), Icons.thermostat);
    });

    test('should return thermostat icon for thermostat key', () {
      expect(IconUtils.getIconForCategory('thermostat'), Icons.thermostat);
    });

    test('should return local_drink icon for Volume category', () {
      expect(IconUtils.getIconForCategory('Volume'), Icons.local_drink);
    });

    test('should return local_drink icon for local_drink key', () {
      expect(IconUtils.getIconForCategory('local_drink'), Icons.local_drink);
    });

    test('should return crop_square icon for Area category', () {
      expect(IconUtils.getIconForCategory('Area'), Icons.crop_square);
    });

    test('should return crop_square icon for crop_square key', () {
      expect(IconUtils.getIconForCategory('crop_square'), Icons.crop_square);
    });

    test('should return speed icon for Speed category', () {
      expect(IconUtils.getIconForCategory('Speed'), Icons.speed);
    });

    test('should return speed icon for speed key', () {
      expect(IconUtils.getIconForCategory('speed'), Icons.speed);
    });

    test('should return data icon for Data category', () {
      expect(IconUtils.getIconForCategory('Data'), Icons.data_object);
    });

    test('should return pressure icon for Pressure category', () {
      expect(IconUtils.getIconForCategory('Pressure'), Icons.compress);
    });

    test('should return cooking icon for Cooking category', () {
      expect(
        IconUtils.getIconForCategory('Cooking'),
        Icons.restaurant_menu,
      );
    });

    test('should return schedule icon for Time category', () {
      expect(IconUtils.getIconForCategory('Time'), Icons.schedule);
    });

    test('should return schedule icon for schedule key', () {
      expect(IconUtils.getIconForCategory('schedule'), Icons.schedule);
    });

    test('should return currency_exchange icon for Currency category', () {
      expect(IconUtils.getIconForCategory('Currency'), Icons.currency_exchange_rounded);
    });

    test('should return category icon for unknown category', () {
      expect(IconUtils.getIconForCategory('Unknown'), Icons.category);
    });

    test('should return category icon for empty string', () {
      expect(IconUtils.getIconForCategory(''), Icons.category);
    });
  });
}
