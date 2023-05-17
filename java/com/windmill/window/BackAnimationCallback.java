package com.windmill.window;

import android.window.BackEvent;

public class BackAnimationCallback implements android.window.OnBackAnimationCallback {

    @Override
    public void onBackCancelled() {
        //do nothing, lua will override it
    }

    @Override
    public void onBackInvoked() {
        //do nothing, lua will override it
    }

    @Override
    public void onBackProgressed(BackEvent backEvent) {
        //do nothing, lua will override it
    }

    @Override
    public void onBackStarted(BackEvent backEvent) {
        //do nothing, lua will override it
    }

}
