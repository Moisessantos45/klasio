# ==============================================================================
# PROGUARD / R8 RULES - KLASIO APP
# ==============================================================================

# --- Flutter Engine & Core Plugins ---
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
-dontwarn io.flutter.embedding.**
-dontwarn io.flutter.**

# --- App Native Classes & Method Channels (com.example.klasio) ---
-keep class com.example.klasio.** { *; }
-keepclassmembers class com.example.klasio.** { *; }
-keep class com.example.klasio.UpdateInfo** { *; }

# --- Kotlin & Kotlin Coroutines ---
-keepattributes *Annotation*,Signature,InnerClasses,EnclosingMethod,SourceFile,LineNumberTable
-keepclassmembers class * extends kotlin.jvm.internal.Lambda {
    <fields>;
    <methods>;
}
-keepnames class kotlinx.coroutines.internal.MainDispatcherFactory {}
-keepnames class kotlinx.coroutines.CoroutineExceptionHandler {}
-keepclassmembernames class kotlinx.** {
    volatile <fields>;
}
-dontwarn kotlinx.coroutines.**
-dontwarn kotlin.**

# --- Google ML Kit & Google Play Services Vision ---
-keep class com.google.mlkit.** { *; }
-keep class com.google.android.gms.vision.** { *; }
-keep class com.google.android.gms.tasks.** { *; }
-keep class com.google.android.gms.common.** { *; }
-dontwarn com.google.mlkit.**
-dontwarn com.google.android.gms.**

# --- JakeWharton ProcessPhoenix ---
-keep class com.jakewharton.processphoenix.** { *; }
-dontwarn com.jakewharton.processphoenix.**

# --- Sqflite (SQLite Plugin) ---
-keep class com.tekartik.sqflite.** { *; }
-dontwarn com.tekartik.sqflite.**

# --- Image Picker & AndroidX Support ---
-keep class io.flutter.plugins.imagepicker.** { *; }
-keep class androidx.core.** { *; }
-keep class androidx.documentfile.** { *; }
-keep class com.google.android.material.** { *; }
-dontwarn androidx.**
-dontwarn com.google.android.material.**

# --- General Optimizations & Warnings ---
-dontwarn java.lang.invoke.**
-dontnote **
