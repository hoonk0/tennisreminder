# Naver Login SDK 관련 Proguard 설정 (릴리즈 모드 오류 방지용)
-keep class com.naver.** { *; }
-keep interface com.naver.** { *; }
-keepclassmembers class com.naver.** { *; }

-keep class com.navercorp.** { *; }
-keep interface com.navercorp.** { *; }
-keepclassmembers class com.navercorp.** { *; }

# Gson, Json 파싱 관련 설정
-keep class com.google.gson.** { *; }
-keep class org.json.** { *; }

# OkHttp 및 Retrofit 관련 설정
-keep class okhttp3.** { *; }
-dontwarn okhttp3.**
-keep class retrofit2.** { *; }
-dontwarn retrofit2.**

# 제네릭 타입 리플렉션 오류 방지를 위한 추가 설정
-keepattributes Exceptions, InnerClasses, Signature, Deprecated, SourceFile, LineNumberTable, *Annotation*
-keep class kotlin.Metadata { *; }
-keep class * implements java.lang.reflect.Type

# Kotlin 관련 클래스 보존
-keepclassmembers class ** {
    ** MODULE$;
}
-dontwarn kotlin.**
-keep class kotlin.** { *; }

# Enum 타입 관련 리플렉션 문제 방지
-keepclassmembers enum * {
    public static **[] values();
    public static ** valueOf(java.lang.String);
}