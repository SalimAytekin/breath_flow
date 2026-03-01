-keep class io.flutter.embedding.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class androidx.** { *; }
-dontwarn androidx.**

-keep class com.google.firebase.** { *; }
-dontwarn com.google.firebase.**
-keep class com.google.android.gms.** { *; }
-dontwarn com.google.android.gms.**

-keep class kotlin.** { *; }
-dontwarn kotlin.**

-dontwarn okio.**
-dontwarn okhttp3.**

# Google Mobile Ads
-keep class com.google.android.gms.ads.** { *; }
-dontwarn com.google.android.gms.ads.**

# AdMob Mediation
-keep class com.google.ads.mediation.** { *; }
-dontwarn com.google.ads.mediation.**

# Firebase Analytics
-keep class com.google.firebase.analytics.** { *; }
-dontwarn com.google.firebase.analytics.**

# Firebase Crashlytics
-keep class com.google.firebase.crashlytics.** { *; }
-dontwarn com.google.firebase.crashlytics.**

# Firebase Remote Config
-keep class com.google.firebase.remoteconfig.** { *; }
-dontwarn com.google.firebase.remoteconfig.**

# AdMob SDK
-keep class com.google.android.gms.ads.identifier.** { *; }
-keep class com.google.android.gms.ads.AdRequest { *; }
-keep class com.google.android.gms.ads.AdSize { *; }
-keep class com.google.android.gms.ads.AdView { *; }
-keep class com.google.android.gms.ads.InterstitialAd { *; }
-keep class com.google.android.gms.ads.RewardedAd { *; }
-keep class com.google.android.gms.ads.MobileAds { *; }

# Keep our ad classes
-keep class breathe_flow.core.ads.** { *; }
-keep class breathe_flow.ui.components.AdContainer { *; }

# Google Play Core (deferred components)
-keep class com.google.android.play.core.** { *; }
-dontwarn com.google.android.play.core.**
