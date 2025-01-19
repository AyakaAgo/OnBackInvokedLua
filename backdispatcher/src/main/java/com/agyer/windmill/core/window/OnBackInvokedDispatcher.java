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

import android.annotation.SuppressLint;
import android.content.Context;
import android.os.Build;
import android.util.Log;
import android.view.KeyEvent;
import android.window.BackEvent;
import android.window.OnBackAnimationCallback;

import androidx.annotation.CheckResult;
import androidx.annotation.ChecksSdkIntAtLeast;
import androidx.annotation.IntDef;
import androidx.annotation.IntRange;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.annotation.RequiresApi;

import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;
import java.lang.ref.WeakReference;
import java.util.HashMap;
import java.util.Map;

public final class OnBackInvokedDispatcher {
    /**
     * Priority level of {@link OnBackInvokedCallback}s for overlays such as menus and
     * navigation drawers that should receive back dispatch before non-overlays.
     */
    @SuppressLint("InlinedApi")
    public static final int PRIORITY_OVERLAY = android.window.OnBackInvokedDispatcher.PRIORITY_OVERLAY;
    /**
     * Default priority level of {@link OnBackInvokedCallback}s.
     */
    @SuppressLint("InlinedApi")
    public static final int PRIORITY_DEFAULT = android.window.OnBackInvokedDispatcher.PRIORITY_DEFAULT;
    /**
     * Priority level of {@link OnBackInvokedCallback}s designed to observe system-level back handling.
     * <p>
     * Callbacks registered with this priority do not consume back events. They receive back events whenever the system handles a back navigation and have no impact on the normal back navigation flow. Useful for logging or analytics.
     * <p>
     * Only one callback with this priority can be registered at a time.
     */
    // wait for 36 sdk
    @SuppressLint("InlinedApi")
    public static final int PRIORITY_SYSTEM_NAVIGATION_OBSERVER = android.window.OnBackInvokedDispatcher.PRIORITY_SYSTEM_NAVIGATION_OBSERVER;

    @NonNull
    private final Map<Integer, OnBackInvokedCallback> intCallbacks = new HashMap<>();

    @NonNull
    private final WeakReference<OnBackInvokedDispatcherOwner> owner;
    private boolean isInternalCallbackAlwaysHold;
    private boolean isInternalCallbackRegistered;

    @RequiresApi(api = Build.VERSION_CODES.TIRAMISU)
    private android.window.OnBackInvokedCallback internalCallback;
    @RequiresApi(api = Build.VERSION_CODES.TIRAMISU)
    private android.window.OnBackInvokedDispatcher internalDispatcher;

    @Retention(RetentionPolicy.SOURCE)
    @IntDef({PRIORITY_DEFAULT, PRIORITY_OVERLAY, PRIORITY_SYSTEM_NAVIGATION_OBSERVER})
    // only PRIORITY_SYSTEM_NAVIGATION_OBSERVER is valid
    @IntRange(from = PRIORITY_DEFAULT)
    public @interface Priority {}

    public OnBackInvokedDispatcher(@NonNull OnBackInvokedDispatcherOwner owner) {
        this.owner = new WeakReference<>(owner);
    }

    public OnBackInvokedDispatcher(@NonNull OnBackInvokedDispatcherOwner owner, boolean alwaysHoldCallback) {
        this(owner);

        setAlwaysHoldCallback(alwaysHoldCallback);
    }

    /**
     * when this returns true, {@link #isSystemCallbackSupported()} also true
     *
     * @return if {@link OnBackAnimationCallback} API is supported in this sdk level
     */
    @ChecksSdkIntAtLeast(api = Build.VERSION_CODES.UPSIDE_DOWN_CAKE)
    @CheckResult
    public static boolean isAnimationCallbackSupported() {
        return Build.VERSION.SDK_INT >= Build.VERSION_CODES.UPSIDE_DOWN_CAKE;
    }

    /**
     * @return if {@link android.window.OnBackInvokedCallback} API is supported,
     *         if false, use compat callback
     */
    @ChecksSdkIntAtLeast(api = Build.VERSION_CODES.TIRAMISU)
    @CheckResult
    public static boolean isSystemCallbackSupported() {
        return Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU;
    }

