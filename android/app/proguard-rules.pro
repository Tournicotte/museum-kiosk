# SumUp Android SDK — keep all public API classes
-keep class com.sumup.** { *; }
-keep interface com.sumup.** { *; }
-keepnames class com.sumup.** { *; }
-dontwarn com.sumup.**

# Kotlin runtime
-keep class kotlin.** { *; }
-keep class kotlinx.** { *; }
-dontwarn kotlin.**
-dontwarn kotlinx.**

# Flutter embedding
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
-dontwarn io.flutter.**

# Drift / SQLite — preserve generated query classes
-keep class ** extends androidx.sqlite.db.SupportSQLiteOpenHelper { *; }
-dontwarn org.sqlite.**
