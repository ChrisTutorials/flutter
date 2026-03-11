# Flutter Monorepo

A monorepo containing Flutter applications and shared libraries.

## Structure

- `common/` - Shared libraries and utilities used across multiple apps
- `unit_converter/` - Unit Converter app
- `test-app/` - Test application
- `marketing/` - Marketing materials (graphics, screenshots, store listings)
- `flutter/` - Flutter SDK (not tracked in git)

## Getting Started

Each app can be run independently. Navigate to the app directory and run:

```bash
cd <app-name>
flutter run
```

## Shared Libraries

The `common/` directory contains reusable code that can be imported by any app in this monorepo.

## Marketing Materials

The `marketing/` directory contains all marketing materials organized by app:
- `unit_converter/` - Graphics, screenshots, and marketing copy for the Unit Converter app

## Contributing

This is a solo developer monorepo for managing multiple Flutter applications efficiently.