    /**
     * @see <a href="https://developer.android.com/about/versions/12/behavior-changes-all?hl=en#back-press">Root launcher activities are no longer finished on Back press</a>
     * @return should finish the root activity in task
     */
    @ChecksSdkIntAtLeast(api = Build.VERSION_CODES.S)
    @CheckResult
    public static boolean isTaskRootMoveToBack() {
        return Build.VERSION.SDK_INT >= Build.VERSION_CODES.S;
    }

    public boolean isAlwaysHoldCallback() {
        return isInternalCallbackAlwaysHold;
    }

    void checkInternalCallback() {
        if (isAlwaysHoldCallback()) {
            return;
        }

        checkInternalCallbackInternal();
    }

    @SuppressLint("WrongConstant")
    private void checkInternalCallbackInternal() {
        if (isSystemCallbackSupported()) {
            boolean hasCallback = isAlwaysHoldCallback() || hasCallback();
            if (isInternalCallbackRegistered == hasCallback) {
                return;
            }
            isInternalCallbackRegistered = hasCallback;

            android.window.OnBackInvokedDispatcher dispatcher = internalDispatcher;

            if (dispatcher == null) {
                dispatcher = internalDispatcher = requireDispatcherOwner().getOnBackInvokedDispatcher();
                internalCallback = isAnimationCallbackSupported() ? new OnBackAnimationCallback() {
                    @Override
                    public void onBackInvoked() {
                        dispatchOnBackInvoked();
                    }

                    @Override
                    public void onBackStarted(@NonNull BackEvent backEvent) {
                        dispatchOnBackStarted(new CompatBackEvent(backEvent));
                    }

                    @Override
                    public void onBackProgressed(@NonNull BackEvent backEvent) {
                        dispatchOnBackProgressed(backEvent);
                    }

                    @Override
                    public void onBackCancelled() {
                        dispatchOnBackCancelled();
                    }

                } : this::dispatchOnBackInvoked;
            }

            if (hasCallback) {
                dispatcher.registerOnBackInvokedCallback(PRIORITY_DEFAULT, internalCallback);
            } else {
                dispatcher.unregisterOnBackInvokedCallback(internalCallback);
            }
        }
    }

    private OnBackInvokedCallback getLatestOrNull() {
        OnBackInvokedCallback next = null;
        Integer priority = null;

        for (Map.Entry<Integer, OnBackInvokedCallback> entry : intCallbacks.entrySet()) {
            Integer prior = entry.getKey();
            if (priority == null || prior > priority) {
                OnBackInvokedCallback backInvokedCallback = entry.getValue();
                if (backInvokedCallback.isEnabled()) {
                    priority = prior;
                    next = backInvokedCallback;
                }
            }
        }

        return next;
    }

    public void setAlwaysHoldCallback(boolean alwaysHoldCallback) {
        if (alwaysHoldCallback != isAlwaysHoldCallback()) {
            isInternalCallbackAlwaysHold = alwaysHoldCallback;

            checkInternalCallbackInternal();
        }
    }

    /**
     * @param priority <strong>MUST</strong> be >= {@link #PRIORITY_DEFAULT},
     *                 all callbacks with priority lower than it will be <strong>IGNORED</strong>,
     * @see #getLatestOrNull()
     */
    public void addCallback(@Priority int priority, @NonNull OnBackInvokedCallback callback) {
        callback.setDispatcher(this);

        intCallbacks.put(priority, callback);

        // check only when callback is enabled
        if (callback.isEnabled()) {
            checkInternalCallback();
        }
    }

    @Priority
    public int nextPriority() {
        int priority;

        int p = -1;
        for (int prior : intCallbacks.keySet()) {
            // must ignore enabled state
            if (prior > p) {
                p = prior;
            }
        }
        priority = p + 1;

        return priority;
    }

    /**
     * a convenient way to {@link #addCallback(int, OnBackInvokedCallback)}
     * if you have no priority-specific need
     *
     * @return priority of this callback
     */
    @Priority
    public int addCallback(@NonNull OnBackInvokedCallback callback) {
        int priority = nextPriority();
        addCallback(priority, callback);
        return priority;
    }

