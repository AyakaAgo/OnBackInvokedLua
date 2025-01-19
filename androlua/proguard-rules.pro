-optimizationpasses 7
-dontusemixedcaseclassnames

-keep class com.android.cglib.** {
    *;
}

-keep class android.widget.ArrayListAdapter {
    *;
}
-keep class android.widget.ArrayPageAdapter {
    *;
}

-keep class com.androlua.** {
    *;
}
-keep class com.luajava.** {
    *;
}
-keepclasseswithmembernames class ** {
    native <methods>;
}
