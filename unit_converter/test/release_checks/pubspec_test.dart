import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:crypto/crypto.dart';

/// Test suite to verify critical pubspec.yaml requirements for Play Store compliance.
/// These tests prevent common version and dependency configuration failures.
void main() {
  group('Pubspec Release Checks', () {
    late String pubspecContent;

    setUp(() {
      final pubspecFile = File('pubspec.yaml');
      if (!pubspecFile.existsSync()) {
        throw Exception('pubspec.yaml not found');
      }
      pubspecContent = pubspecFile.readAsStringSync();
    });

    test('Version must be in correct format (x.y.z+buildNumber)', () {
      final versionRegex = RegExp(
        r'^version:\s*\d+\.\d+\.\d+\+\d+',
        multiLine: true,
      );
      expect(
        versionRegex.hasMatch(pubspecContent),
        isTrue,
        reason: 'Version must be in format x.y.z+buildNumber (e.g., 1.0.0+1)',
      );
    });

    test('Build number must be greater than 0', () {
      final versionMatch = RegExp(r'version:\s*\d+\.\d+\.\d+\+(\d+)').firstMatch(pubspecContent);
      expect(versionMatch, isNotNull, reason: 'Version with build number not found');
      
      final buildNumber = int.parse(versionMatch!.group(1)!);
      expect(
        buildNumber,
        greaterThan(0),
        reason: 'Build number must be greater than 0',
      );
    });

    test('Version must have build number specified', () {
      final hasBuildNumber = RegExp(r'version:\s*\d+\.\d+\.\d+\+').hasMatch(pubspecContent);
      expect(
        hasBuildNumber,
        isTrue,
        reason: 'Version must include build number (e.g., 1.0.0+1, not just 1.0.0)',
      );
    });

    test('google_mobile_ads dependency must be present', () {
      expect(
        pubspecContent.contains('google_mobile_ads'),
        isTrue,
        reason: 'google_mobile_ads dependency must be present for AdMob',
      );
    });

    test('shared_preferences dependency must be present', () {
      expect(
        pubspecContent.contains('shared_preferences'),
        isTrue,
        reason: 'shared_preferences dependency must be present for settings',
      );
    });

    test('intl dependency must be present', () {
      expect(
        pubspecContent.contains('intl'),
        isTrue,
        reason: 'intl dependency must be present for number formatting',
      );
    });

    test('in_app_purchase dependency must be present', () {
      expect(
        pubspecContent.contains('in_app_purchase'),
        isTrue,
        reason: 'in_app_purchase dependency must be present for premium features',
      );
    });

    test('http dependency must be present', () {
      expect(
        pubspecContent.contains('http'),
        isTrue,
        reason: 'http dependency must be present for currency API',
      );
    });

    test('App name must be descriptive', () {
      final nameMatch = RegExp(r'name:\s*(.+)').firstMatch(pubspecContent);
      expect(nameMatch, isNotNull, reason: 'App name not found in pubspec.yaml');
      
      final name = nameMatch!.group(1)!.trim();
      expect(
        name.length,
        greaterThan(3),
        reason: 'App name must be descriptive (at least 4 characters)',
      );
    });

    test('Description must be present', () {
      final hasDescription = RegExp(r'description:\s*".+"').hasMatch(pubspecContent);
      expect(
        hasDescription,
        isTrue,
        reason: 'Description must be present in pubspec.yaml',
      );
    });

    test('publish_to must be set to none for private apps', () {
      expect(
        pubspecContent.contains("publish_to: 'none'"),
        isTrue,
        reason: 'publish_to should be set to none for private apps',
      );
    });

    test('SDK version constraints must be specified', () {
      expect(
        pubspecContent.contains('sdk:'),
        isTrue,
        reason: 'SDK version constraints must be specified',
      );
    });

    test('Flutter SDK constraint must be at least 3.0.0', () {
      final flutterSdkMatch = RegExp(r'flutter:\s*">=(\d+\.\d+\.\d+)"').firstMatch(pubspecContent);
      if (flutterSdkMatch != null) {
        final version = flutterSdkMatch.group(1)!;
        final major = int.parse(version.split('.')[0]);
        expect(
          major,
          greaterThanOrEqualTo(3),
          reason: 'Flutter SDK should be at least 3.0.0',
        );
      }
    });

    test('Windows MSIX publisher display name matches Partner Center', () {
      final publisherDisplayNameMatch = RegExp(
        r'publisher_display_name:\s*(.+)',
        multiLine: true,
      ).firstMatch(pubspecContent);
      expect(
        publisherDisplayNameMatch,
        isNotNull,
        reason: 'Windows MSIX publisher_display_name must be set',
      );

      expect(
        publisherDisplayNameMatch!.group(1)!.trim(),
        equals('MoonBark Studio'),
        reason: 'Windows MSIX publisher_display_name must exactly match the Partner Center publisher display name',
      );
    });

    test('Windows MSIX identity name remains stable for store submissions', () {
      final identityNameMatch = RegExp(
        r'identity_name:\s*(.+)',
        multiLine: true,
      ).firstMatch(pubspecContent);
      expect(
        identityNameMatch,
        isNotNull,
        reason: 'Windows MSIX identity_name must be set',
      );

      expect(
        identityNameMatch!.group(1)!.trim(),
        equals('MoonBarkStudio.UnitConverterAll-in-One'),
        reason: 'Windows MSIX identity_name must remain stable to avoid Partner Center package mismatches',
      );
    });

    test('Windows MSIX publisher subject matches Partner Center', () {
      final publisherMatch = RegExp(
        r'publisher:\s*(.+)',
        multiLine: true,
      ).firstMatch(pubspecContent);
      expect(
        publisherMatch,
        isNotNull,
        reason: 'Windows MSIX publisher must be set',
      );

      expect(
        publisherMatch!.group(1)!.trim(),
        equals('CN=3EFF2941-6801-4CEC-B527-2958F9AE4902'),
        reason: 'Windows MSIX publisher must exactly match the Partner Center publisher subject',
      );
    });

    test('Windows app must use custom Unit Converter logo, not default Flutter logo', () {
      final iconFile = File('windows/runner/resources/app_icon.ico');
      expect(
        iconFile.existsSync(),
        isTrue,
        reason: 'Windows app icon file must exist at windows/runner/resources/app_icon.ico',
      );

      // Read the icon file and compute its MD5 hash
      final iconBytes = iconFile.readAsBytesSync();
      final iconHash = md5.convert(iconBytes).toString().toUpperCase();

      // The default Flutter icon MD5 hash (from Flutter template)
      const defaultFlutterIconHash = '6EA04D80CA2A3FA92C7717C3C44CCC19';

      expect(
        iconHash,
        isNot(equals(defaultFlutterIconHash)),
        reason: 'Windows app must use custom Unit Converter logo, not the default Flutter logo. '
                'Current icon hash: $iconHash, Default Flutter icon hash: $defaultFlutterIconHash',
      );

      // Also verify the icon file is not empty
      expect(
        iconBytes.isNotEmpty,
        isTrue,
        reason: 'Windows app icon file must not be empty',
      );

      // Verify the icon file has a reasonable size (at least 1KB, not more than 1MB)
      expect(
        iconBytes.length,
        greaterThanOrEqualTo(1024),
        reason: 'Windows app icon file must be at least 1KB',
      );
      expect(
        iconBytes.length,
        lessThanOrEqualTo(1024 * 1024),
        reason: 'Windows app icon file must not exceed 1MB',
      );
    });
  });

  group('Version Increment Checks', () {
    test('Version should be incrementable', () {
      final pubspecFile = File('pubspec.yaml');
      final pubspecContent = pubspecFile.readAsStringSync();
      
      final versionMatch = RegExp(r'version:\s*(\d+)\.(\d+)\.(\d+)\+(\d+)').firstMatch(pubspecContent);
      expect(versionMatch, isNotNull, reason: 'Version not in correct format');
      
      final major = int.parse(versionMatch!.group(1)!);
      final minor = int.parse(versionMatch.group(2)!);
      final patch = int.parse(versionMatch.group(3)!);
      final buildNumber = int.parse(versionMatch.group(4)!);
      
      // Verify all version components are non-negative
      expect(major, greaterThanOrEqualTo(0), reason: 'Major version must be non-negative');
      expect(minor, greaterThanOrEqualTo(0), reason: 'Minor version must be non-negative');
      expect(patch, greaterThanOrEqualTo(0), reason: 'Patch version must be non-negative');
      expect(buildNumber, greaterThan(0), reason: 'Build number must be greater than 0');
    });

    test('Build number should be unique for each release', () {
      // This is a placeholder test - in a real scenario, you'd check against
      // previously released versions to ensure the build number is unique
      final pubspecFile = File('pubspec.yaml');
      final pubspecContent = pubspecFile.readAsStringSync();
      
      final versionMatch = RegExp(r'version:\s*\d+\.\d+\.\d+\+(\d+)').firstMatch(pubspecContent);
      expect(versionMatch, isNotNull, reason: 'Version with build number not found');
      
      final buildNumber = int.parse(versionMatch!.group(1)!);
      
      // In production, you would check this against a database of released versions
      expect(buildNumber, greaterThan(0), reason: 'Build number must be set');
    });
  });

  group('Dependency Version Checks', () {
    test('Critical dependencies should have version constraints', () {
      final pubspecFile = File('pubspec.yaml');
      final pubspecContent = pubspecFile.readAsStringSync();
      
      // Check that critical dependencies have version constraints
      final dependencies = ['google_mobile_ads', 'shared_preferences', 'intl'];
      
      for (final dep in dependencies) {
        final depRegex = RegExp(
          '^\\s*${RegExp.escape(dep)}:\\s*\\^?\\d+\\.\\d+\\.\\d+',
          caseSensitive: false,
          multiLine: true,
        );
        expect(
          depRegex.hasMatch(pubspecContent),
          isTrue,
          reason: '$dep should have a version constraint',
        );
      }
    });
  });
}
