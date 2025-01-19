/*
 * Copyright 2024 The Windmill Open Source Project
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
package com.agyer.windmill.core.window.lua;

import com.agyer.windmill.core.window.OnBackAnimationCallback;

public abstract class LuaOnBackInvokedCallback extends OnBackAnimationCallback {
    public LuaOnBackInvokedCallback() {
    }

    public LuaOnBackInvokedCallback(boolean enabled) {
        super(enabled);
    }

    @Override
    public final void onBackInvoked() {
        onBackInvoked(this);
    }

    /*@RequiresApi(api = Build.VERSION_CODES.UPSIDE_DOWN_CAKE)
    @Override
    public final void onBackCancelled() {
        onBackCancelled(this);
    }

    @RequiresApi(api = Build.VERSION_CODES.UPSIDE_DOWN_CAKE)
    @Override
    public final void onBackProgressed(@NonNull CompatBackEvent backEvent) {
        onBackProgressed(this, backEvent);
    }

    @RequiresApi(api = Build.VERSION_CODES.UPSIDE_DOWN_CAKE)
    @Override
    public final void onBackStarted(@NonNull CompatBackEvent backEvent) {
        onBackStarted(this, backEvent);
    }*/

    // ---------------- lua override methods -----------------

    // added callback parameter for removal
    public abstract void onBackInvoked(LuaOnBackInvokedCallback callback);

    /*@EmptySuper
    public void onBackProgressed(LuaOnBackInvokedCallback callback, CompatBackEvent backEventCompat) {

    }

    @EmptySuper
    public void onBackStarted(LuaOnBackInvokedCallback callback, CompatBackEvent backEventCompat) {

    }

    @EmptySuper
    public void onBackCancelled(LuaOnBackInvokedCallback callback) {

    }*/

}
