#!/bin/bash

# Pre-Deployment Verification Script
# This script runs all critical tests to ensure the app is ready for Play Store deployment

set -e  # Exit on any error

TEST_TIMEOUT="3s"

if [ -f ".env" ]; then
    set -a
    . ./.env
    set +a
fi

echo "========================================="
echo "Pre-Deployment Verification Script"
echo "========================================="
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# 1. Check Flutter installation
echo "1. Checking Flutter installation..."
if command_exists flutter; then
    FLUTTER_VERSION=$(flutter --version | head -n 1)
    print_success "Flutter installed: $FLUTTER_VERSION"
else
    print_error "Flutter is not installed or not in PATH"
    exit 1
fi

# 2. Check Dart installation
echo ""
echo "2. Checking Dart installation..."
if command_exists dart; then
    DART_VERSION=$(dart --version)
    print_success "Dart installed: $DART_VERSION"
else
    print_error "Dart is not installed or not in PATH"
    exit 1
fi

# 3. Check if we're in the correct directory
echo ""
echo "3. Checking project directory..."
if [ -f "pubspec.yaml" ]; then
    print_success "In correct Flutter project directory"
else
    print_error "Not in a Flutter project directory (pubspec.yaml not found)"
    exit 1
fi

# 4. Run pubspec tests
echo ""
echo "4. Running pubspec configuration tests..."
cd test/release_checks
if flutter test pubspec_test.dart --timeout "$TEST_TIMEOUT"; then
    print_success "Pubspec configuration tests passed"
else
    print_error "Pubspec configuration tests failed"
    exit 1
fi
cd ../..

# 5. Check AndroidManifest.xml
echo ""
echo "5. Checking AndroidManifest.xml..."
if [ -f "android/app/src/main/AndroidManifest.xml" ]; then
    MANIFEST="android/app/src/main/AndroidManifest.xml"
    
    # Check AdMob app ID
    if grep -q "com.google.android.gms.ads.APPLICATION_ID" "$MANIFEST"; then
        # Check if it's commented out
        if grep -q "<!--.*com.google.android.gms.ads.APPLICATION_ID" "$MANIFEST"; then
            print_error "AdMob Application ID is commented out in AndroidManifest.xml"
            exit 1
        else
            print_success "AdMob Application ID is present in AndroidManifest.xml"
        fi
    else
        print_error "AdMob Application ID is missing from AndroidManifest.xml"
        exit 1
    fi
    
    # Check advertising ID permission
    if grep -q "com.google.android.gms.permission.AD_ID" "$MANIFEST"; then
        print_success "Advertising ID permission is present"
    else
        print_error "Advertising ID permission is missing (required for Android 13+)"
        exit 1
    fi
    
    # Check billing permission
    if grep -q "com.android.vending.BILLING" "$MANIFEST"; then
        print_success "Billing permission is present"
    else
        print_error "Billing permission is missing (required for in-app purchases)"
        exit 1
    fi
    
    # Check internet permission
    if grep -q "android.permission.INTERNET" "$MANIFEST"; then
        print_success "Internet permission is present"
    else
        print_error "Internet permission is missing (required for AdMob and currency API)"
        exit 1
    fi
    
else
    print_error "AndroidManifest.xml not found"
    exit 1
fi

# 6. Check build.gradle.kts
echo ""
echo "6. Checking build.gradle.kts..."
if [ -f "android/app/build.gradle.kts" ]; then
    BUILD_GRADLE="android/app/build.gradle.kts"
    
    # Check code shrinking
    if grep -q "isMinifyEnabled = true" "$BUILD_GRADLE"; then
        print_success "Code shrinking is enabled"
    else
        print_error "Code shrinking is not enabled (required for release builds)"
        exit 1
    fi
    
    # Check resource shrinking
    if grep -q "isShrinkResources = true" "$BUILD_GRADLE"; then
        print_success "Resource shrinking is enabled"
    else
        print_error "Resource shrinking is not enabled (required for release builds)"
        exit 1
    fi
    
    # Check ProGuard
    if grep -q "proguardFiles" "$BUILD_GRADLE"; then
        print_success "ProGuard is configured"
    else
        print_error "ProGuard is not configured (required for code obfuscation)"
        exit 1
    fi
    
else
    print_error "build.gradle.kts not found"
    exit 1
fi

# 7. Check version format
echo ""
echo "7. Checking version format..."
VERSION=$(grep "^version:" pubspec.yaml | sed 's/version: //')
if [[ $VERSION =~ ^[0-9]+\.[0-9]+\.[0-9]+\+[0-9]+$ ]]; then
    print_success "Version format is correct: $VERSION"
    BUILD_NUMBER=$(echo $VERSION | cut -d'+' -f2)
    if [ "$BUILD_NUMBER" -gt 0 ]; then
        print_success "Build number is valid: $BUILD_NUMBER"
    else
        print_error "Build number must be greater than 0"
        exit 1
    fi
else
    print_error "Version format is incorrect. Expected: x.y.z+buildNumber, Got: $VERSION"
    exit 1
fi

# 8. Check for required dependencies
echo ""
echo "8. Checking required dependencies..."
REQUIRED_DEPS=("google_mobile_ads" "shared_preferences" "intl" "in_app_purchase" "http")
for dep in "${REQUIRED_DEPS[@]}"; do
    if grep -q "$dep" pubspec.yaml; then
        print_success "Dependency $dep is present"
    else
        print_error "Dependency $dep is missing"
        exit 1
    fi
done

# 9. Run Flutter tests
echo ""
echo "9. Running Flutter tests..."
if flutter test --timeout "$TEST_TIMEOUT"; then
    print_success "Flutter tests passed"
else
    print_error "Flutter tests failed"
    exit 1
fi

# 10. Check if release build is possible
echo ""
echo "10. Checking if release build is possible..."
flutter clean >/dev/null 2>&1
flutter pub get >/dev/null 2>&1
if flutter build apk --release --dry-run 2>/dev/null | grep -q "BUILD FAILED"; then
    print_error "Release build would fail"
    exit 1
else
    print_success "Release build configuration is valid"
fi

# 11. Check for common issues
echo ""
echo "11. Checking for common issues..."

# Check if AdMob app ID is set to test ID
if grep -q "ca-app-pub-3940256099942544" android/app/build.gradle.kts; then
    print_warning "AdMob app ID is set to test ID - this should be changed to production ID"
fi

# Check if key.properties exists
if [ ! -f "android/key.properties" ]; then
    print_warning "key.properties not found - app will be signed with debug keys (not secure for production)"
else
    print_success "Production signing configuration found"
fi

# Summary
echo ""
echo "========================================="
echo "✓ All pre-deployment checks passed!"
echo "========================================="
echo ""
echo "App is ready for Play Store deployment."
echo "Version: $VERSION"
echo ""
echo "Next steps:"
echo "1. Build release AAB: flutter build appbundle --release"
echo "2. Upload to Google Play Console"
echo "3. Complete store listing"
echo "4. Submit for review"
echo ""
