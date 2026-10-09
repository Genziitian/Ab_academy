import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// Upload keystore. `android/key.properties` is gitignored; see
// docs/RELEASE.md for how to generate it. Without the file the release build
// stays unsigned rather than silently falling back to the debug key, which
// Play rejects on upload.
val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
val hasKeystore = keystorePropertiesFile.exists()
if (hasKeystore) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

android {
    namespace = "com.akhandbharat.akhand_bharat_academy"
    compileSdk = flutter.compileSdkVersion
    // path_provider_android, pdfrx and url_launcher_android all require 27;
    // NDK versions are backward compatible, so take the highest.
    ndkVersion = "27.0.12077973"

    compileOptions {
        // flutter_local_notifications uses java.time, which needs desugaring
        // to run on the API 23 floor this app targets.
        isCoreLibraryDesugaringEnabled = true
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "in.akhandbharatacademy.app"
        // Supabase Auth's PKCE flow and firebase_messaging both need 21+;
        // 23 is the floor for the Play Integrity defaults.
        minSdk = 23
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName

        // The Google sign-in deep link (in.akhandbharatacademy.app://login-callback).
        manifestPlaceholders["appAuthRedirectScheme"] = "in.akhandbharatacademy.app"
    }

    signingConfigs {
        if (hasKeystore) {
            create("release") {
                keyAlias = keystoreProperties["keyAlias"] as String
                keyPassword = keystoreProperties["keyPassword"] as String
                storeFile = file(keystoreProperties["storeFile"] as String)
                storePassword = keystoreProperties["storePassword"] as String
            }
        }
    }

    buildTypes {
        release {
            // Falls back to unsigned, never to the debug key: a debug-signed
            // bundle is rejected at upload, and failing loudly here is better
            // than discovering it in the Play Console.
            signingConfig = if (hasKeystore) {
                signingConfigs.getByName("release")
            } else {
                null
            }

            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro",
            )
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}

// pdfrx ships a ~4 MB PDFium WASM module for Flutter Web. Android plays PDFs
// through libpdfium.so, so the .wasm is dead weight in every install.
//
// Neither packaging{} nor androidResources.ignoreAssetsPatterns reaches it:
// the Flutter Gradle plugin copies flutter_assets into the merged assets
// directory after both of those filters have run. Deleting it immediately
// after that copy task is the one hook that lands.
tasks.matching { it.name.matches(Regex("copyFlutterAssets(Release|Profile)")) }
    .configureEach {
        doLast {
            val removed = layout.buildDirectory.get().asFile
                .walkTopDown()
                .filter { it.name == "pdfium.wasm" }
                .onEach { it.delete() }
                .count()
            if (removed > 0) {
                logger.lifecycle("Stripped $removed web-only pdfium.wasm from release assets")
            }
        }
    }
