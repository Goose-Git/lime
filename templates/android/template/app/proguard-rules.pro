# Shared Lime/HXCPP JNI bridge: native code looks up Java names directly.
-keep class org.haxe.lime.** { *; }
-keep class org.haxe.HXCPP { *; }
-keep class org.haxe.extension.** { *; }

# SDL Android callbacks used by native window, audio and input code.
-keep class org.libsdl.app.** { *; }

# Shared fallback for games using different Haxe extensions.
# Extensions outside this namespace need their own consumer keep rules.
# This can be narrowed as extensions supply consumerProguardFiles.
-keep class extension.** { *; }
