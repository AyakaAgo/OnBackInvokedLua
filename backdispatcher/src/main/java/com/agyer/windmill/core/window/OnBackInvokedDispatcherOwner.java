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

import androidx.annotation.CallSuper;
import androidx.annotation.EmptySuper;
import androidx.annotation.NonNull;
import androidx.annotation.RequiresApi;

/**
 * interface for {@link android.window.OnBackInvokedDispatcher} owner
 */
public interface OnBackInvokedDispatcherOwner {
    /**
     * <strong>DO NOT<strong> call this method directly, call {@link #goBack()} for proper behaviour
     *
     * @see OnBackInvokedDispatcher#dispatchOnBackInvoked()
     * @see #goBack()
     * @implNote you <strong>MUST</strong> write a way to exit due to {@link #goBack()}
     */
    void onBackInvoked();

    /**
     * callback received when {@link OnBackInvokedDispatcher#setAlwaysHoldCallback(boolean)}
     * is set to true
     */
    @EmptySuper
    @RequiresApi(api = Build.VERSION_CODES.UPSIDE_DOWN_CAKE)
    default void onBackStarted(@NonNull CompatBackEvent backEvent) {}

    /**
     * callback received when {@link OnBackInvokedDispatcher#setAlwaysHoldCallback(boolean)}
     * is set to true
     */
    @EmptySuper
    @RequiresApi(api = Build.VERSION_CODES.UPSIDE_DOWN_CAKE)
    default void onBackProgressed(@NonNull CompatBackEvent backEvent) {}

    /**
     * callback received when {@link OnBackInvokedDispatcher#setAlwaysHoldCallback(boolean)}
     * is set to true
     */
    @EmptySuper
    @RequiresApi(api = Build.VERSION_CODES.UPSIDE_DOWN_CAKE)
    default void onBackCancelled() {}

    @CallSuper
    default boolean goBack() {
        return getCompatOnBackInvokedDispatcher().dispatchOnBackInvoked();
    }

    @CallSuper
    default void registerOnBackInvokedCallback(@OnBackInvokedDispatcher.Priority int priority, @NonNull OnBackInvokedCallback callback) {
        getCompatOnBackInvokedDispatcher().addCallback(priority, callback);
    }

    @CallSuper
    default int registerOnBackInvokedCallback(@NonNull OnBackInvokedCallback callback) {
        return getCompatOnBackInvokedDispatcher().addCallback(callback);
    }

    @CallSuper
    default void unregisterOnBackInvokedCallback(@NonNull OnBackInvokedCallback callback) {
        getCompatOnBackInvokedDispatcher().removeCallback(callback);
    }

    @CallSuper
    default void unregisterOnBackInvokedCallback(@OnBackInvokedDispatcher.Priority int priority) {
        getCompatOnBackInvokedDispatcher().removeCallback(priority);
    }

    /**
     * @return OnBackInvokedDispatcher the system dispatcher
     * @implNote do not override this method if this is a {@link android.app.Activity},
     * {@link android.app.Dialog} or {@link android.view.Window}
     */
    @RequiresApi(Build.VERSION_CODES.TIRAMISU)
    @NonNull
    android.window.OnBackInvokedDispatcher getOnBackInvokedDispatcher();

    @NonNull
    OnBackInvokedDispatcher getCompatOnBackInvokedDispatcher();

}
