# Add project specific ProGuard rules here.
# You can control the set of applied configuration files using the
# proguardFiles setting in build.gradle.
#
# For more details, see
#   http://developer.android.com/guide/developing/tools/proguard.html

# If your project uses WebView with JS, uncomment the following
# and specify the fully qualified class name to the JavaScript interface
# class:
#-keepclassmembers class fqcn.of.javascript.interface.for.webview {
#   public *;
#}

# Uncomment this to preserve the line number information for
# debugging stack traces.
#-keepattributes SourceFile,LineNumberTable

# If you keep the line number information, uncomment this to
# hide the original source file name.
#-renamesourcefileattribute SourceFile

-keep class com.agyer.windmill.core.window.CompatBackEvent {
    public static final <fields>;
    public *** get*();
}

-keep class com.agyer.windmill.core.window.OnBackInvokedDispatcherOwner {
    # basic usecase methods
    public boolean goBack();
    public int registerOnBackInvokedCallback(com.agyer.windmill.core.window.OnBackInvokedCallback);
    public void registerOnBackInvokedCallback(int, com.agyer.windmill.core.window.OnBackInvokedCallback);
    public void unregisterOnBackInvokedCallback(***);

    #public com.agyer.windmill.core.window.OnBackInvokedDispatcher getCompatOnBackInvokedDispatcher();
}

-keep class com.agyer.windmill.core.window.OnBackInvokedDispatcher {
    # basic usecase methods
    public static final <fields>;
    public static boolean isAnimationCallbackSupported();

    #public void removeCallback(int);
    #public void removeCallback(com.agyer.windmill.core.window.OnBackInvokedCallback);
    #public void addCallback(int, com.agyer.windmill.core.window.OnBackInvokedCallback);
    #public int addCallback(com.agyer.windmill.core.window.OnBackInvokedCallback);
    #public int nextPriority();
    #public static boolean isSystemCallbackSupported();
}

-keep class com.agyer.windmill.core.window.lua.LuaOnBackInvokedCallback {
    *;
}
