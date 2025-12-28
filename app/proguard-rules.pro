# Add project specific ProGuard rules here.
# You can control the set of applied configuration files using the
# proguardFiles setting in build.gradle.

# Keep native methods
-keepclasseswithmembernames class * {
    native <methods>;
}

# Keep MainActivity
-keep public class com.ctf.secureapp.MainActivity {
    public *;
}

# Obfuscate everything else
-repackageclasses 'o'
-allowaccessmodification
-overloadaggressively

# String encryption
-obfuscationdictionary proguard-dictionary.txt
-classobfuscationdictionary proguard-dictionary.txt
-packageobfuscationdictionary proguard-dictionary.txt

# Keep HiddenCheck but obfuscate its methods
-keep class com.ctf.secureapp.HiddenCheck {
    public *;
}

# Remove logging
-assumenosideeffects class android.util.Log {
    public static *** d(...);
    public static *** v(...);
    public static *** i(...);
}

# Optimization
-optimizationpasses 5
-optimizations !code/simplification/arithmetic,!code/simplification/cast,!field/*,!class/merging/*

# Keep line numbers for debugging (can be removed for extra obfuscation)
# -keepattributes SourceFile,LineNumberTable

# Rename fields and methods aggressively
-repackageclasses ''
-flattenpackagehierarchy ''
