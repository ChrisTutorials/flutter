fastlane documentation
----

# Installation

Make sure you have the latest version of the Xcode command line tools installed:

```sh
xcode-select --install
```

For _fastlane_ installation instructions, see [Installing _fastlane_](https://docs.fastlane.tools/#installing-fastlane)

# Available Actions

## windows

### windows validate

```sh
[bundle exec] fastlane windows validate
```

Validate Windows Store configuration

### windows validate_manifest

```sh
[bundle exec] fastlane windows validate_manifest
```

Validate Windows package manifest

### windows validate_version_format

```sh
[bundle exec] fastlane windows validate_version_format
```

Validate version format in pubspec.yaml

### windows validate_signing_config

```sh
[bundle exec] fastlane windows validate_signing_config
```

Validate Windows signing configuration

### windows check_for_test_ids

```sh
[bundle exec] fastlane windows check_for_test_ids
```

Check for test IDs in Windows build

### windows build_msix

```sh
[bundle exec] fastlane windows build_msix
```

Build Windows release MSIX package

### windows build_exe

```sh
[bundle exec] fastlane windows build_exe
```

Build Windows release EXE

### windows deploy_store

```sh
[bundle exec] fastlane windows deploy_store
```

Deploy to Windows Store (Microsoft Partner Center)

### windows deploy_internal

```sh
[bundle exec] fastlane windows deploy_internal
```

Deploy to internal testing

### windows deploy_production

```sh
[bundle exec] fastlane windows deploy_production
```

Deploy to retail (production)

### windows test

```sh
[bundle exec] fastlane windows test
```

Run Flutter tests

### windows ci

```sh
[bundle exec] fastlane windows ci
```

Complete CI pipeline for Windows

### windows bump_build_number

```sh
[bundle exec] fastlane windows bump_build_number
```

Bump build number

### windows show_version

```sh
[bundle exec] fastlane windows show_version
```

Show current version

### windows test_deployment

```sh
[bundle exec] fastlane windows test_deployment
```

Run all deployment test cases

### windows test_prerequisites

```sh
[bundle exec] fastlane windows test_prerequisites
```

Test Windows Store deployment prerequisites

----

This README.md is auto-generated and will be re-generated every time [_fastlane_](https://fastlane.tools) is run.

More information about _fastlane_ can be found on [fastlane.tools](https://fastlane.tools).

The documentation of _fastlane_ can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
