import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shared_preferences/shared_preferences.dart';


/// Reusable ad service for Flutter applications
///
/// Features:
/// - Banner, Interstitial, and App Open ads
/// - User experience protection with frequency capping
/// - First-time user protection
/// - Session limits
/// - Time-based restrictions
/// - Premium user support (via Google Play Billing)
///
/// Usage:
/// 1. Call PurchaseService.initialize() and AdService.initialize() when app starts
/// 2. Call AdService.resetSessionCounters() on app launch
/// 3. Call AdService.trackConversion() after user completes actions
/// 4. Call AdService.showAppOpenAdIfAvailable() in main screen initState
class AdService {
  // Ad instances
  static BannerAd? _bannerAd;
  static InterstitialAd? _interstitialAd;
  static AppOpenAd? _appOpenAd;

  // Tracking variables
  static int _conversionCount = 0;
  static int _conversionsSinceLastAd = 0;
  static int _sessionInterstitials = 0;
  static int _interstitialLoadAttempts = 0;
  static DateTime? _lastAdTime;
  static DateTime? _lastAppOpenAdTime;
  static bool _adsEnabled = true;
  static bool _isInitialized = false;

  // Configuration constants - Override these in your app for customization
  static int minConversionsBeforeFirstAd = 10; // First-time user protection
  static int conversionsBetweenAds = 20; // Frequency cap
  static int minSecondsBetweenAds = 180; // 3 minutes minimum between ads
  static int maxInterstitialsPerSession = 3; // Session limit

  // Test flag - set to true to skip MobileAds initialization
  static bool skipMobileAdsInitialization = false;

  // Ad unit IDs - Override these with your app-specific IDs
  static String bannerAdUnitId = 'ca-app-pub-3940256099942544/6300978111'; // Test ID
  static String interstitialAdUnitId = 'ca-app-pub-3940256099942544/1033173712'; // Test ID
  static String appOpenAdUnitId = 'ca-app-pub-3940256099942544/3419835294'; // Test ID

  // Storage keys
  static const String _conversionCountKey = 'ad_conversion_count';
  static const String _lastAppOpenAdDateKey = 'ad_last_app_open_date';

  /// Premium status callback - Override this to check if user is premium
  /// Note: By default, this checks PremiumService which integrates with Google Play Billing
  static Future<bool> Function()? isPremiumUser;

  /// Initialize Mobile Ads SDK and load persistent data
  static Future<void> initialize() async {
    if (_isInitialized) return;

    // Check premium status - check SharedPreferences directly by default
    if (isPremiumUser == null) {
      // Default to checking SharedPreferences directly
      isPremiumUser = () async {
        final prefs = await SharedPreferences.getInstance();
        return prefs.getBool('has_purchased_ad_removal') ?? false;
      };
    }

    _adsEnabled = !(await isPremiumUser!());

    if (!_adsEnabled) {
      _isInitialized = true;
      return;
    }

    if (!skipMobileAdsInitialization) {
      try {
        await MobileAds.instance.initialize();
      } catch (e) {
        // MobileAds may not be available in tests or certain environments
        debugPrint('AdService: MobileAds initialization failed: $e');
        // Continue anyway - ads may not work but app won't crash
      }
    }

    await _loadPersistentData();

    // Preload ads
    if (!skipMobileAdsInitialization) {
      try {
        loadInterstitialAd();
        loadAppOpenAd();
      } catch (e) {
        debugPrint('AdService: Failed to preload ads: $e');
      }
    }

    _isInitialized = true;
  }
  
  /// Load persistent data from SharedPreferences
  static Future<void> _loadPersistentData() async {
    final prefs = await SharedPreferences.getInstance();
    _conversionCount = prefs.getInt(_conversionCountKey) ?? 0;
    
    // Load last app open ad date
    final lastOpenAdDateStr = prefs.getString(_lastAppOpenAdDateKey);
    if (lastOpenAdDateStr != null) {
      _lastAppOpenAdTime = DateTime.parse(lastOpenAdDateStr);
    }
  }
  
