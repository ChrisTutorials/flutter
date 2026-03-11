import 'package:flutter/material.dart';

// Stub implementation for non-mobile platforms
// This prevents AdMob from being imported on Windows/Web

class BannerAd {
  final AdSize size;
  final BannerAdListener listener;
  BannerAd({
    required this.size,
    required AdRequest request,
    required this.listener,
  });
  void load() {}
  void dispose() {}
}

class AdSize {
  final double width;
  final double height;
  AdSize({required this.width, required this.height});
}

class AdRequest {
  const AdRequest();
}

class BannerAdListener {
  final Function({dynamic ad, dynamic error})? onAdLoaded;
  final Function({dynamic ad, dynamic error})? onAdFailedToLoad;

  const BannerAdListener({this.onAdLoaded, this.onAdFailedToLoad});
}

class InterstitialAd {
  static Future<void> load({
    required String adUnitId,
    required AdLoadCallback adLoadCallback,
  }) async {}
  Future<void> show() async {}
  FullScreenContentCallback? fullScreenContentCallback;
}

typedef AdLoadCallback =
    void Function({required InterstitialAd ad, required dynamic error});

class FullScreenContentCallback {
  final Function(InterstitialAd ad)? onAdDismissedFullScreenContent;
  final Function(InterstitialAd ad, dynamic error)?
  onAdFailedToShowFullScreenContent;

  FullScreenContentCallback({
    this.onAdDismissedFullScreenContent,
    this.onAdFailedToShowFullScreenContent,
  });
}

class AdWidget extends StatelessWidget {
  final dynamic ad;
  const AdWidget({super.key, required this.ad});

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}

class AdMobService {
  static Future<void> initialize() async {}
  static BannerAd createBannerAd() => BannerAd(
    size: AdSize(width: 320, height: 50),
    request: const AdRequest(),
    listener: const BannerAdListener(),
  );
  static Future<void> loadInterstitialAd() async {}
  static Future<void> showInterstitialAd() async {}
  static void trackConversion() {}
  static void dispose() {}
}
