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
package com.agyer.windmill.core.window;

import android.os.Build;

import androidx.annotation.EmptySuper;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.annotation.RequiresApi;

public abstract class OnBackInvokedCallback {
    private boolean enabled;
    @Nullable
    private OnBackInvokedDispatcher dispatcher;

    //@Keep
    public OnBackInvokedCallback(boolean enabled) {
        setEnabledInternal(enabled);
    }

    //@Keep
    public OnBackInvokedCallback() {
        this(true);
    }

    protected final void setDispatcher(@Nullable OnBackInvokedDispatcher dispatcher) /*throws IllegalStateException*/ {
        if (!(dispatcher == null || this.dispatcher == null)) {
            throw new IllegalArgumentException("back callback should only register with one dispatcher.");
        }
        this.dispatcher = dispatcher;
    }

    public final void remove() {
        if (dispatcher != null) {
            dispatcher.removeCallback(this);
        }
    }

    public final boolean isEnabled() {
        return this.enabled;
    }

    private void setEnabledInternal(boolean enabled) {
        this.enabled = enabled;
    }

    /**
     * Enable or disable the callback without removing. Use this method for
     * callbacks that need to be registered/unregistered frequently.
     *
     * @see #remove()
     * @see OnBackInvokedDispatcher#removeCallback(OnBackInvokedCallback)
     */
    public final void setEnabled(boolean enabled) {
        if (this.enabled != enabled) {
            setEnabledInternal(enabled);

            if (dispatcher != null) {
                dispatcher.checkInternalCallback();
            }
        }
    }

    public abstract void onBackInvoked();

    @EmptySuper
    //@RequiresApi(Build.VERSION_CODES.UPSIDE_DOWN_CAKE)
    public void onBackStarted(@NonNull CompatBackEvent backEvent) {

    }

    @EmptySuper
    @RequiresApi(Build.VERSION_CODES.UPSIDE_DOWN_CAKE)
    public void onBackProgressed(@NonNull CompatBackEvent backEvent) {

    }

    @EmptySuper
    //@RequiresApi(Build.VERSION_CODES.UPSIDE_DOWN_CAKE)
    public void onBackCancelled() {

    }

}
