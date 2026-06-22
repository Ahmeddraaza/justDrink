# Flutter Local Notifications rules
-keep class com.dexterous.flutterlocalnotifications.** { *; }
-dontwarn com.dexterous.flutterlocalnotifications.**

# Gson TypeToken — CRITICAL: prevents "Missing type parameter" crash in release mode
# R8 strips generic type info from TypeToken subclasses without these rules
-keep class com.google.gson.** { *; }
-keep class com.google.gson.reflect.TypeToken { *; }
-keep class * extends com.google.gson.reflect.TypeToken
-keep public class * implements java.lang.reflect.Type

# Keep attributes needed for generic type reflection
-keepattributes Signature
-keepattributes InnerClasses
-keepattributes EnclosingMethod
-keepattributes *Annotation*

# Keep Widget Provider
-keep class com.hanotech.justdrinkapp.JustDrinkWidgetProvider { *; }