    private void removeCallbackInternal(@NonNull OnBackInvokedCallback callback) {
        callback.setDispatcher(null);
        checkInternalCallback();
    }

    /**
     * @see OnBackInvokedCallback#setEnabled(boolean)
     */
    public void removeCallback(@NonNull OnBackInvokedCallback callback) {
        Map<Integer, OnBackInvokedCallback> calls = intCallbacks;

        for (Map.Entry<Integer, OnBackInvokedCallback> callbackEntry : calls.entrySet()) {
            if (callbackEntry.getValue() == callback) {
                calls.remove(callbackEntry.getKey());
                removeCallbackInternal(callback);

                break;
            }
        }
    }

    /**
     * @see OnBackInvokedCallback#setEnabled(boolean)
     */
    public void removeCallback(@Priority int priority) {
        OnBackInvokedCallback registeredCallback = intCallbacks.remove(priority);
        if (registeredCallback != null) {
            removeCallbackInternal(registeredCallback);
        }
    }

    public void clearCallbacks() {
        Map<Integer, OnBackInvokedCallback> calls = intCallbacks;
        for (OnBackInvokedCallback onBackInvokedCallback : calls.values()) {
            onBackInvokedCallback.setDispatcher(null);
        }
        calls.clear();
        checkInternalCallback();
    }

    @Nullable
    public OnBackInvokedCallback getCallback(int priority) {
        return intCallbacks.get(priority);
    }

    private boolean hasCallback() {
        for (OnBackInvokedCallback callback : intCallbacks.values()) {
            if (callback.isEnabled()) {
                return true;
            }
        }
        return false;
    }

    /**
     * @return is back event dispatched, false means you can exit
     */
    public boolean dispatchOnBackInvoked() {
        OnBackInvokedCallback invokedCallback = getLatestOrNull();
        boolean dispatched = invokedCallback != null;

        if (dispatched) {
            invokedCallback.onBackInvoked();
        } else {
            //backward compatibility
            requireDispatcherOwner().onBackInvoked();
        }

        return dispatched;
    }

    @NonNull
    private OnBackInvokedDispatcherOwner requireDispatcherOwner() {
        OnBackInvokedDispatcherOwner dispatcherOwner = owner.get();
        if (dispatcherOwner == null) {
            throw new NullPointerException("dispatcher is null.");
        }
        return dispatcherOwner;
    }

    private void dispatchOnBackStarted(@NonNull CompatBackEvent compatBackEvent) {
        OnBackInvokedCallback invokedCallback = getLatestOrNull();

        if (invokedCallback != null) {
            invokedCallback.onBackStarted(compatBackEvent);
        } else {
            requireDispatcherOwner().onBackStarted(compatBackEvent);
        }
    }

    @RequiresApi(api = Build.VERSION_CODES.UPSIDE_DOWN_CAKE)
    private void dispatchOnBackProgressed(@NonNull BackEvent backEvent) {
        OnBackInvokedCallback invokedCallback = getLatestOrNull();

        CompatBackEvent compatBackEvent = new CompatBackEvent(backEvent);
        if (invokedCallback != null) {
            invokedCallback.onBackProgressed(compatBackEvent);
        } else {
            requireDispatcherOwner().onBackProgressed(compatBackEvent);
        }
    }

    //@RequiresApi(api = Build.VERSION_CODES.UPSIDE_DOWN_CAKE)
    private void dispatchOnBackCancelled() {
        OnBackInvokedCallback invokedCallback = getLatestOrNull();

        if (invokedCallback != null) {
            invokedCallback.onBackCancelled();
        } else {
            requireDispatcherOwner().onBackCancelled();
        }
    }

    public boolean dispatchKeyEvent(@NonNull KeyEvent event) {
        if (event.getKeyCode() == KeyEvent.KEYCODE_BACK) {
            switch (event.getAction()) {
                case KeyEvent.ACTION_DOWN -> dispatchOnBackStarted(new CompatBackEvent(event));
                case KeyEvent.ACTION_UP -> {
                    if (event.isCanceled()) {
                        dispatchOnBackCancelled();
                        return false;
                    }
                    return dispatchOnBackInvoked();
                }
            }
        }
        return false;
    }

}
