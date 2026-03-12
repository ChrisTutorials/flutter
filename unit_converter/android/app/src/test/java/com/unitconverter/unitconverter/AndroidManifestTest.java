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
 * Test suite to verify critical AndroidManifest.xml requirements for Play Store compliance.
 * These tests prevent common release failures that cause app rejections.
 */
@RunWith(JUnit4.class)
public class AndroidManifestTest {

    private static final String MANIFEST_PATH = "src/main/AndroidManifest.xml";

    /**
     * Test 1: Verify AdMob Application ID is present in AndroidManifest.xml
     * Failure cause: Google Play rejects apps with missing AdMob app ID
     */
    @Test
    public void testAdMobApplicationIdPresent() throws IOException {
        String manifestContent = readManifest();
        
        // Check for AdMob application ID meta-data
        assertTrue(
            "AdMob Application ID meta-data must be present in AndroidManifest.xml. " +
            "Add: <meta-data android:name=\"com.google.android.gms.ads.APPLICATION_ID\" android:value=\"${adMobAppId}\"/>",
            manifestContent.contains("com.google.android.gms.ads.APPLICATION_ID")
        );
        
        // Verify it's not commented out
        assertFalse(
            "AdMob Application ID must not be commented out in AndroidManifest.xml",
            manifestContent.contains("<!-- <meta-data") && 
            manifestContent.contains("com.google.android.gms.ads.APPLICATION_ID")
        );
    }

    /**
     * Test 2: Verify Advertising ID permission for Android 13+ compliance
     * Failure cause: Google Play rejects apps targeting Android 13+ without this declaration
     */
    @Test
    public void testAdvertisingIdPermissionPresent() throws IOException {
        String manifestContent = readManifest();
        
        assertTrue(
            "Advertising ID permission must be present for Android 13+ compliance. " +
            "Add: <uses-permission android:name=\"com.google.android.gms.permission.AD_ID\"/>",
            manifestContent.contains("com.google.android.gms.permission.AD_ID")
        );
    }

    /**
     * Test 3: Verify Billing permission for in-app purchases
     * Failure cause: Google Play Console won't allow IAP products without this permission
     */
    @Test
    public void testBillingPermissionPresent() throws IOException {
        String manifestContent = readManifest();
        
        assertTrue(
            "Billing permission must be present for in-app purchases. " +
            "Add: <uses-permission android:name=\"com.android.vending.BILLING\"/>",
            manifestContent.contains("com.android.vending.BILLING")
        );
    }

    /**
     * Test 4: Verify Internet permission for AdMob and currency API
     * Failure cause: App will crash when trying to load ads or currency rates
     */
    @Test
    public void testInternetPermissionPresent() throws IOException {
        String manifestContent = readManifest();
        
        assertTrue(
            "Internet permission must be present for AdMob and currency API. " +
            "Add: <uses-permission android:name=\"android.permission.INTERNET\"/>",
            manifestContent.contains("android.permission.INTERNET")
        );
    }

    /**
     * Test 5: Verify MainActivity is exported
     * Failure cause: App won't be launchable
     */
    @Test
    public void testMainActivityExported() throws IOException {
        String manifestContent = readManifest();
        
        assertTrue(
            "MainActivity must be exported to be launchable. " +
            "Add: android:exported=\"true\" to MainActivity",
            manifestContent.contains("android:name=\".MainActivity\"") &&
            manifestContent.contains("android:exported=\"true\"")
        );
    }

    /**
     * Test 6: Verify network security config is present
     * Failure cause: AdMob and currency API calls will fail on Android 9+
     */
    @Test
    public void testNetworkSecurityConfigPresent() throws IOException {
        String manifestContent = readManifest();
        
        assertTrue(
            "Network security config must be present for AdMob and currency API on Android 9+. " +
            "Add: android:networkSecurityConfig=\"@xml/network_security_config\" to application tag",
            manifestContent.contains("android:networkSecurityConfig")
        );
    }

    /**
     * Test 7: Verify usesCleartextTraffic is set to false
     * Failure cause: Security best practice, Google Play may reject insecure apps
     */
    @Test
    public void testCleartextTrafficDisabled() throws IOException {
        String manifestContent = readManifest();
        
        assertTrue(
            "usesCleartextTraffic should be set to false for security. " +
            "Add: android:usesCleartextTraffic=\"false\" to application tag",
            manifestContent.contains("android:usesCleartextTraffic=\"false\"")
        );
    }

    /**
     * Test 8: Verify widget provider is exported
     * Failure cause: Home screen widgets won't work
     */
    @Test
    public void testWidgetProviderExported() throws IOException {
        String manifestContent = readManifest();
        
        assertTrue(
            "Widget provider must be exported for home screen widgets to work. " +
            "Add: android:exported=\"true\" to widget provider",
            manifestContent.contains("UnitConverterWidgetProvider") &&
            manifestContent.contains("android:exported=\"true\"")
        );
    }

    /**
     * Test 9: Verify application label is set
     * Failure cause: App will show package name instead of app name
     */
    @Test
    public void testApplicationLabelPresent() throws IOException {
        String manifestContent = readManifest();
        
        assertTrue(
            "Application label must be set. " +
            "Add: android:label=\"Unit Converter\" to application tag",
            manifestContent.contains("android:label=\"") &&
            manifestContent.contains("Unit Converter")
        );
    }

    /**
     * Test 10: Verify application icon is set
     * Failure cause: App will use default Android icon
     */
    @Test
    public void testApplicationIconPresent() throws IOException {
        String manifestContent = readManifest();
        
        assertTrue(
            "Application icon must be set. " +
            "Add: android:icon=\"@mipmap/ic_launcher\" to application tag",
            manifestContent.contains("android:icon=\"@mipmap/ic_launcher\"")
        );
    }

    /**
     * Helper method to read the AndroidManifest.xml file
     */
    private String readManifest() throws IOException {
        StringBuilder content = new StringBuilder();
        File manifestFile = new File(MANIFEST_PATH);
        
        if (!manifestFile.exists()) {
            throw new IOException("AndroidManifest.xml not found at: " + MANIFEST_PATH);
        }
        
        try (BufferedReader reader = new BufferedReader(new FileReader(manifestFile))) {
            String line;
            while ((line = reader.readLine()) != null) {
                content.append(line).append("\n");
            }
        }
        
        return content.toString();
    }
}
