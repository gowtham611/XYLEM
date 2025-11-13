# Add project specific ProGuard rules here.
# You can control the set of applied configuration files using the
# proguardFiles setting in build.gradle.

# Flutter Wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# ✅ TensorFlow Lite - Keep all classes
-keep class org.tensorflow.lite.** { *; }
-keep class org.tensorflow.lite.gpu.** { *; }
-keep class org.tensorflow.lite.nnapi.** { *; }
-keep class org.tensorflow.lite.delegates.** { *; }
-keep interface org.tensorflow.lite.** { *; }

# ✅ TensorFlow Lite GPU Delegate - Critical for your plant disease detection
-keep class org.tensorflow.lite.gpu.GpuDelegate { *; }
-keep class org.tensorflow.lite.gpu.GpuDelegateFactory { *; }
-keep class org.tensorflow.lite.gpu.GpuDelegateFactory$Options { *; }
-keep class org.tensorflow.lite.gpu.GpuDelegateFactory$Options$GpuBackend { *; }
-keep class org.tensorflow.lite.gpu.CompatibilityList { *; }

# ✅ TensorFlow Lite Support Libraries
-keep class org.tensorflow.lite.support.** { *; }
-keep class org.tensorflow.lite.task.** { *; }
-keep class org.tensorflow.lite.support.image.** { *; }
-keep class org.tensorflow.lite.support.label.** { *; }

# ✅ Flatbuffers (used by TensorFlow Lite)
-keep class com.google.flatbuffers.** { *; }

# ✅ Native methods - Critical for TensorFlow Lite JNI
-keepclasseswithmembernames class * {
    native <methods>;
}

# ✅ Speech to Text (for voice assistant)
-keep class com.google.android.gms.** { *; }
-keep class org.vosk.** { *; }
-keep class speech_to_text.** { *; }

# ✅ Flutter TTS (for voice assistant)
-keep class com.tundralabs.fluttertts.** { *; }

# ✅ Image Picker (for plant photo capture)
-keep class io.flutter.plugins.imagepicker.** { *; }
-keep class io.flutter.plugins.pathprovider.** { *; }

# ✅ Camera Plugin
-keep class io.flutter.plugins.camera.** { *; }

# ✅ Permission Handler
-keep class com.baseflow.permissionhandler.** { *; }

# ✅ HTTP and Network
-keep class io.flutter.plugins.connectivity.** { *; }
-keep class okhttp3.** { *; }
-keep class retrofit2.** { *; }

# ✅ ONNX Runtime (for sensor predictions)
-keep class ai.onnxruntime.** { *; }
-keep class microsoft.** { *; }

# ✅ Location Services
-keep class com.baseflow.geolocator.** { *; }

# ✅ Keep annotations and signatures
-keepattributes *Annotation*
-keepattributes Signature
-keepattributes Exceptions
-keepattributes InnerClasses
-keepattributes EnclosingMethod

# ✅ Suppress warnings for optional dependencies
-dontwarn org.tensorflow.lite.gpu.**
-dontwarn org.tensorflow.**
-dontwarn com.google.**
-dontwarn java.lang.invoke.**
-dontwarn javax.annotation.**

# ✅ Keep Kotlin metadata
-keep class kotlin.Metadata { *; }
-keepclassmembers class **$WhenMappings {
    <fields>;
}

# ✅ Keep enum classes
-keepclassmembers enum * {
    public static **[] values();
    public static ** valueOf(java.lang.String);
}

# ✅ Serialization
-keepclassmembers class * implements java.io.Serializable {
    static final long serialVersionUID;
    private static final java.io.ObjectStreamField[] serialPersistentFields;
    !static !transient <fields>;
    private void writeObject(java.io.ObjectOutputStream);
    private void readObject(java.io.ObjectInputStream);
    java.lang.Object writeReplace();
    java.lang.Object readResolve();
}

# ✅ Flutter specific rules
-keep class io.flutter.embedding.** { *; }
-keep class io.flutter.embedding.engine.** { *; }
-keep class io.flutter.embedding.android.** { *; }

# ✅ Dart VM
-keep class io.flutter.view.FlutterMain { *; }
-keep class io.flutter.util.** { *; }
