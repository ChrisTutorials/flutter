# Google Cloud Credentials Configuration

This document describes how the `GOOGLE_APPLICATION_CREDENTIALS` environment variable is configured for use across all Flutter apps and development environments.

## Overview

The `GOOGLE_APPLICATION_CREDENTIALS` environment variable points to a Google Cloud service account JSON key that provides authentication for Google Cloud services (Cloud Storage, Cloud Functions, Firestore, etc.).

## Credential Location

- **File**: `C:\Users\chris\.keys\poetic-axle-490013-m9-b3314de9cee3.json`
- **Type**: Service account key
- **Project**: `poetic-axle-490013-m9`

## Environment Configuration

### Windows PowerShell

The environment variable is configured as a user-level environment variable:

```powershell
GOOGLE_APPLICATION_CREDENTIALS=C:\Users\chris\.keys\poetic-axle-490013-m9-b3314de9cee3.json
```

This configuration persists across all PowerShell sessions and system restarts.

### WSL Ubuntu (Bash)

The environment variable is added to `~/.bashrc`:

```bash
export GOOGLE_APPLICATION_CREDENTIALS=/mnt/c/Users/chris/.keys/poetic-axle-490013-m9-b3314de9cee3.json
```

### Zsh (if installed)

If you use Zsh in WSL, add this to `~/.zshrc`:

```bash
export GOOGLE_APPLICATION_CREDENTIALS=/mnt/c/Users/chris/.keys/poetic-axle-490013-m9-b3314de9cee3.json
```

## Verification

### Windows PowerShell
```powershell
echo $env:GOOGLE_APPLICATION_CREDENTIALS
```

### WSL Bash
```bash
echo $GOOGLE_APPLICATION_CREDENTIALS
```

## Usage in Flutter Apps

### Dart/Flutter Code

When using Google Cloud services in Flutter, the Google Cloud client libraries automatically detect and use the `GOOGLE_APPLICATION_CREDENTIALS` environment variable:

```dart
import 'package:googleapis/storage/v1.dart' as storage;
import 'package:googleapis_auth/auth_io.dart' as auth;

// The client library will automatically use GOOGLE_APPLICATION_CREDENTIALS
final client = await auth.clientViaApplicationDefaultCredentials();
final api = storage.StorageApi(client);
```

### Server-Side Dart

For server-side Dart applications (e.g., Cloud Functions, backend services):

```dart
import 'package:googleapis/firestore/v1.dart' as firestore;
import 'package:googleapis_auth/auth_io.dart' as auth;

// Automatically uses GOOGLE_APPLICATION_CREDENTIALS
final client = await auth.clientViaApplicationDefaultCredentials();
final api = firestore.FirestoreApi(client);
```

## Integration with Release Pipeline

### Current Release Pipeline

The current Play Store release pipeline (see `play-store-release-runbook.md`) uses Fastlane with a separate Play Store service account (`google-play-service-account.json` or `GOOGLE_PLAY_JSON_KEY_FILE`).

### Google Cloud Services in Release Pipeline

If Google Cloud services are added to the app (e.g., Cloud Storage for crash reports, Firestore for user data, Cloud Functions for backend logic), the release pipeline should:

1. **Pre-deployment checks**: Verify that `GOOGLE_APPLICATION_CREDENTIALS` is set
2. **Build process**: The environment variable is automatically available to the build
3. **Testing**: Integration tests can use the credentials to test against Google Cloud services
4. **CI/CD**: In GitHub Actions or other CI systems, set the credential as a secret

### CI/CD Configuration

For GitHub Actions, add the service account key as a repository secret and reference it in workflows:

```yaml
- name: Set Google Cloud credentials
  run: |
    echo "${{ secrets.GOOGLE_APPLICATION_CREDENTIALS }}" > $HOME/.keys/service-account.json
    echo "GOOGLE_APPLICATION_CREDENTIALS=$HOME/.keys/service-account.json" >> $GITHUB_ENV

- name: Run integration tests
  run: flutter test integration_test/
  env:
    GOOGLE_APPLICATION_CREDENTIALS: ${{ secrets.GOOGLE_APPLICATION_CREDENTIALS }}
```

## Security Considerations

1. **Never commit service account keys** to version control
2. **Use minimal permissions** - Grant only the necessary roles to the service account
3. **Rotate keys regularly** - Delete old keys and create new ones periodically
4. **Monitor usage** - Use Google Cloud Console to monitor service account usage
5. **Restrict key usage** - Set IP restrictions and expiration dates on keys if possible

## Troubleshooting

### Environment Variable Not Set

**Symptom**: Applications fail to authenticate with Google Cloud services

**Solution**:
- Windows: Check System Environment Variables
- WSL: Verify the export line in `~/.bashrc` and restart your shell
- Run the verification commands above

### Key File Not Found

**Symptom**: `GOOGLE_APPLICATION_CREDENTIALS` points to a non-existent file

**Solution**:
- Verify the file exists at the specified path
- Check file permissions
- Ensure the path format is correct for your OS (Windows vs. WSL)

### Insufficient Permissions

**Symptom**: Authentication succeeds but operations fail with permission errors

**Solution**:
- Check the service account has the necessary IAM roles
- Review the Google Cloud Console IAM & Admin section
- Grant additional roles as needed

## Related Documentation

- [Play Store Release Runbook](play-store-release-runbook.md) - Play Store deployment process
- [AdMob Production Setup](ADMOB_PRODUCTION_SETUP.md) - AdMob configuration
- [Security Configuration](SECURITY_CONFIG.md) - Security best practices

## Support

For issues related to Google Cloud credentials:
1. Check the Google Cloud Console IAM & Admin section
2. Review the service account's IAM roles
3. Verify the key has not expired or been revoked
4. Check Google Cloud audit logs for authentication failures