  /// Save persistent data to SharedPreferences
  static Future<void> _savePersistentData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_conversionCountKey, _conversionCount);
    
    if (_lastAppOpenAdTime != null) {
      await prefs.setString(_lastAppOpenAdDateKey, _lastAppOpenAdTime!.toIso8601String());
    }
  }

  /// Create a banner ad
  static BannerAd createBannerAd() {
    if (!_adsEnabled) {
      throw StateError('Ads are disabled (premium user or not initialized)');
    }
    
    return BannerAd(
      adUnitId: bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          debugPrint('AdService: Banner ad loaded.');
        },
        onAdFailedToLoad: (ad, error) {
          debugPrint('AdService: Banner ad failed to load: $error');
          ad.dispose();
        },
      ),
    );
  }

  /// Load an interstitial ad
  static Future<void> loadInterstitialAd() async {
    if (!_adsEnabled || !_isInitialized) return;

    await InterstitialAd.load(
      adUnitId: interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _interstitialLoadAttempts = 0;
          debugPrint('AdService: Interstitial ad loaded.');
        },
        onAdFailedToLoad: (error) {
          _interstitialLoadAttempts += 1;
          _interstitialAd = null;
          debugPrint('AdService: Interstitial ad failed to load: $error');
          if (_interstitialLoadAttempts < 3) {
            loadInterstitialAd();
          }
        },
      ),
    );
  }
  
  /// Load an app open ad
  static Future<void> loadAppOpenAd() async {
    if (!_adsEnabled || !_isInitialized) return;

    await AppOpenAd.load(
      adUnitId: appOpenAdUnitId,
      request: const AdRequest(),
      adLoadCallback: AppOpenAdLoadCallback(
        onAdLoaded: (ad) {
          _appOpenAd = ad;
          debugPrint('AdService: App open ad loaded.');
        },
        onAdFailedToLoad: (error) {
          debugPrint('AdService: App open ad failed to load: $error');
          _appOpenAd = null;
        },
      ),
    );
  }

  /// Check if interstitial should be shown based on all rules
  static bool shouldShowInterstitial() {
    if (!_adsEnabled || !_isInitialized) {
      return false;
    }

    // Rule 1: First-time user protection
    if (_conversionCount < minConversionsBeforeFirstAd) {
      debugPrint('AdService: Interstitial blocked: First-time user protection (conversions: $_conversionCount)');
      return false;
    }
    
    // Rule 2: Frequency cap - minimum conversions between ads
    if (_conversionsSinceLastAd < conversionsBetweenAds) {
      debugPrint('AdService: Interstitial blocked: Not enough conversions since last ad ($_conversionsSinceLastAd/$conversionsBetweenAds)');
      return false;
    }
    
    // Rule 3: Time-based cap - minimum time between ads
    if (_lastAdTime != null) {
      final timeSinceLastAd = DateTime.now().difference(_lastAdTime!).inSeconds;
      if (timeSinceLastAd < minSecondsBetweenAds) {
        debugPrint('AdService: Interstitial blocked: Too soon since last ad (${timeSinceLastAd}s/$minSecondsBetweenAds)');
        return false;
      }
    }
    
    // Rule 4: Session limit
    if (_sessionInterstitials >= maxInterstitialsPerSession) {
      debugPrint('AdService: Interstitial blocked: Session limit reached ($_sessionInterstitials/$maxInterstitialsPerSession)');
      return false;
    }
    
    return true;
  }

  /// Show interstitial ad
  /// Call this AFTER the user completes a task, not during
  static Future<void> showInterstitialAd() async {
    if (!_adsEnabled || !_isInitialized) {
      return;
    }

    if (_interstitialAd == null) {
      debugPrint('AdService: Interstitial ad not loaded yet.');
      return;
    }

    // Update tracking before showing
    _conversionsSinceLastAd = 0;
    _sessionInterstitials++;
    _lastAdTime = DateTime.now();
    
    await _savePersistentData();

    _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        debugPrint('AdService: Interstitial ad dismissed.');
        ad.dispose();
        _interstitialAd = null;
        loadInterstitialAd(); // Preload next ad
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        debugPrint('AdService: Interstitial ad failed to show: $error');
        ad.dispose();
        _interstitialAd = null;
        loadInterstitialAd();
      },
    );

    debugPrint('AdService: Showing interstitial ad (session: $_sessionInterstitials/$maxInterstitialsPerSession)');
    await _interstitialAd!.show();
    _interstitialAd = null;
  }
  
  /// Show app open ad if available and not shown today
  static Future<void> showAppOpenAdIfAvailable() async {
    if (!_adsEnabled || !_isInitialized) {
      return;
    }

    if (_appOpenAd == null) {
      debugPrint('AdService: App open ad not loaded yet.');
      return;
    }
    
    // Check if already shown today
    if (_lastAppOpenAdTime != null) {
      final now = DateTime.now();
      final lastShown = _lastAppOpenAdTime!;
      if (now.day == lastShown.day &&
          now.month == lastShown.month &&
          now.year == lastShown.year) {
        debugPrint('AdService: App open ad already shown today.');
        return;
      }
    }
    
    // Show the ad
    await _appOpenAd!.show();
    _lastAppOpenAdTime = DateTime.now();
    _appOpenAd = null;
    
    await _savePersistentData();
    
    debugPrint('AdService: App open ad shown, preloading next...');
    loadAppOpenAd(); // Preload next ad
  }

  /// Track a conversion and potentially show interstitial
  /// Call this AFTER the user completes a conversion/action
  static void trackConversion() {
    if (!_adsEnabled || !_isInitialized) {
      return;
    }

    _conversionCount++;
    _conversionsSinceLastAd++;
    
    debugPrint('AdService: Conversion tracked: $_conversionCount total, $_conversionsSinceLastAd since last ad');
    
    // Check if we should show an interstitial
    if (shouldShowInterstitial()) {
      debugPrint('AdService: Conditions met, showing interstitial...');
      showInterstitialAd();
    }
  }
  
  /// Reset session counters (call when app starts a new session)
  static void resetSessionCounters() {
    _sessionInterstitials = 0;
    debugPrint('AdService: Session counters reset');
  }

  /// Reset all state (for testing only)
  static void resetForTesting() {
    _conversionCount = 0;
    _conversionsSinceLastAd = 0;
    _sessionInterstitials = 0;
    _interstitialLoadAttempts = 0;
    _lastAdTime = null;
    _lastAppOpenAdTime = null;
    _adsEnabled = true;
    _isInitialized = false;
    _bannerAd = null;
    _interstitialAd = null;
    _appOpenAd = null;
    isPremiumUser = null;
    skipMobileAdsInitialization = true; // Skip MobileAds in tests
    debugPrint('AdService: Reset for testing');
  }

  /// Update premium status and reinitialize if needed
  static Future<void> updatePremiumStatus(bool isPremium) async {
    // Update the premium check function
    isPremiumUser = () async => isPremium;
    
    // Dispose of any existing ads
    dispose();
    
    // Force a re-initialization to update the adsEnabled flag based on the new premium status
    _isInitialized = false;
    await initialize();
  }
  
  /// Configure ad settings for your app
  static void configure({
    int? minConversionsBeforeFirstAdValue,
    int? conversionsBetweenAdsValue,
    int? minSecondsBetweenAdsValue,
    int? maxInterstitialsPerSessionValue,
    String? bannerAdUnitIdValue,
    String? interstitialAdUnitIdValue,
    String? appOpenAdUnitIdValue,
    Future<bool> Function()? premiumCheck,
  }) {
    if (minConversionsBeforeFirstAdValue != null) {
      minConversionsBeforeFirstAd = minConversionsBeforeFirstAdValue;
    }
    if (conversionsBetweenAdsValue != null) {
      conversionsBetweenAds = conversionsBetweenAdsValue;
    }
    if (minSecondsBetweenAdsValue != null) {
      minSecondsBetweenAds = minSecondsBetweenAdsValue;
    }
    if (maxInterstitialsPerSessionValue != null) {
      maxInterstitialsPerSession = maxInterstitialsPerSessionValue;
    }
    if (bannerAdUnitIdValue != null) {
      bannerAdUnitId = bannerAdUnitIdValue;
    }
    if (interstitialAdUnitIdValue != null) {
      interstitialAdUnitId = interstitialAdUnitIdValue;
    }
    if (appOpenAdUnitIdValue != null) {
      appOpenAdUnitId = appOpenAdUnitIdValue;
    }
    if (premiumCheck != null) {
      isPremiumUser = premiumCheck;
    }
  }
  
  // Getters for debugging
  static bool get adsEnabled => _adsEnabled;
  static bool get isInitialized => _isInitialized;
  static int get conversionCount => _conversionCount;
  static int get conversionsSinceLastAd => _conversionsSinceLastAd;
  static int get sessionInterstitials => _sessionInterstitials;

  /// Dispose of ads
  static void dispose() {
    _bannerAd?.dispose();
    _interstitialAd?.dispose();
    _appOpenAd?.dispose();
  }
}
