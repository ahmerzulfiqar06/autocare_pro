plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android plugin.
    id("dev.flutter.flutter-gradle-plugin")
    id("org.jetbrains.kotlin.android")
    id("com.google.gms.google-services")
}

android {
    namespace = "com.example.autocare_pro"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
         isCoreLibraryDesugaringEnabled = true
    }
kotlinOptions {
        jvmTarget = "17"
    }
    sourceSets {
        main.java.srcDirs += 'src/main/java'
    }

dependencies {
  // Import the Firebase BoM
  implementation(platform("com.google.firebase:firebase-bom:34.3.0"))


  // TODO: Add the dependencies for Firebase products you want to use
  // When using the BoM, don't specify versions in Firebase dependencies
  implementation("com.google.firebase:firebase-analytics")
coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.4")

  // Add the dependencies for any other desired Firebase products
  // https://firebase.google.com/docs/android/setup#available-libraries
}

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.example.autocare_pro"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}
