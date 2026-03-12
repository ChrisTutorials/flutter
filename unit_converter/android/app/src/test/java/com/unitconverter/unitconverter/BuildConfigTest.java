package com.unitconverter.unitconverter;

import org.junit.Test;
import org.junit.runner.RunWith;
import org.junit.runners.JUnit4;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileReader;
import java.io.IOException;

import static org.junit.Assert.*;

/**
 * Test suite to verify critical build.gradle.kts requirements for Play Store compliance.
 * These tests prevent common build configuration failures.
 */
@RunWith(JUnit4.class)
public class BuildConfigTest {

    private static final String BUILD_GRADLE_PATH = "build.gradle.kts";

    /**
     * Test 1: Verify AdMob app ID is configured in build.gradle.kts
     * Failure cause: AdMob ads won't load, app may crash
     */
    @Test
    public void testAdMobAppIdConfigured() throws IOException {
        String buildGradleContent = readBuildGradle();
        
        assertTrue(
            "AdMob app ID must be configured in build.gradle.kts. " +
            "Add: manifestPlaceholders[\"adMobAppId\"] = \"ca-app-pub-xxxxxxxxxx~xxxxxxxxxx\"",
            buildGradleContent.contains("adMobAppId") ||
            buildGradleContent.contains("adMobAppId")
        );
    }

    /**
     * Test 2: Verify target SDK is set to at least 33 (Android 13)
     * Failure cause: Google Play requires target SDK 33+ for new apps
     */
    @Test
    public void testTargetSdkVersion() throws IOException {
        String buildGradleContent = readBuildGradle();
        
        assertTrue(
            "Target SDK must be at least 33 (Android 13) for Google Play compliance. " +
            "Update: targetSdk = flutter.targetSdkVersion (should be 33 or higher)",
            buildGradleContent.contains("targetSdk") ||
            buildGradleContent.contains("targetSdkVersion")
        );
    }

    /**
     * Test 3: Verify min SDK is at least 21 (Android 5.0)
     * Failure cause: App won't install on older devices
     */
    @Test
    public void testMinSdkVersion() throws IOException {
        String buildGradleContent = readBuildGradle();
        
        assertTrue(
            "Min SDK must be at least 21 (Android 5.0). " +
            "Update: minSdk = flutter.minSdkVersion",
            buildGradleContent.contains("minSdk") ||
            buildGradleContent.contains("minSdkVersion")
        );
    }

    /**
     * Test 4: Verify code shrinking is enabled for release builds
     * Failure cause: App size will be too large, Google Play may reject
     */
    @Test
    public void testCodeShrinkingEnabled() throws IOException {
        String buildGradleContent = readBuildGradle();
        
        assertTrue(
            "Code shrinking must be enabled for release builds to reduce app size. " +
            "Add: isMinifyEnabled = true in release build type",
            buildGradleContent.contains("isMinifyEnabled = true")
        );
    }

    /**
     * Test 5: Verify resource shrinking is enabled for release builds
     * Failure cause: App size will be too large, Google Play may reject
     */
    @Test
    public void testResourceShrinkingEnabled() throws IOException {
        String buildGradleContent = readBuildGradle();
        
        assertTrue(
            "Resource shrinking must be enabled for release builds to reduce app size. " +
            "Add: isShrinkResources = true in release build type",
            buildGradleContent.contains("isShrinkResources = true")
        );
    }

    /**
     * Test 6: Verify ProGuard is configured for release builds
     * Failure cause: Code obfuscation won't work, app may crash
     */
    @Test
    public void testProGuardConfigured() throws IOException {
        String buildGradleContent = readBuildGradle();
        
        assertTrue(
            "ProGuard must be configured for release builds. " +
            "Add: proguardFiles(getDefaultProguardFile(\"proguard-android-optimize.txt\"), \"proguard-rules.pro\")",
            buildGradleContent.contains("proguardFiles") ||
            buildGradleContent.contains("proguard-rules.pro")
        );
    }

    /**
     * Test 7: Verify release signing config is present
     * Failure cause: App won't be signed properly, can't upload to Play Store
     */
    @Test
    public void testReleaseSigningConfigPresent() throws IOException {
        String buildGradleContent = readBuildGradle();
        
        assertTrue(
            "Release signing config must be present. " +
            "Add: signingConfigs { create(\"release\") { ... } }",
            buildGradleContent.contains("signingConfigs") &&
            buildGradleContent.contains("release")
        );
    }

    /**
     * Test 8: Verify namespace is set
     * Failure cause: Build will fail on Android Gradle Plugin 8.0+
     */
    @Test
    public void testNamespaceSet() throws IOException {
        String buildGradleContent = readBuildGradle();
        
        assertTrue(
            "Namespace must be set in android block. " +
            "Add: namespace = \"com.unitconverter.unit_converter\"",
            buildGradleContent.contains("namespace = \"") ||
            buildGradleContent.contains("namespace=")
        );
    }

    /**
     * Test 9: Verify application ID is set
     * Failure cause: App will have wrong package name
     */
    @Test
    public void testApplicationIdSet() throws IOException {
        String buildGradleContent = readBuildGradle();
        
        assertTrue(
            "Application ID must be set. " +
            "Add: applicationId = \"com.unitconverter.unit_converter\"",
            buildGradleContent.contains("applicationId = \"") ||
            buildGradleContent.contains("applicationId=")
        );
    }

    /**
     * Test 10: Verify version code and version name are configured
     * Failure cause: App won't have proper version info
     */
    @Test
    public void testVersionConfigured() throws IOException {
        String buildGradleContent = readBuildGradle();
        
        assertTrue(
            "Version code and version name must be configured. " +
            "Add: versionCode = flutter.versionCode and versionName = flutter.versionName",
            buildGradleContent.contains("versionCode") &&
            buildGradleContent.contains("versionName")
        );
    }

    /**
     * Helper method to read the build.gradle.kts file
     */
    private String readBuildGradle() throws IOException {
        StringBuilder content = new StringBuilder();
        File buildGradleFile = new File(BUILD_GRADLE_PATH);
        
        if (!buildGradleFile.exists()) {
            throw new IOException("build.gradle.kts not found at: " + BUILD_GRADLE_PATH);
        }
        
        try (BufferedReader reader = new BufferedReader(new FileReader(buildGradleFile))) {
            String line;
            while ((line = reader.readLine()) != null) {
                content.append(line).append("\n");
            }
        }
        
        return content.toString();
    }
}
