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

import android.app.Activity;

import androidx.annotation.NonNull;

import com.agyer.windmill.core.window.OnBackInvokedDispatcher;
import com.agyer.windmill.core.window.OnBackInvokedDispatcherOwner;

public class OnBackInvokedBaseActivity extends Activity implements OnBackInvokedDispatcherOwner {
    // dispatcher to manage callbacks
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

    /**
     * for backward compatibility we have to trigger {@link #goBack} for dispatcher manually.
     */
    @Override
    public void onBackPressed() {
        goBack();
    }

    /**
     * get dispatcher for {@link OnBackInvokedDispatcherOwner}
     */
    @NonNull
    @Override
    public final OnBackInvokedDispatcher getCompatOnBackInvokedDispatcher() {
        return backInvokedDispatcher;
    }

}