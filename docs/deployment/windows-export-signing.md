# Windows Export and Signing Guide

## Overview

Use this guide as the canonical source for Windows exports, MSIX signing, and Microsoft Partner Center uploads for `unit_converter`.

Use the broader deployment guides for platform selection and CI/CD context, but keep all Windows packaging details here.

## Canonical Windows Packaging Values

These values must match Microsoft Partner Center exactly.

- **Display name**: `Unit Converter All-in-One`
- **Publisher display name**: `MoonBark Studio`
- **Identity name**: `MoonBarkStudio.UnitConverterAll-in-One`
- **Publisher**: `CN=3EFF2941-6801-4CEC-B527-2958F9AE4902`

The authoritative source in the repo is `unit_converter/pubspec.yaml` under `msix_config`.

## Required Prerequisites

- **OS**: Windows 10/11
- **Flutter**: Windows desktop enabled
- **Build tools**: Visual Studio with Desktop C++ workload and Windows SDK
- **Project root**: `c:\dev\flutter\unit_converter`
- **MSIX package toolchain**: `msix` dependency installed via `pubspec.yaml`
- **Signing certificate**: `.pfx` file whose subject matches the Partner Center publisher

## Signing Inputs

The export flow requires a `.pfx` certificate and password.

Recommended environment variables:

```powershell
$env:WINDOWS_CERTIFICATE_PATH = "C:\path\to\certificate.pfx"
$env:WINDOWS_CERTIFICATE_PASSWORD = "your-password"
```

For the current local setup, the working repo-local certificate path is:

```powershell
c:\dev\flutter\unit_converter\windows\certificate.pfx
```

## Pre-Export Validation

Run the Windows release checks before exporting:

```powershell
cd c:\dev\flutter\unit_converter
flutter test test\release_checks\pubspec_test.dart
```

This guards against regressions in:

- **Publisher display name**
- **Identity name**
- **Publisher subject**

## Export MSIX

From the app root:

```powershell
cd c:\dev\flutter\unit_converter
$env:WINDOWS_CERTIFICATE_PATH = "c:\dev\flutter\unit_converter\windows\certificate.pfx"
$env:WINDOWS_CERTIFICATE_PASSWORD = "your-password"
dart run msix:create --certificate-path "$env:WINDOWS_CERTIFICATE_PATH" --certificate-password "$env:WINDOWS_CERTIFICATE_PASSWORD"
```

Output package:

```powershell
c:\dev\flutter\unit_converter\build\windows\x64\runner\Release\unit_converter.msix
```

## Verify the Built Package

Inspect the embedded manifest after export:

```powershell
tar -xOf c:\dev\flutter\unit_converter\build\windows\x64\runner\Release\unit_converter.msix AppxManifest.xml
```

Expected values in `AppxManifest.xml`:

- **Identity Name**: `MoonBarkStudio.UnitConverterAll-in-One`
- **Publisher**: `CN=3EFF2941-6801-4CEC-B527-2958F9AE4902`
- **PublisherDisplayName**: `MoonBark Studio`

## Upload Flow

After export:

1. Open Microsoft Partner Center.
2. Navigate to the app package upload page.
3. Upload `unit_converter.msix`.
4. Confirm package identity, family name, and publisher match the expected Partner Center values.
5. Proceed with submission.

## Troubleshooting

### Wrong package identity or family name

Check `unit_converter/pubspec.yaml` under `msix_config` and rerun:

```powershell
flutter test test\release_checks\pubspec_test.dart
```

### Wrong package publisher name

The package was likely signed with the fallback test certificate. Rebuild with the correct `.pfx` and password.

### `Msix Testing` appears in the manifest or signing output

That means no valid certificate was supplied. Set:

```powershell
$env:WINDOWS_CERTIFICATE_PATH
$env:WINDOWS_CERTIFICATE_PASSWORD
```

Then rebuild.

### Fastlane Windows lanes

The current Windows Fastlane lanes are validation-oriented, but the actual MSIX export path is the direct `dart run msix:create` command above.

## Routing

If you update Windows packaging instructions elsewhere, replace duplicated steps with a link back to this guide:

`docs/deployment/windows-export-signing.md`
