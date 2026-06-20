# Gson specific rules for flutter_local_notifications
-keepattributes InnerClasses
-keepattributes Signature
-keepattributes *Annotation*

# Keep Gson classes
-dontwarn sun.misc.**
-keep class * extends com.google.gson.TypeAdapter
-keep class * implements com.google.gson.TypeAdapterFactory
-keep class * implements com.google.gson.JsonSerializer
-keep class * implements com.google.gson.JsonDeserializer

# Prevent R8 from stripping necessary information from the plugin
-keep class com.dexterous.** { *; }

# Keep SerializedName for data objects
-keepclassmembers,allowobfuscation class * {
    @com.google.gson.annotations.SerializedName <fields>;
}
