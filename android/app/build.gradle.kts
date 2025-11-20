plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.cycla"  // Змініть на ваш package
    compileSdk = 36  // Оновлено до 36

    compileOptions {
        isCoreLibraryDesugaringEnabled = true
        sourceCompatibility = JavaVersion.VERSION_21  // Оновлено до 17
        targetCompatibility = JavaVersion.VERSION_21  // Оновлено до 17
    }

    kotlinOptions {
        jvmTarget = "21"  // Оновлено до 17
    }

    defaultConfig {
        applicationId = "com.example.cycla"  // Змініть на ваш package
        minSdk = flutter.minSdkVersion
        targetSdk = 36  // Оновлено до 36
        versionCode = 1
        versionName = "1.0.0"
        multiDexEnabled = true
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.4")
}
