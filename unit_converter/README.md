# Unit Converter

A beautiful, ad-supported unit converter app built with Flutter. Convert between 8 different unit categories including live currency conversion with offline support and recent conversion history.

## Features

- 🔄 **8 Conversion Categories**: Length, Weight, Temperature, Volume, Area, Speed, Time, Currency
- � **Live Currency Rates**: Real-time exchange rates via Frankfurter API
- � **Recent Conversions**: Automatically saves your last 10 conversions
- 📋 **Copy Results**: One-tap copy to clipboard
- 🎨 **Beautiful UI**: Material Design 3 with deep purple theme
- 📱 **Ad-Supported**: Banner ads and interstitial ads for monetization
- 🌐 **Offline Mode**: Works without internet connection (currency uses cached data)
- ⚡ **Real-time Conversion**: Instant results as you type
- 🔍 **Instant Search**: Type conversions like "60 g to lb" directly in search bar

## Supported Conversions

### Length
- Millimeter, Centimeter, Meter, Kilometer
- Inch, Foot, Yard, Mile

### Weight
- Milligram, Gram, Kilogram, Metric Ton
- Ounce, Pound, Stone

### Temperature
- Celsius, Fahrenheit, Kelvin

### Volume
- Milliliter, Liter, Cubic Meter
- Gallon, Quart, Pint, Cup, Fluid Ounce (US)

### Area
- Square Millimeter, Square Centimeter, Square Meter, Hectare, Square Kilometer
- Square Inch, Square Foot, Acre

### Speed
- Meter per Second, Kilometer per Hour, Mile per Hour, Foot per Second, Knot

### Time
- Millisecond, Second, Minute, Hour, Day, Week, Month, Year

### Currency
- 30+ currencies including USD, EUR, GBP, JPY, CAD, AUD, and more
- Live exchange rates via Frankfurter API
- Offline mode with cached data
- Rate details and last update information

## Getting Started

### Prerequisites
- Flutter SDK (3.11.1 or higher)
- Android Studio (for Android builds)
- Google Play Developer account ($25 one-time fee)

### Installation

1. Clone the repository
2. Navigate to the project directory
3. Get dependencies:
   ```bash
   flutter pub get
   ```

4. Run the app:
   ```bash
   flutter run
   ```

## Documentation

For detailed documentation, see the [docs/](docs/) directory:

- **[docs/README.md](docs/README.md)** - Project overview and documentation index
- [QUICKSTART.md](docs/QUICKSTART.md) - Quick start guide for testing and deployment
- [ARCHITECTURE.md](docs/ARCHITECTURE.md) - Architecture overview and design patterns
- [API.md](docs/API.md) - Complete API documentation
- [SECURITY_CONFIG.md](docs/SECURITY_CONFIG.md) - Security configuration guide
- [DEPLOYMENT_ROADMAP.md](docs/DEPLOYMENT_ROADMAP.md) - Deployment phases and roadmap
- [DOCUMENTATION_CLAIMS_VALIDATION.md](docs/DOCUMENTATION_CLAIMS_VALIDATION.md) - Test coverage validation
- [TEST_COVERAGE.md](docs/TEST_COVERAGE.md) - Test coverage report
- [AD_STRATEGY.md](docs/AD_STRATEGY.md) - Comprehensive ad monetization strategy
- [CURRENCY_ARCHITECTURE.md](docs/CURRENCY_ARCHITECTURE.md) - Currency converter architecture and design

## Building for Android

### Debug Build
\\\ash
flutter build apk --debug
\\\

### Release Build
\\\ash
flutter build apk --release
\\\

The APK will be located at: \uild/app/outputs/flutter-apk/app-release.apk\

## AdMob Setup

The app uses Google AdMob for monetization. To use your own ads:

