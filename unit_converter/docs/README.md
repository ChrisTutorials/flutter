# Unit Converter - Project Overview

## Description
A Flutter-based unit converter application that supports multiple conversion categories including length, weight, temperature, volume, area, speed, and time.

## Features
- Multi-category unit conversion
- Recent conversion history
- Temperature conversion with special formulas
- Material Design 3 theming
- AdMob integration (with stub for testing)

## Project Structure
```
unit_converter/
├── lib/
│   ├── main.dart              # Main application entry point
│   ├── models/
│   │   └── conversion.dart    # Data models and conversion logic
│   └── services/
│       ├── admob_service.dart            # AdMob service
│       ├── admob_service_stub.dart       # AdMob stub for testing
│       └── recent_conversions_service.dart # Recent conversions management
├── test/                      # Test files
└── docs/                      # Documentation
```

## Supported Conversion Categories
- Length (mm, cm, m, km, in, ft, yd, mi)
- Weight (mg, g, kg, t, oz, lb, st)
- Temperature (°C, °F, K)
- Volume (mL, L, m³, gal, qt, pt, cup, fl oz)
- Area (mm², cm², m², ha, km², in², ft², ac)
- Speed (m/s, km/h, mph, ft/s, kn)
- Time (ms, s, min, h, d, wk, mo, yr)

## Getting Started
See [QUICKSTART.md](QUICKSTART.md) for detailed setup instructions.

## Documentation Index
- [QUICKSTART.md](QUICKSTART.md) - Quick start guide for testing and deployment
- [ARCHITECTURE.md](ARCHITECTURE.md) - Architecture overview and design patterns
- [API.md](API.md) - Complete API documentation
- [SECURITY_CONFIG.md](SECURITY_CONFIG.md) - Security configuration guide
- [DEPLOYMENT_ROADMAP.md](DEPLOYMENT_ROADMAP.md) - Deployment phases and roadmap
- [DOCUMENTATION_CLAIMS_VALIDATION.md](DOCUMENTATION_CLAIMS_VALIDATION.md) - Test coverage validation
- [AD_STRATEGY.md](AD_STRATEGY.md) - Comprehensive ad monetization strategy
- [APP_SIZE_ANALYSIS.md](APP_SIZE_ANALYSIS.md) - App size analysis and optimization recommendations
