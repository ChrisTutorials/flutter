import 'package:shared_preferences/shared_preferences.dart';
import '../models/conversion.dart';

/// Service for managing unit visibility settings
class UnitSettingsService {
  static const String _hiddenUnitsKey = 'hidden_units';
  static const String _hiddenCurrenciesKey = 'hidden_currencies';
  
  // Default units to hide (lowest value units)
  static const Set<String> _defaultHiddenUnits = {
    'Micrometer',      // Length - 0.000001
    'Milligram',       // Weight - 0.000001
    'Square Millimeter', // Area - 0.000001
    'Pinch',           // Cooking - 0.0003080576
    'Dash',            // Cooking - 0.0006161152
    'Bit',             // Data - 0.125
  };

  // Default currencies to hide
  static const Set<String> _defaultHiddenCurrencies = {
    'VND', // Vietnamese Dong
  };

  /// Get the set of hidden unit names
  static Future<Set<String>> getHiddenUnits() async {
    final prefs = await SharedPreferences.getInstance();
    final hiddenUnitList = prefs.getStringList(_hiddenUnitsKey);
    
    if (hiddenUnitList == null || hiddenUnitList.isEmpty) {
      // Return default hidden units if none are set
      return Set<String>.from(_defaultHiddenUnits);
    }
    
    return Set<String>.from(hiddenUnitList);
  }

  /// Set the hidden units
  static Future<void> setHiddenUnits(Set<String> hiddenUnits) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_hiddenUnitsKey, hiddenUnits.toList());
  }

  /// Check if a specific unit is hidden
  static Future<bool> isUnitHidden(String unitName) async {
    final hiddenUnits = await getHiddenUnits();
    return hiddenUnits.contains(unitName);
  }

  /// Toggle visibility of a unit
  static Future<void> toggleUnitVisibility(String unitName) async {
    final hiddenUnits = await getHiddenUnits();
    
    if (hiddenUnits.contains(unitName)) {
      hiddenUnits.remove(unitName);
    } else {
      hiddenUnits.add(unitName);
    }
    
    await setHiddenUnits(hiddenUnits);
  }

  /// Reset to default hidden units
  static Future<void> resetToDefaults() async {
    await setHiddenUnits(Set<String>.from(_defaultHiddenUnits));
  }

  /// Filter units based on visibility settings
  static Future<List<Unit>> filterUnits(List<Unit> units) async {
    final hiddenUnits = await getHiddenUnits();
    
    return units.where((unit) => !hiddenUnits.contains(unit.name)).toList();
  }

  /// Get all units that can be toggled (all units from all categories)
  static Future<Set<String>> getAllToggleableUnits() async {
    final allUnits = <String>{};
    
    for (final category in ConversionData.categories) {
      for (final unit in category.units) {
        allUnits.add(unit.name);
      }
    }
    
    return allUnits;
  }

  /// Get units that are typically considered "low value" and good candidates for hiding
  static Set<String> getLowValueUnits() {
    return Set<String>.from(_defaultHiddenUnits);
  }

  /// Get the set of hidden currency codes
  static Future<Set<String>> getHiddenCurrencies() async {
    final prefs = await SharedPreferences.getInstance();
    final hiddenCurrencyList = prefs.getStringList(_hiddenCurrenciesKey);

    if (hiddenCurrencyList == null || hiddenCurrencyList.isEmpty) {
      return Set<String>.from(_defaultHiddenCurrencies);
    }

    return Set<String>.from(hiddenCurrencyList);
  }

  /// Set the hidden currencies
  static Future<void> setHiddenCurrencies(Set<String> hiddenCurrencies) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_hiddenCurrenciesKey, hiddenCurrencies.toList());
  }

  /// Check if a specific currency is hidden
  static Future<bool> isCurrencyHidden(String currencyCode) async {
    final hiddenCurrencies = await getHiddenCurrencies();
    return hiddenCurrencies.contains(currencyCode);
  }

  /// Toggle visibility of a currency
  static Future<void> toggleCurrencyVisibility(String currencyCode) async {
    final hiddenCurrencies = await getHiddenCurrencies();

    if (hiddenCurrencies.contains(currencyCode)) {
      hiddenCurrencies.remove(currencyCode);
    } else {
      hiddenCurrencies.add(currencyCode);
    }

    await setHiddenCurrencies(hiddenCurrencies);
  }

  /// Reset currency defaults to default hidden currencies
  static Future<void> resetCurrencyDefaults() async {
    await setHiddenCurrencies(Set<String>.from(_defaultHiddenCurrencies));
  }

  /// Filter currencies based on visibility settings
  static Future<Map<String, String>> filterCurrencies(
    Map<String, String> currencies,
  ) async {
    final hiddenCurrencies = await getHiddenCurrencies();

    return Map.fromEntries(
      currencies.entries.where((e) => !hiddenCurrencies.contains(e.key)),
    );
  }
}
