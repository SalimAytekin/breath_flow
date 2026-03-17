plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.google.mlkit.vision.demo"
    compileSdk = 35
    // Using NDK version required by plugins
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = "17"
    }
    
    // Compose support eklendi
    buildFeatures {
        compose = true
    }
    
    composeOptions {
        kotlinCompilerExtensionVersion = "1.4.8"
    }
    
    // Do NOT compress tflite model files
    aaptOptions {
        noCompress("tflite")
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.google.mlkit.vision.demo"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = 21 // MLKit Vision en düşük 21 API seviyesini gerektiriyor
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        multiDexEnabled = true
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

dependencies {
    // Compose BOM - sürüm uyumluluğu için
    implementation(platform("androidx.compose:compose-bom:2024.02.00"))
    
    // Compose UI kütüphaneleri
    implementation("androidx.compose.ui:ui")
    implementation("androidx.compose.ui:ui-graphics")
    implementation("androidx.compose.ui:ui-tooling-preview")
    implementation("androidx.compose.material3:material3")
    implementation("androidx.activity:activity-compose:1.8.2")
    implementation("androidx.compose.material:material-icons-core")
    implementation("androidx.compose.material:material-icons-extended")
    
    // MLKit Vision bağımlılıkları - orijinal proje ile tam uyumlu olması için güncellendi
    implementation("com.google.mlkit:pose-detection:18.0.0-beta5")
    implementation("com.google.mlkit:pose-detection-accurate:18.0.0-beta5")
    implementation("com.google.mlkit:camera:16.0.0-beta3")
    
    // CameraX bağımlılıkları - stabil sürümlerle değiştiriyoruz
    implementation("androidx.camera:camera-camera2:1.3.1")
    implementation("androidx.camera:camera-lifecycle:1.3.1")
    implementation("androidx.camera:camera-view:1.3.1")
    
    // Temel Android bağımlılıkları
    implementation("com.google.code.gson:gson:2.8.6")
    implementation("com.google.guava:guava:27.1-android")
    implementation("androidx.appcompat:appcompat:1.2.0")
    implementation("androidx.annotation:annotation:1.2.0")
    implementation("androidx.constraintlayout:constraintlayout:2.0.4")
    
    // On Device Machine Learning
    implementation("com.google.android.odml:image:1.0.0-beta1")
    
    // ViewModel ve LiveData
    implementation("androidx.lifecycle:lifecycle-livedata:2.3.1")
    implementation("androidx.lifecycle:lifecycle-viewmodel:2.3.1")
    
    // MultiDex desteği
    implementation("androidx.multidex:multidex:2.0.1")
    
    // Flutter eklentileriyle çakışmaları önlemek için
    configurations.all {
        exclude(group = "com.google.guava", module = "listenablefuture")
    }
}
