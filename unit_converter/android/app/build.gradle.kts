import java.util.Properties
import java.io.FileInputStream
import java.io.File

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// Load keystore properties from key.properties file
val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

fun loadDotEnv(file: File): Map<String, String> {
    if (!file.exists()) {
        return emptyMap()
    }

    return file.readLines()
        .map { it.trim() }
        .filter { it.isNotEmpty() && !it.startsWith("#") && it.contains("=") }
        .associate { line ->
            val separatorIndex = line.indexOf('=')
            val key = line.substring(0, separatorIndex).trim()
            var value = line.substring(separatorIndex + 1).trim()

            if ((value.startsWith('"') && value.endsWith('"')) ||
                (value.startsWith('\'') && value.endsWith('\''))) {
                value = value.substring(1, value.length - 1)
            }

            key to value
        }
}

val debugAdMobAppId = "ca-app-pub-3940256099942544~3347511713"
val dotEnv = loadDotEnv(rootProject.file("../.env"))
val releaseAdMobAppId = dotEnv["UNIT_CONVERTER_ADMOB_APP_ID"]
    ?: providers.environmentVariable("UNIT_CONVERTER_ADMOB_APP_ID").orNull
    ?: debugAdMobAppId

android {
    namespace = "com.unitconverter.unit_converter"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = "17"
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.unitconverter.unit_converter"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    // Configure signing for release builds
    signingConfigs {
        create("release") {
            // Use key.properties if it exists, otherwise use debug signing
            if (keystorePropertiesFile.exists()) {
                storeFile = file(keystoreProperties.getProperty("storeFile"))
                storePassword = keystoreProperties.getProperty("storePassword")
                keyAlias = keystoreProperties.getProperty("keyAlias")
                keyPassword = keystoreProperties.getProperty("keyPassword")
            }
        }
    }

    lint {
        disable.add("LintError")
        checkReleaseBuilds = false
        abortOnError = false
    }

    buildTypes {
        getByName("debug") {
            manifestPlaceholders["adMobAppId"] = debugAdMobAppId
        }

        getByName("release") {
            manifestPlaceholders["adMobAppId"] = releaseAdMobAppId

            // Use production signing if key.properties exists, otherwise use debug signing
            // WARNING: Debug signing is NOT SECURE for production!
            signingConfig = if (keystorePropertiesFile.exists() && keystoreProperties.getProperty("storeFile") != null) {
                signingConfigs.getByName("release")
            } else {
                signingConfigs.getByName("debug")
            }

            // Enable code shrinking and minification
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }
}

flutter {
    source = "../.."
}
