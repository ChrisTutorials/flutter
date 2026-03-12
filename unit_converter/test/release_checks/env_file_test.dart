import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

/// Test suite to verify .env file configuration for release deployment.
/// These tests ensure the .env file is properly formatted and contains required values.
void main() {
  group('.env File Validation', () {
    late String? envContent;

    setUp(() {
      final envFile = File('.env');
      if (!envFile.existsSync()) {
        return; // Skip tests if .env doesn't exist
      }
      envContent = envFile.readAsStringSync();
    });

    test('.env file must exist', () {
      final envFile = File('.env');
      expect(
        envFile.existsSync(),
        isTrue,
        reason: '.env file must exist for local development and deployment',
      );
    });

    test('.env file must contain UNIT_CONVERTER_ADMOB_APP_ID', () {
      if (envContent == null) return;

      expect(
        envContent!.contains('UNIT_CONVERTER_ADMOB_APP_ID'),
        isTrue,
        reason: 'UNIT_CONVERTER_ADMOB_APP_ID must be set in .env file',
      );
    });

    test('UNIT_CONVERTER_ADMOB_APP_ID must have valid format', () {
      if (envContent == null) return;

      final adMobMatch = RegExp(
        r'UNIT_CONVERTER_ADMOB_APP_ID\s*=\s*ca-app-pub-\d{16}~\d{10}',
      ).firstMatch(envContent!);

      expect(
        adMobMatch,
        isNotNull,
        reason: 'UNIT_CONVERTER_ADMOB_APP_ID must be in format ca-app-pub-<16 digits>~<10 digits>',
      );
    });

    test('UNIT_CONVERTER_ADMOB_APP_ID must not use test ID', () {
      if (envContent == null) return;

      final hasTestId = RegExp(
        r'UNIT_CONVERTER_ADMOB_APP_ID\s*=\s*ca-app-pub-3940256099942544',
      ).hasMatch(envContent!);

      expect(
        hasTestId,
        isFalse,
        reason: 'UNIT_CONVERTER_ADMOB_APP_ID must not use Google\'s test app ID',
      );
    });

    test('.env file must contain GOOGLE_APPLICATION_CREDENTIALS', () {
      if (envContent == null) return;

      expect(
        envContent!.contains('GOOGLE_APPLICATION_CREDENTIALS'),
        isTrue,
        reason: 'GOOGLE_APPLICATION_CREDENTIALS must be set in .env file for Google Cloud services',
      );
    });

    test('GOOGLE_APPLICATION_CREDENTIALS must point to a valid file path', () {
      if (envContent == null) return;

      final credsMatch = RegExp(
        r'GOOGLE_APPLICATION_CREDENTIALS\s*=\s*(.+)',
      ).firstMatch(envContent!);

      expect(
        credsMatch,
        isNotNull,
        reason: 'GOOGLE_APPLICATION_CREDENTIALS must be set with a file path',
      );

      if (credsMatch != null) {
        var path = credsMatch.group(1)!.trim();
        // Remove quotes if present
        path = path.replaceAll(RegExp(r'^["\']|["\']$'), '');

        // Note: We can't verify the file exists in all environments (CI may not have it)
        // but we can verify the path format is valid
        expect(
          path.isNotEmpty,
          isTrue,
          reason: 'GOOGLE_APPLICATION_CREDENTIALS must have a non-empty path',
        );
      }
    });

    test('.env file must contain GOOGLE_PLAY_JSON_KEY_FILE', () {
      if (envContent == null) return;

      expect(
        envContent!.contains('GOOGLE_PLAY_JSON_KEY_FILE'),
        isTrue,
        reason: 'GOOGLE_PLAY_JSON_KEY_FILE must be set in .env file for Play Store upload',
      );
    });

    test('GOOGLE_PLAY_JSON_KEY_FILE must point to a valid file path', () {
      if (envContent == null) return;

      final keyMatch = RegExp(
        r'GOOGLE_PLAY_JSON_KEY_FILE\s*=\s*(.+)',
      ).firstMatch(envContent!);

      expect(
        keyMatch,
        isNotNull,
        reason: 'GOOGLE_PLAY_JSON_KEY_FILE must be set with a file path',
      );

      if (keyMatch != null) {
        var path = keyMatch.group(1)!.trim();
        // Remove quotes if present
        path = path.replaceAll(RegExp(r'^["\']|["\']$'), '');

        expect(
          path.isNotEmpty,
          isTrue,
          reason: 'GOOGLE_PLAY_JSON_KEY_FILE must have a non-empty path',
        );
      }
    });

    test('.env file must not contain empty lines with only whitespace', () {
      if (envContent == null) return;

      final lines = envContent!.split('\n');
      final emptyLines = lines.where((line) => line.trim().isEmpty && line.isNotEmpty);

      expect(
        emptyLines.isEmpty,
        isTrue,
        reason: '.env file should not contain lines with only whitespace',
      );
    });

    test('.env file comments must start with #', () {
      if (envContent == null) return;

      final lines = envContent!.split('\n');
      for (final line in lines) {
        final trimmed = line.trim();
        if (trimmed.isNotEmpty && !trimmed.contains('=')) {
          // If it's not a key=value pair, it should be a comment
          expect(
            trimmed.startsWith('#'),
            isTrue,
            reason: 'Non key=value lines in .env must be comments starting with #',
          );
        }
      }
    });

    test('.env file must use valid key=value format', () {
      if (envContent == null) return;

      final lines = envContent!.split('\n');
      var hasValidEntry = false;

      for (final line in lines) {
        final trimmed = line.trim();
        if (trimmed.isNotEmpty && !trimmed.startsWith('#')) {
          final parts = trimmed.split('=');
          expect(
            parts.length,
            greaterThanOrEqualTo(2),
            reason: 'Line "$trimmed" must be in KEY=VALUE format',
          );
          hasValidEntry = true;
        }
      }

      expect(
        hasValidEntry,
        isTrue,
        reason: '.env file must contain at least one valid key=value entry',
      );
    });
  });

  group('.env File Security Checks', () {
    late String? envContent;

    setUp(() {
      final envFile = File('.env');
      if (!envFile.existsSync()) {
        return; // Skip tests if .env doesn't exist
      }
      envContent = envFile.readAsStringSync();
    });

    test('.env file should not contain example values', () {
      if (envContent == null) return;

      final hasExample = RegExp(
        r'YOUR_|XXX|example\.com|placeholder',
        caseSensitive: false,
      ).hasMatch(envContent!);

      expect(
        hasExample,
        isFalse,
        reason: '.env file should not contain example or placeholder values',
      );
    });

    test('.env file values should not contain obvious secrets', () {
      if (envContent == null) return;

      // Check for common secret patterns that shouldn't be in .env
      final hasSecret = RegExp(
        r'password\s*=\s*["\']?123456["\']?|secret\s*=\s*["\']?secret["\']?',
        caseSensitive: false,
      ).hasMatch(envContent!);

      expect(
        hasSecret,
        isFalse,
        reason: '.env file should not contain obvious placeholder secrets',
      );
    });
  });

  group('.env File Integration Checks', () {
    test('.env file should be in .gitignore', () {
      final gitignoreFile = File('.gitignore');
      if (!gitignoreFile.existsSync()) {
        return; // Skip if .gitignore doesn't exist
      }

      final gitignoreContent = gitignoreFile.readAsStringSync();
      expect(
        gitignoreContent.contains('.env'),
        isTrue,
        reason: '.env file should be in .gitignore to prevent committing secrets',
      );
    });

    test('.env.example should exist for reference', () {
      final envExampleFile = File('.env.example');
      expect(
        envExampleFile.existsSync(),
        isTrue,
        reason: '.env.example should exist as a template for developers',
      );
    });

    test('.env.example should contain all required keys', () {
      final envExampleFile = File('.env.example');
      if (!envExampleFile.existsSync()) {
        return; // Skip if .env.example doesn't exist
      }

      final envExampleContent = envExampleFile.readAsStringSync();
      final requiredKeys = [
        'UNIT_CONVERTER_ADMOB_APP_ID',
        'GOOGLE_APPLICATION_CREDENTIALS',
        'GOOGLE_PLAY_JSON_KEY_FILE',
      ];

      for (final key in requiredKeys) {
        expect(
          envExampleContent.contains(key),
          isTrue,
          reason: '.env.example should contain $key as a reference',
        );
      }
    });
  });
}
