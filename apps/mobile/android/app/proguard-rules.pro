# Flutter's own rules come from the Flutter Gradle plugin; these cover the
# plugins R8 cannot see through.

# Firebase Messaging reflects over its service classes.
-keep class com.google.firebase.** { *; }
-dontwarn com.google.firebase.**

# pdfrx loads PDFium through JNI.
-keep class org.pdfrx.** { *; }
-dontwarn org.pdfrx.**

# Play Core is referenced by Flutter's deferred-components support, which this
# app does not use; without this R8 fails on the missing classes.
-dontwarn com.google.android.play.core.**

# Google sign-in goes through Credential Manager, which finds its Play
# Services provider by reflection; keep it or R8 strips it from release builds.
-if class androidx.credentials.CredentialManager
-keep class androidx.credentials.playservices.** { *; }
