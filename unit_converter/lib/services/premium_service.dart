import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';

class PremiumService {
  static const String _premiumKey = 'premium_enabled';
  static const String _premiumHashKey = 'premium_hash';
  static const String _salt = 'MoonBarkStudio_UnitConverter_v1.0';

  /// Check if premium is enabled with integrity verification
  static Future<bool> isPremium() async {
    final prefs = await SharedPreferences.getInstance();
    final premiumEnabled = prefs.getBool(_premiumKey) ?? false;
    
    if (!premiumEnabled) return false;
    
    // Verify integrity by checking the hash
    final storedHash = prefs.getString(_premiumHashKey);
    if (storedHash == null) return false;
    
    final expectedHash = _generateHash(premiumEnabled);
    return storedHash == expectedHash;
  }

  /// Enable premium with integrity hash
  static Future<void> setPremium(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_premiumKey, value);
    
    // Store integrity hash to detect tampering
    final hash = _generateHash(value);
    await prefs.setString(_premiumHashKey, hash);
  }

  /// Generate integrity hash
  static String _generateHash(bool value) {
    final data = '$value:$_salt';
    return sha256.convert(utf8.encode(data)).toString();
  }

  /// Verify premium status hasn't been tampered with
  static Future<bool> verifyIntegrity() async {
    final prefs = await SharedPreferences.getInstance();
    final premiumEnabled = prefs.getBool(_premiumKey) ?? false;
    final storedHash = prefs.getString(_premiumHashKey);
    
    if (premiumEnabled && storedHash == null) return false;
    
    final expectedHash = _generateHash(premiumEnabled);
    return storedHash == expectedHash;
  }
}
