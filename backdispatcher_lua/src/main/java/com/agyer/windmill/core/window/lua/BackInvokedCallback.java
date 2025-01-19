/*
 * Copyright 2023 The Windmill Open Source Project
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

import android.os.Build;
import android.window.OnBackInvokedCallback;

import androidx.annotation.RequiresApi;


/**
 * this class is a system api wrapper for Lua,
 * for java, use {@link com.agyer.windmill.core.window.OnBackInvokedCallback}
 * or {@link com.agyer.windmill.core.window.OnBackAnimationCallback}
 *
 * @deprecated use {@link LuaOnBackInvokedCallback} instead.
 */
@Deprecated
@RequiresApi(api = Build.VERSION_CODES.TIRAMISU)
public abstract class BackInvokedCallback implements OnBackInvokedCallback {
    public BackInvokedCallback() {

    }

}
