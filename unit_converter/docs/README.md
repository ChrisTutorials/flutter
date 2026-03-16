# Unit Converter - Project Overview

## Description
A Flutter-based unit converter application that supports multiple conversion categories including length, weight, temperature, volume, area, speed, time, and live currency conversion.

## Features
- Multi-category unit conversion (8 categories including currency)
- Live currency conversion with Frankfurter API integration
- Recent conversion history
- Temperature conversion with special formulas
- Material Design 3 theming
- AdMob integration (with stub for testing)
- Instant search with conversion preview
- Offline mode for currency with cached data

## Project Structure
```
unit_converter/
├── lib/
│   ├── main.dart              # Main application entry point
│   ├── models/
│   │   └── conversion.dart    # Data models and conversion logic
│   ├── screens/
│   │   ├── category_selection_screen.dart    # Home screen with search and categories
│   │   ├── conversion_screen.dart            # Unit conversion screen
│   │   ├── currency_converter_screen.dart    # Currency conversion screen
│   │   ├── settings_screen.dart              # Settings screen
│   │   ├── add_custom_unit_screen.dart       # Add custom unit screen
│   │   └── custom_units_screen.dart          # Custom units management
│   ├── widgets/
│   │   ├── unit_input_card.dart              # Unit input widget
│   │   ├── currency_input_row.dart           # Currency input widget
│   │   └── theme_toggle_widget.dart          # Theme toggle widget
│   ├── services/
│   │   ├── admob_service.dart                # AdMob service
│   │   ├── admob_service_stub.dart           # AdMob stub for testing
│   │   ├── recent_conversions_service.dart   # Recent conversions management
│   │   ├── currency_service.dart             # Currency conversion service
│   │   ├── favorite_conversions_service.dart # Favorite conversions management
│   │   ├── widget_service.dart               # Widget data service
│   │   ├── comparison_service.dart           # Real-world comparison service
│   │   └── formula_service.dart              # Formula display service
│   └── utils/
│       ├── platform_utils.dart               # Platform detection utilities
│       ├── snackbar_utils.dart               # SnackBar display utilities
│       ├── button_styles.dart                # Button style utilities
│       ├── navigation_utils.dart             # Navigation utilities
│       ├── number_formatter.dart             # Number formatting utilities
│       └── home_search.dart                  # Home search and instant conversion
├── test/                      # Test files
└── ../docs/                      # Documentation
```

## Supported Conversion Categories
- Length (mm, cm, m, km, in, ft, yd, mi)
- Weight (mg, g, kg, t, oz, lb, st)
- Temperature (°C, °F, K)
- Volume (mL, L, m³, gal, qt, pt, cup, fl oz)
- Area (mm², cm², m², ha, km², in², ft², ac)
- Speed (m/s, km/h, mph, ft/s, kn)
- Time (ms, s, min, h, d, wk, mo, yr)
- Currency (USD, EUR, GBP, JPY, CAD, AUD, and 30+ more via Frankfurter API)

## Getting Started
See [quickstart.md](quickstart.md) for detailed setup instructions.

## 🚀 Quick Deployment

Deploy to Google Play Store with a single command:

```powershell
# Deploy to internal testing
.\scripts\release.ps1

# Deploy to production
.\scripts\release.ps1 -Track production -ReleaseNotes "New features"

# Check deployment readiness
cd android
fastlane release_status
```

For complete deployment documentation, see [DEPLOYMENT.md](DEPLOYMENT.md) or [play-store-release-runbook.md](play-store-release-runbook.md).

## Documentation Index
- [DEPLOYMENT.md](DEPLOYMENT.md) - Complete deployment guide with automated workflow
- [quickstart.md](quickstart.md) - Quick start guide for testing and deployment
- [play-store-release-runbook.md](play-store-release-runbook.md) - Production release, metadata, and screenshot workflow
- [ARCHITECTURE.md](ARCHITECTURE.md) - Architecture overview and design patterns
- [API.md](API.md) - Complete API documentation
- [SECURITY_CONFIG.md](SECURITY_CONFIG.md) - Security configuration guide
- [RELEASE_CREDENTIALS_SETUP.md](RELEASE_CREDENTIALS_SETUP.md) - Credential setup for releases
- [DEPLOYMENT_ROADMAP.md](DEPLOYMENT_ROADMAP.md) - Deployment phases and roadmap
- [DOCUMENTATION_CLAIMS_VALIDATION.md](DOCUMENTATION_CLAIMS_VALIDATION.md) - Test coverage validation
- [ad-strategy.md](ad-strategy.md) - Comprehensive ad monetization strategy
- [app-size-analysis.md](app-size-analysis.md) - App size analysis and optimization recommendations

### Currency Converter Documentation
- [currency-architecture.md](currency-architecture.md) - Currency converter architecture and design decisions
- [currency-converter-tests.md](currency-converter-tests.md) - Currency converter test suite documentation
- [currency-offline-warning-system.md](currency-offline-warning-system.md) - Offline warning system implementation
- [currency-last-update-and-api-source.md](currency-last-update-and-api-source.md) - Last update tracking and API source link

### Other Documentation
- [DRY_SUMMARY.md](DRY_SUMMARY.md) - DRY refactoring summary
- [REFACTORING_SUMMARY.md](REFACTORING_SUMMARY.md) - Complete refactoring details
- [dark-light-theme-implementation.md](dark-light-theme-implementation.md) - Theme implementation details
- [RESPONSIVE_LAYOUT_IMPLEMENTATION.md](RESPONSIVE_LAYOUT_IMPLEMENTATION.md) - Responsive layout implementation
- [SECURITY_FIXES_APPLIED.md](SECURITY_FIXES_APPLIED.md) - Security fixes documentation
- [SMOKE_TESTS.md](SMOKE_TESTS.md) - Smoke test documentation
- [TEST_COVERAGE.md](TEST_COVERAGE.md) - Test coverage details
- [ADMOB_PRODUCTION_SETUP.md](ADMOB_PRODUCTION_SETUP.md) - AdMob production setup
- [ad-implementation-summary.md](ad-implementation-summary.md) - Ad implementation summary
- [ad-test-coverage-summary.md](ad-test-coverage-summary.md) - Ad test coverage summary

