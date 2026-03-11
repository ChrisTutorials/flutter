import 'ad_service.dart';

/// Ad configuration presets for different app types
/// 
/// Use these presets to configure AdService for your specific app type:
/// - AdConfigUtilityApps: For utility apps like converters, calculators
/// - AdConfigGameApps: For casual gaming apps
/// - AdConfigContentApps: For content consumption apps
/// - AdConfigProductivityApps: For productivity apps
class AdConfig {
  /// Configuration for utility apps (converters, calculators, tools)
  /// 
  /// Philosophy: Conservative ad placement to protect user experience
  /// Users expect quick, interruption-free interactions
  static void configureForUtilityApp() {
    AdService.configure(
      minConversionsBeforeFirstAdValue: 10, // Let users try the app first
      conversionsBetweenAdsValue: 20, // Very conservative frequency
      minSecondsBetweenAdsValue: 180, // 3 minutes between ads
      maxInterstitialsPerSessionValue: 3, // Low session limit
    );
  }

  /// Configuration for casual gaming apps
  /// 
  /// Philosophy: More frequent ads but respect natural breaks
  /// Players expect ads between levels or game overs
  static void configureForCasualGame() {
    AdService.configure(
      minConversionsBeforeFirstAdValue: 3, // Faster introduction to ads
      conversionsBetweenAdsValue: 10, // More frequent for gaming sessions
      minSecondsBetweenAdsValue: 120, // 2 minutes between ads
      maxInterstitialsPerSessionValue: 5, // Higher tolerance in games
    );
  }

  /// Configuration for content consumption apps (news, reading, video)
  /// 
  /// Philosophy: Balance between content flow and monetization
  /// Users are engaged for longer periods
  static void configureForContentApp() {
    AdService.configure(
      minConversionsBeforeFirstAdValue: 5, // Moderate introduction
      conversionsBetweenAdsValue: 15, // Moderate frequency
      minSecondsBetweenAdsValue: 150, // 2.5 minutes between ads
      maxInterstitialsPerSessionValue: 4, // Moderate session limit
    );
  }

  /// Configuration for productivity apps
  /// 
  /// Philosophy: Very conservative to avoid workflow interruption
  /// Users are focused and task-oriented
  static void configureForProductivityApp() {
    AdService.configure(
      minConversionsBeforeFirstAdValue: 15, // Let users establish workflow
      conversionsBetweenAdsValue: 25, // Very conservative
      minSecondsBetweenAdsValue: 300, // 5 minutes between ads
      maxInterstitialsPerSessionValue: 2, // Very low session limit
    );
  }

  /// Configuration for aggressive monetization (use with caution)
  /// 
  /// Warning: This may hurt user experience and app store ratings
  /// Only use for apps where users expect frequent ads
  static void configureAggressive() {
    AdService.configure(
      minConversionsBeforeFirstAdValue: 2, // Quick ad introduction
      conversionsBetweenAdsValue: 5, // Very frequent
      minSecondsBetweenAdsValue: 60, // 1 minute between ads
      maxInterstitialsPerSessionValue: 8, // High session limit
    );
  }

  /// Custom configuration builder
  /// 
  /// Use this for fine-tuned control over ad behavior
  static void configureCustom({
    required int firstAdAfterConversions,
    required int conversionsBetweenAds,
    required int minimumSecondsBetweenAds,
    required int maxAdsPerSession,
  }) {
    AdService.configure(
      minConversionsBeforeFirstAdValue: firstAdAfterConversions,
      conversionsBetweenAdsValue: conversionsBetweenAds,
      minSecondsBetweenAdsValue: minimumSecondsBetweenAds,
      maxInterstitialsPerSessionValue: maxAdsPerSession,
    );
  }
}

/// Ad unit ID configurations for different environments
class AdUnitIds {
  /// Test ad unit IDs (for development)
  static const test = AdUnitSet(
    banner: 'ca-app-pub-3940256099942544/6300978111',
    interstitial: 'ca-app-pub-3940256099942544/1033173712',
    appOpen: 'ca-app-pub-3940256099942544/3419835294',
  );

  /// Production ad unit IDs (replace with your actual IDs)
  static void configureProduction({
    required String bannerId,
    required String interstitialId,
    required String appOpenId,
  }) {
    AdService.configure(
      bannerAdUnitIdValue: bannerId,
      interstitialAdUnitIdValue: interstitialId,
      appOpenAdUnitIdValue: appOpenId,
    );
  }
}

/// Helper class for organizing ad unit IDs
class AdUnitSet {
  final String banner;
  final String interstitial;
  final String appOpen;

  const AdUnitSet({
    required this.banner,
    required this.interstitial,
    required this.appOpen,
  });

  /// Apply this ad unit set to AdService
  void apply() {
    AdService.configure(
      bannerAdUnitIdValue: banner,
      interstitialAdUnitIdValue: interstitial,
      appOpenAdUnitIdValue: appOpen,
    );
  }
}
