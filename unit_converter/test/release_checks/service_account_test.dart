import 'dart:io';
import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';

/// Test suite to verify Google Play Console service account JSON configuration.
/// These tests ensure the service account key is properly formatted and contains required fields.
void main() {
  group('Service Account JSON Validation', () {
    late Map<String, dynamic> serviceAccountData;

    setUp(() {
      // Check multiple possible locations for the service account key
      final possiblePaths = [
        'android/fastlane/google-play-service-account.json',
        '../android/fastlane/google-play-service-account.json',
        '../../android/fastlane/google-play-service-account.json',
        // Also check environment variable
        Platform.environment['GOOGLE_PLAY_JSON_KEY_FILE'],
      ];

      String? serviceAccountPath;
      for (final path in possiblePaths) {
        if (path != null) {
          final file = File(path);
          if (file.existsSync()) {
            serviceAccountPath = path;
            break;
          }
        }
      }

      if (serviceAccountPath == null) {
        skip('Service account JSON file not found - skipping service account validation tests');
        return;
      }

      final serviceAccountFile = File(serviceAccountPath);
      final jsonContent = serviceAccountFile.readAsStringSync();

      try {
        serviceAccountData = json.decode(jsonContent) as Map<String, dynamic>;
      } catch (e) {
        fail('Failed to parse service account JSON: $e');
      }
    });

    test('Service account JSON must be valid JSON', () {
      // If we got here, JSON parsing succeeded in setUp
      expect(serviceAccountData, isNotNull);
    });

    test('Service account must have type field', () {
      expect(
        serviceAccountData.containsKey('type'),
        isTrue,
        reason: 'Service account JSON must have a "type" field',
      );

      expect(
        serviceAccountData['type'],
        equals('service_account'),
        reason: 'Service account type must be "service_account"',
      );
    });

    test('Service account must have project_id field', () {
      expect(
        serviceAccountData.containsKey('project_id'),
        isTrue,
        reason: 'Service account JSON must have a "project_id" field',
      );

      final projectId = serviceAccountData['project_id'] as String?;
      expect(
        projectId,
        isNotNull,
        reason: 'project_id must not be null',
      );

      expect(
        projectId?.isNotEmpty,
        isTrue,
        reason: 'project_id must not be empty',
      );
    });

    test('Service account must have private_key_id field', () {
      expect(
        serviceAccountData.containsKey('private_key_id'),
        isTrue,
        reason: 'Service account JSON must have a "private_key_id" field',
      );

      final privateKeyId = serviceAccountData['private_key_id'] as String?;
      expect(
        privateKeyId,
        isNotNull,
        reason: 'private_key_id must not be null',
      );

      expect(
        privateKeyId?.isNotEmpty,
        isTrue,
        reason: 'private_key_id must not be empty',
      );
    });

    test('Service account must have private_key field', () {
      expect(
        serviceAccountData.containsKey('private_key'),
        isTrue,
        reason: 'Service account JSON must have a "private_key" field',
      );

      final privateKey = serviceAccountData['private_key'] as String?;
      expect(
        privateKey,
        isNotNull,
        reason: 'private_key must not be null',
      );

      expect(
        privateKey?.isNotEmpty,
        isTrue,
        reason: 'private_key must not be empty',
      );

      // Verify it's a valid RSA private key
      expect(
        privateKey?.startsWith('-----BEGIN PRIVATE KEY-----'),
        isTrue,
        reason: 'private_key must be a valid RSA private key',
      );

      expect(
        privateKey?.endsWith('-----END PRIVATE KEY-----'),
        isTrue,
        reason: 'private_key must be a valid RSA private key',
      );
    });

    test('Service account must have client_email field', () {
      expect(
        serviceAccountData.containsKey('client_email'),
        isTrue,
        reason: 'Service account JSON must have a "client_email" field',
      );

      final clientEmail = serviceAccountData['client_email'] as String?;
      expect(
        clientEmail,
        isNotNull,
        reason: 'client_email must not be null',
      );

      expect(
        clientEmail?.isNotEmpty,
        isTrue,
        reason: 'client_email must not be empty',
      );

      // Verify it's a valid email format
      expect(
        clientEmail?.contains('@'),
        isTrue,
        reason: 'client_email must be a valid email address',
      );

      expect(
        clientEmail?.endsWith('.iam.gserviceaccount.com'),
        isTrue,
        reason: 'client_email must be a Google service account email',
      );
    });

    test('Service account must have client_id field', () {
      expect(
        serviceAccountData.containsKey('client_id'),
        isTrue,
        reason: 'Service account JSON must have a "client_id" field',
      );

      final clientId = serviceAccountData['client_id'] as String?;
      expect(
        clientId,
        isNotNull,
        reason: 'client_id must not be null',
      );

      expect(
        clientId?.isNotEmpty,
        isTrue,
        reason: 'client_id must not be empty',
      );

      // Verify it's a numeric string
      expect(
        int.tryParse(clientId ?? ''),
        isNotNull,
        reason: 'client_id must be a numeric string',
      );
    });

    test('Service account must have auth_uri field', () {
      expect(
        serviceAccountData.containsKey('auth_uri'),
        isTrue,
        reason: 'Service account JSON must have an "auth_uri" field',
      );

      final authUri = serviceAccountData['auth_uri'] as String?;
      expect(
        authUri,
        isNotNull,
        reason: 'auth_uri must not be null',
      );

      expect(
        authUri?.isNotEmpty,
        isTrue,
        reason: 'auth_uri must not be empty',
      );

      // Verify it's a valid URL
      expect(
        authUri?.startsWith('https://'),
        isTrue,
        reason: 'auth_uri must be a valid HTTPS URL',
      );
    });

    test('Service account must have token_uri field', () {
      expect(
        serviceAccountData.containsKey('token_uri'),
        isTrue,
        reason: 'Service account JSON must have a "token_uri" field',
      );

      final tokenUri = serviceAccountData['token_uri'] as String?;
      expect(
        tokenUri,
        isNotNull,
        reason: 'token_uri must not be null',
      );

      expect(
        tokenUri?.isNotEmpty,
        isTrue,
        reason: 'token_uri must not be empty',
      );

      // Verify it's a valid URL
      expect(
        tokenUri?.startsWith('https://'),
        isTrue,
        reason: 'token_uri must be a valid HTTPS URL',
      );
    });

    test('Service account must have auth_provider_x509_cert_url field', () {
      expect(
        serviceAccountData.containsKey('auth_provider_x509_cert_url'),
        isTrue,
        reason: 'Service account JSON must have an "auth_provider_x509_cert_url" field',
      );

      final certUrl = serviceAccountData['auth_provider_x509_cert_url'] as String?;
      expect(
        certUrl,
        isNotNull,
        reason: 'auth_provider_x509_cert_url must not be null',
      );

      expect(
        certUrl?.isNotEmpty,
        isTrue,
        reason: 'auth_provider_x509_cert_url must not be empty',
      );

      // Verify it's a valid URL
      expect(
        certUrl?.startsWith('https://'),
        isTrue,
        reason: 'auth_provider_x509_cert_url must be a valid HTTPS URL',
      );
    });

    test('Service account must have client_x509_cert_url field', () {
      expect(
        serviceAccountData.containsKey('client_x509_cert_url'),
        isTrue,
        reason: 'Service account JSON must have a "client_x509_cert_url" field',
      );

      final certUrl = serviceAccountData['client_x509_cert_url'] as String?;
      expect(
        certUrl,
        isNotNull,
        reason: 'client_x509_cert_url must not be null',
      );

      expect(
        certUrl?.isNotEmpty,
        isTrue,
        reason: 'client_x509_cert_url must not be empty',
      );

      // Verify it's a valid URL
      expect(
        certUrl?.startsWith('https://'),
        isTrue,
        reason: 'client_x509_cert_url must be a valid HTTPS URL',
      );
    });

    test('Service account project_id should match expected project', () {
      // This is a configurable check - adjust the expected project ID as needed
      final expectedProjectIds = [
        'poetic-axle-490013-m9', // Example project ID
      ];

      final projectId = serviceAccountData['project_id'] as String?;
      expect(
        expectedProjectIds.contains(projectId),
        isTrue,
        reason: 'Service account project_id should match the expected Google Cloud project',
      );
    });

    test('Service account email should contain project_id', () {
      final projectId = serviceAccountData['project_id'] as String?;
      final clientEmail = serviceAccountData['client_email'] as String?;

      expect(
        clientEmail?.contains(projectId ?? ''),
        isTrue,
        reason: 'Service account email should contain the project_id',
      );
    });
  });

  group('Service Account Security Checks', () {
    late Map<String, dynamic> serviceAccountData;

    setUp(() {
      final possiblePaths = [
        'android/fastlane/google-play-service-account.json',
        '../android/fastlane/google-play-service-account.json',
        '../../android/fastlane/google-play-service-account.json',
        Platform.environment['GOOGLE_PLAY_JSON_KEY_FILE'],
      ];

      String? serviceAccountPath;
      for (final path in possiblePaths) {
        if (path != null) {
          final file = File(path);
          if (file.existsSync()) {
            serviceAccountPath = path;
            break;
          }
        }
      }

      if (serviceAccountPath == null) {
        skip('Service account JSON file not found - skipping security checks');
        return;
      }

      final serviceAccountFile = File(serviceAccountPath);
      final jsonContent = serviceAccountFile.readAsStringSync();
      serviceAccountData = json.decode(jsonContent) as Map<String, dynamic>;
    });

    test('Service account file should be in .gitignore', () {
      final gitignoreFile = File('.gitignore');
      if (!gitignoreFile.existsSync()) {
        skip('.gitignore file not found');
        return;
      }

      final gitignoreContent = gitignoreFile.readAsStringSync();
      expect(
        gitignoreContent.contains('google-play-service-account.json') ||
        gitignoreContent.contains('*.json') ||
        gitignoreContent.contains('fastlane/*.json'),
        isTrue,
        reason: 'Service account JSON file should be in .gitignore to prevent committing secrets',
      );
    });

    test('Service account private_key should not be a placeholder', () {
      final privateKey = serviceAccountData['private_key'] as String?;

      expect(
        privateKey?.contains('YOUR_PRIVATE_KEY'),
        isFalse,
        reason: 'Service account private_key should not be a placeholder',
      );

      expect(
        privateKey?.contains('XXXX'),
        isFalse,
        reason: 'Service account private_key should not contain XXXX placeholders',
      );
    });
  });

  group('Service Account Integration Checks', () {
    test('Service account file should exist at expected location', () {
      final expectedPath = 'android/fastlane/google-play-service-account.json';
      final file = File(expectedPath);

      expect(
        file.existsSync(),
        isTrue,
        reason: 'Service account file should exist at $expectedPath',
      );
    });

    test('Service account file should be readable', () {
      final expectedPath = 'android/fastlane/google-play-service-account.json';
      final file = File(expectedPath);

      if (!file.existsSync()) {
        skip('Service account file not found at expected location');
        return;
      }

      expect(
        file.canRead(),
        isTrue,
        reason: 'Service account file should be readable',
      );
    });
  });
}
