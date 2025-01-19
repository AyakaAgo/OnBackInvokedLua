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

import androidx.annotation.NonNull;

/**
 * same as {@link OnBackInvokedCallback}, but related methods are abstract
 */
public abstract class OnBackAnimationCallback extends OnBackInvokedCallback {

    public OnBackAnimationCallback() {

    }

    public OnBackAnimationCallback(boolean enabled) {
        super(enabled);
    }

    @Override
    public abstract void onBackCancelled();

    @Override
    public abstract void onBackProgressed(@NonNull CompatBackEvent backEvent);

    @Override
    public abstract void onBackStarted(@NonNull CompatBackEvent backEvent);

}
