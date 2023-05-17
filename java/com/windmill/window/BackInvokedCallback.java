package com.windmill.window;

public class BackInvokedCallback implements android.window.OnBackInvokedCallback {

    @Override
    public void onBackInvoked() {
        //do nothing, lua will override it
    }

}
