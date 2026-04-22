import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class BottomBannerSlot extends StatelessWidget {
  const BottomBannerSlot({
    super.key,
    this.bannerSize,
    this.bannerChild,
    this.showDebugPlaceholder = false,
  });

  final AdSize? bannerSize;
  final Widget? bannerChild;
  final bool showDebugPlaceholder;

  @override
  Widget build(BuildContext context) {
    // Get system bottom padding (e.g., Android navigation bar)
    final systemBottomPadding = MediaQuery.of(context).padding.bottom;

    if (bannerChild != null && bannerSize != null) {
      final width = bannerSize!.width.toDouble();
      final height = bannerSize!.height.toDouble();

      return Padding(
        padding: EdgeInsets.only(bottom: systemBottomPadding),
        child: SizedBox(
          key: const Key('banner_ad_container'),
          width: double.infinity,
          height: height,
          child: Center(
            child: SizedBox(
              width: width,
              height: height,
              child: bannerChild,
            ),
          ),
        ),
      );
    }

    if (showDebugPlaceholder) {
      return Container(
        key: const Key('banner_ad_container'),
        width: double.infinity,
        height: 50,
         margin: EdgeInsets.only(bottom: systemBottomPadding),
        decoration: BoxDecoration(
          color: Colors.grey[300],
          border: Border.all(color: Colors.grey, width: 1),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Center(
          child: Text(
            'Banner Ad Placeholder',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      );
    }

    return const SizedBox.shrink();
  }
}