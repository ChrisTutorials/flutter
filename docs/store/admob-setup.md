# AdMob Production Setup

This document explains the AdMob production configuration for the Unit Converter app.

## Production Ad Unit IDs

The following production AdMob ad unit IDs have been configured:

### Banner Ad
- **Ad Unit ID**: `ca-app-pub-5684393858412931/2095306836`
- **Type**: Banner
- **Platform**: Android/iOS

### Interstitial Ad
- **Ad Unit ID**: `ca-app-pub-5684393858412931/3408388509`
- **Type**: Interstitial
- **Platform**: Android/iOS

### App Open Ad
- **Ad Unit ID**: `ca-app-pub-5684393858412931/2095306836` (using banner ID as placeholder)
- **Type**: App Open
- **Platform**: Android/iOS

## Configuration Logic

The app automatically switches between test and production ad unit IDs based on the build mode:

### Debug Mode
- Uses Google's test ad unit IDs (`ca-app-pub-3940256099942544/*`)
- Safe for development and testing
- No real impressions or revenue

### Release Mode
- Uses production ad unit IDs provided above
- Real impressions and revenue
- Requires valid AdMob account and app setup

## Implementation Details

### Environment Detection
```dart
if (kDebugMode) {
  // Use test IDs in debug mode
  AdUnitIds.test.apply();
  debugPrint('AdMobService: Using test ad unit IDs');
} else {
  // Use production IDs in release mode
  AdUnitIds.configureProduction(
    bannerId: 'ca-app-pub-5684393858412931/2095306836',
    interstitialId: 'ca-app-pub-5684393858412931/3408388509',
    appOpenId: 'ca-app-pub-5684393858412931/2095306836',
  );
  debugPrint('AdMobService: Using production ad unit IDs');
}
```

### Ad Frequency Configuration
The app uses conservative ad settings for utility apps:
- **First ad after**: 10 conversions
- **Frequency cap**: 20 conversions between ads
- **Time cap**: 3 minutes minimum between ads
- **Session limit**: 3 interstitials per session

## Test Coverage

### Production Configuration Tests
- ✅ Production ad unit ID format validation
- ✅ Production vs test ID differentiation
- ✅ Service initialization with production config
- ✅ Banner ad creation with correct format
- ✅ Conversion tracking functionality
- ✅ Ad display logic validation
- ✅ Service disposal and reset operations

### Platform Tests
- ✅ Cross-platform compatibility
- ✅ Test ad unit ID usage in debug mode
- ✅ Production ad unit ID format validation
- ✅ Platform-specific initialization logic

## Verification Commands

### Run Production Tests
```bash
flutter test test/production_ad_test.dart
```

### Run Platform Tests
```bash
flutter test test/admob_platform_test.dart
```

### Run All Ad Tests
```bash
flutter test test/*ad*test.dart
```

## Deployment Checklist

Before deploying to production:

1. **Verify AdMob Setup**
   - [ ] AdMob account created and verified
   - [ ] App added to AdMob console
   - [ ] Production ad units created
   - [ ] App store linking completed

2. **Test Release Build**
   - [ ] Build release APK/AAB
   - [ ] Test on real device
   - [ ] Verify production ads load
   - [ ] Check ad impression tracking

3. **Compliance**
   - [ ] Privacy policy updated
   - [ ] GDPR consent implemented
   - [ ] App store disclosure complete

## Important Notes

⚠️ **Critical**: The app will only use production ad unit IDs in release builds. Debug builds always use test IDs.

⚠️ **Revenue**: Production ads will generate real impressions and revenue. Monitor AdMob dashboard after deployment.

⚠️ **Testing**: Always test release builds on real devices before publishing to ensure ads work correctly.

⚠️ **Compliance**: Ensure your app complies with AdMob policies and app store guidelines regarding ad implementation.

## Troubleshooting

### Ads Not Showing in Release
1. Verify AdMob app and ad unit setup
2. Check device network connectivity
3. Review AdMob policy compliance
4. Check ad fill rate in AdMob dashboard

### Test Ads Still Showing
1. Ensure you're running a release build
2. Check `kDebugMode` detection logic
3. Verify production IDs are correctly configured

### Revenue Not Tracking
1. Verify app is linked to AdMob
2. Check ad unit ID configuration
3. Review AdMob dashboard settings
4. Ensure proper app store linking