1. Create an AdMob account at [https://admob.google.com](https://admob.google.com)
2. Create a new app and ad units
3. Replace the test ad unit IDs in \lib/services/admob_service.dart\:

\\\dart
static const String _bannerAdUnitId = 'ca-app-pub-XXXXXXXXXXXXXXXX/YYYYYYYYYY';
static const String _interstitialAdUnitId = 'ca-app-pub-XXXXXXXXXXXXXXXX/ZZZZZZZZZZ';
\\\

### Test Ad Units
The app currently uses test ad units:
- Banner: ca-app-pub-3940256099942544/6300978111
- Interstitial: ca-app-pub-3940256099942544/1033173712

To use your own ad unit IDs for production, replace the following in `lib/services/admob_service.dart`:
```dart
static const String _bannerAdUnitId = 'ca-app-pub-your-banner-ad-unit-id-here';
static const String _interstitialAdUnitId = 'ca-app-pub-your-interstitial-ad-unit-id-here';
```
IMPORTANT: Replace the above placeholder IDs with your actual ad unit IDs from the AdMob Console.
## Publishing to Google Play Store

### 1. Prepare Your App
- Update app name and description in \ndroid/app/src/main/AndroidManifest.xml\
- Update version in \pubspec.yaml\
- Create app icons (replace placeholder icons in \ndroid/app/src/main/res/mipmap-*\)

### 2. Sign Your App
1. Generate a keystore:
   \\\ash
   keytool -genkey -v -keystore ~/upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
   \\\

2. Create \key.properties\ file in \ndroid/\ directory:
   \\\
   storePassword=<your-store-password>
   keyPassword=<your-key-password>
   keyAlias=upload
   storeFile=<path-to-keystore-file>
   \\\

3. Add \key.properties\ to \.gitignore\

4. Update \ndroid/app/build.gradle\ to use the keystore

### 3. Build Release APK
\\\ash
flutter build apk --release
\\\

### 4. Create Play Store Listing
- App title: Unit Converter
- Short description: Convert between 7 unit categories instantly
- Full description: [Use the full description below]
- Screenshots: Take screenshots from the app
- Icon: Create a 512x512 app icon

### 5. Upload to Play Console
1. Go to [Google Play Console](https://play.google.com/console)
2. Create a new app
3. Fill in all required information
4. Upload the APK
5. Submit for review

## App Description for Play Store

### Short Description (80 chars)
Convert between 8 categories including live currency rates instantly

### Full Description
Unit Converter is the ultimate tool for quick and accurate unit conversions. Whether you're a student, professional, or just need to convert measurements, this app has you covered.

**FEATURES:**
✅ 8 conversion categories: Length, Weight, Temperature, Volume, Area, Speed, Time, Currency
✅ Live currency exchange rates via Frankfurter API
✅ Real-time conversion as you type
✅ Recent conversions history (last 10)
✅ Copy results to clipboard with one tap
✅ Beautiful Material Design 3 interface
✅ Works offline - currency uses cached data
✅ Instant search with conversion preview
✅ Swap units with a single tap
✅ View all available units in each category

**SUPPORTED CONVERSIONS:**
📏 Length: mm, cm, m, km, in, ft, yd, mi
⚖️ Weight: mg, g, kg, t, oz, lb, st
🌡️ Temperature: °C, °F, K
🥛 Volume: mL, L, m³, gal, qt, pt, cup, fl oz
📐 Area: mm², cm², m², ha, km², in², ft², ac
🚀 Speed: m/s, km/h, mph, ft/s, kn
⏰ Time: ms, s, min, h, d, wk, mo, yr
💰 Currency: USD, EUR, GBP, JPY, CAD, AUD, and 30+ more

Perfect for:
- Students doing homework
- Engineers and scientists
- Travelers
- Cooks and bakers
- DIY enthusiasts
- Anyone who needs quick conversions!

Download Unit Converter now and make conversions effortless!

## Monetization

### Ad Strategy
- **Banner Ads**: Displayed on the main screen
- **Interstitial Ads**: Shown every 5 conversions
- **Expected Revenue**: \-50/month with 1,000+ active users

### Revenue Optimization Tips
1. Optimize ad placement for better CTR
2. Use A/B testing for ad formats
3. Consider premium version without ads
4. Add more features to increase engagement
5. Encourage users to rate the app

## Project Structure

\\\
lib/
├── main.dart                          # Main app UI
├── models/
│   └── conversion.dart                # Conversion data models
└── services/
    ├── admob_service.dart             # AdMob integration
    └── recent_conversions_service.dart # Recent conversions storage
\\\

## Dependencies

- flutter: SDK
- google_mobile_ads: ^7.0.0 - AdMob ads
- shared_preferences: ^2.3.2 - Local storage
- intl: ^0.20.2 - Number formatting

## License

This project is open source and available for personal and commercial use.

## Support

For issues or feature requests, please create an issue in the repository.

## Privacy Policy

This app does not collect any personal data. All conversions are stored locally on your device.
