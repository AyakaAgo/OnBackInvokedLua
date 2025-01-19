/*
 * Copyright 2025 The Windmill Open Source Project
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
package com.agyer.playground.app;

import android.view.KeyEvent;

import androidx.annotation.NonNull;

import com.agyer.windmill.core.window.OnBackInvokedDispatcher;
import com.agyer.windmill.core.window.OnBackInvokedDispatcherOwner;
import com.androlua.LuaActivity;

public class OnBackInvokedBaseLuaActivity extends LuaActivity implements OnBackInvokedDispatcherOwner {
    private final OnBackInvokedDispatcher backInvokedDispatcher = new OnBackInvokedDispatcher(this);

    @Override
    public void onBackInvoked() {
        if (isTaskRoot()) {
            // as new system behaviour we just move task to back instead of finish it
            // also for backward compatibility
            if (OnBackInvokedDispatcher.isTaskRootMoveToBack()) {
                moveTaskToBack(false);
            } else {
                finishAndRemoveTask();
            }
        } else {
            finish();
        }
    }

    @Override
    public boolean dispatchKeyEvent(KeyEvent event) {
        return backInvokedDispatcher.dispatchKeyEvent(event) || super.dispatchKeyEvent(event);
    }

    @NonNull
    @Override
    public OnBackInvokedDispatcher getCompatOnBackInvokedDispatcher() {
        return backInvokedDispatcher;
    }

}
