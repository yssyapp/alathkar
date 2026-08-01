pluginManagement {
    val flutterSdkPath =
        run {
            val properties = java.util.Properties()
            file("local.properties").inputStream().use { properties.load(it) }
            val flutterSdkPath = properties.getProperty("flutter.sdk")
            require(flutterSdkPath != null) { "flutter.sdk not set in local.properties" }
            flutterSdkPath
        }

    includeBuild("$flutterSdkPath/packages/flutter_tools/gradle")

    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
}

plugins {
    id("dev.flutter.flutter-plugin-loader") version "1.0.0"
    // AGP 9+ يستخدم DSL جديد لا يدعمه Flutter Gradle Plugin الحالي بعد
    // ("only the new DSL interface will be read"). لكن أيضاً بعض مكتبات
    // androidx الحديثة (browser 1.9.0, core-ktx 1.18.0) تتطلب AGP 8.9.1
    // فأعلى — فنستقر عند 8.9.1: أعلى إصدار مستقر يرضي الاثنين معاً.
    id("com.android.application") version "8.9.1" apply false
    id("org.jetbrains.kotlin.android") version "2.2.20" apply false
}

include(":app")
