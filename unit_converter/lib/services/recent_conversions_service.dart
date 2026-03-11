import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/conversion.dart';

class RecentConversionsService {
  static const String _key = 'recent_conversions';
  static const int _maxRecent = 10;

  /// Save a recent conversion
  Future<void> saveConversion(RecentConversion conversion) async {
    final prefs = await SharedPreferences.getInstance();
    final recentList = await getRecentConversions();

    // Remove duplicate if exists
    recentList.removeWhere(
      (c) =>
          c.category == conversion.category &&
          c.fromUnit == conversion.fromUnit &&
          c.toUnit == conversion.toUnit &&
          c.inputValue == conversion.inputValue,
    );

    // Add new conversion at the beginning
    recentList.insert(0, conversion);

    // Keep only the most recent
    if (recentList.length > _maxRecent) {
      recentList.removeRange(_maxRecent, recentList.length);
    }

    // Save to preferences
    final jsonString = jsonEncode(recentList.map((c) => c.toJson()).toList());
    await prefs.setString(_key, jsonString);
  }

  /// Get all recent conversions
  Future<List<RecentConversion>> getRecentConversions() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_key);

    if (jsonString == null) return [];

    try {
      final List<dynamic> jsonList = jsonDecode(jsonString);
      return jsonList.map((json) => RecentConversion.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }

  /// Clear all recent conversions
  Future<void> clearRecentConversions() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }

  /// Delete a specific recent conversion
  Future<void> deleteConversion(RecentConversion conversion) async {
    final recentList = await getRecentConversions();
    recentList.removeWhere(
      (c) =>
          c.category == conversion.category &&
          c.fromUnit == conversion.fromUnit &&
          c.toUnit == conversion.toUnit &&
          c.timestamp == conversion.timestamp,
    );

    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(recentList.map((c) => c.toJson()).toList());
    await prefs.setString(_key, jsonString);
  }
}
