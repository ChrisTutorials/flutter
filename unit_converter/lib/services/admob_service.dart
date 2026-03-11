import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:common_flutter_ads/ad_service.dart';
import 'package:common_flutter_ads/ad_config.dart';

import 'premium_service.dart';

/// Legacy AdMob service - now using common ad service
/// @deprecated Use AdService from common_flutter_ads instead
class AdMobService {
  /// Initialize the ad service with utility app configuration
  static Future<void> initialize() async {
    // Configure for utility app
    AdConfig.configureForUtilityApp();
    
    // Set premium user check
    AdService.configure(
      premiumCheck: () async => !(await PremiumService.isPremium()),
    );
    
    // Use test IDs for now - replace with production when ready
    AdUnitIds.test.apply();
    
    // Initialize the common ad service
    await AdService.initialize();
  }
  
  /// Create a banner ad (delegates to common service)
  static BannerAd createBannerAd() => AdService.createBannerAd();

  /// Load an interstitial ad (handled automatically by common service)
  static Future<void> loadInterstitialAd() => AdService.loadInterstitialAd();
  
  /// Load an app open ad (handled automatically by common service)
  static Future<void> loadAppOpenAd() => AdService.loadAppOpenAd();

  /// Check if interstitial should be shown (delegates to common service)
  static bool shouldShowInterstitial() => AdService.shouldShowInterstitial();

  /// Show interstitial ad (delegates to common service)
  static Future<void> showInterstitialAd() => AdService.showInterstitialAd();
  
  /// Show app open ad if available (delegates to common service)
  static Future<void> showAppOpenAdIfAvailable() => AdService.showAppOpenAdIfAvailable();

  /// Track a conversion (delegates to common service)
  static void trackConversion() => AdService.trackConversion();
  
  /// Reset session counters (delegates to common service)
  static void resetSessionCounters() => AdService.resetSessionCounters();

  /// Check if ads are enabled (delegates to common service)
  static bool get adsEnabled => AdService.adsEnabled;

  /// Update premium status (delegates to common service)
  static Future<void> setPremiumStatus(bool isPremium) async {
    await AdService.updatePremiumStatus(isPremium);
  }
  
  /// Get conversion count for debugging (delegates to common service)
  static int get conversionCount => AdService.conversionCount;
  
  /// Get conversions since last ad for debugging (delegates to common service)
  static int get conversionsSinceLastAd => AdService.conversionsSinceLastAd;
  
  /// Get session interstitial count for debugging (delegates to common service)
  static int get sessionInterstitials => AdService.sessionInterstitials;

  /// Dispose of ads (delegates to common service)
  static void dispose() => AdService.dispose();
}
