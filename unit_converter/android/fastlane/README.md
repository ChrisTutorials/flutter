fastlane documentation
----

# Installation

Make sure you have the latest version of the Xcode command line tools installed:

```sh
xcode-select --install
```

For _fastlane_ installation instructions, see [Installing _fastlane_](https://docs.fastlane.tools/#installing-fastlane)

# Available Actions

## Android

### android validate

```sh
[bundle exec] fastlane android validate
```

Run all pre-deployment validation checks

### android validate_android_manifest

```sh
[bundle exec] fastlane android validate_android_manifest
```

Validate AndroidManifest.xml for Play Store compliance

### android validate_build_config

```sh
[bundle exec] fastlane android validate_build_config
```

Validate build.gradle.kts configuration

### android validate_version_format

```sh
[bundle exec] fastlane android validate_version_format
```

Validate version format in pubspec.yaml

### android validate_permissions

```sh
[bundle exec] fastlane android validate_permissions
```

Validate required permissions

### android validate_admob_config

```sh
[bundle exec] fastlane android validate_admob_config
```

Validate AdMob configuration

### android check_for_test_ids

```sh
[bundle exec] fastlane android check_for_test_ids
```

Check for test IDs in production configuration

### android validate_signing_config

```sh
[bundle exec] fastlane android validate_signing_config
```

Validate signing configuration

### android build_release

```sh
[bundle exec] fastlane android build_release
```

Build release AAB

### android build_apk

```sh
[bundle exec] fastlane android build_apk
```

Build release APK

### android deploy_internal

```sh
[bundle exec] fastlane android deploy_internal
```

Validate, build, and upload to internal testing track

### android deploy_alpha

```sh
[bundle exec] fastlane android deploy_alpha
```

Validate, build, and upload to alpha testing track

### android deploy_beta

```sh
[bundle exec] fastlane android deploy_beta
```

Validate, build, and upload to beta testing track

### android deploy_production

```sh
[bundle exec] fastlane android deploy_production
```

Validate, build, and upload to production

### android upload_screenshots

```sh
[bundle exec] fastlane android upload_screenshots
```

Upload screenshots to Play Store

### android upload_metadata

```sh
[bundle exec] fastlane android upload_metadata
```

Upload metadata to Play Store

### android test

```sh
[bundle exec] fastlane android test
```

Run Flutter tests

### android ci

```sh
[bundle exec] fastlane android ci
```

Run Flutter tests and build validation

### android bump_build_number

```sh
[bundle exec] fastlane android bump_build_number
```

Increment build number

### android show_version

```sh
[bundle exec] fastlane android show_version
```

Show current version

----

This README.md is auto-generated and will be re-generated every time [_fastlane_](https://fastlane.tools) is run.

More information about _fastlane_ can be found on [fastlane.tools](https://fastlane.tools).

The documentation of _fastlane_ can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
