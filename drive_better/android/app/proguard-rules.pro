# Isar Proguard Rules
-keep class io.isar.** { *; }
-keep class * implements io.isar.IsarCollection { *; }
-keep class * implements io.isar.IsarEmbedded { *; }
-dontwarn io.isar.**

# ML Kit Text Recognition
-dontwarn com.google.mlkit.vision.text.**
-dontwarn com.google.android.gms.internal.ml.**
