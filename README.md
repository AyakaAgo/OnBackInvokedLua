# OnBackInvokedLua
[![中文版本](https://img.shields.io/badge/中文版本-red.svg)](https://github.com/AyakaAgo/OnBackInvokedLua/blob/main/README.zh.md)

[`OnBackInvokedCallback`](https://developer.android.com/reference/android/window/OnBackInvokedCallback)(library side: [LuaOnBackInvokedCallback](https://github.com/AyakaAgo/OnBackInvokedLua/blob/main/backdispatcher_lua/src/main/java/com/agyer/windmill/core/window/lua/LuaOnBackInvokedCallback.java)) wrapper for Androlua+

## Add support for the predictive back gesture

### Opt in predictive back gesture 

To opt in predictive back gesture, enabled it in `AndroidManifest.xml`.

```xml
<application
    ...
    android:enableOnBackInvokedCallback="true"
    ... >
...
</application>
```

**In Android 14 Beta 2 and higher**, you can [**set it per-Activity**](https://developer.android.com/about/versions/14/features#predictive-back-animations) instead of for the entire app.

```xml
<manifest ...>
    <application . . .

        android:enableOnBackInvokedCallback="false">

        <activity
            android:name=".MainActivity"
            android:enableOnBackInvokedCallback="true"
            ...
        </activity>
        <activity
            android:name=".SecondActivity"
            android:enableOnBackInvokedCallback="false"
            ...
        </activity>
    </application>
</manifest>
```

If not provided, it defaults to `false` and does the following:

- Disables the predictive back gesture system animation.
- Ignores OnBackInvokedCallback, old implementations continue to work.

After opting in, your app displays animations for back-to-home, cross-activity, and cross-task.

### Migrate to module API

#### implements with OnBackInvokedDispatcherOwner

Here's a base implementation of a OnBackInvokedDispatcherOwner Activity

```java
import android.view.KeyEvent;
import android.app.Activity;

import androidx.annotation.NonNull;

import com.agyer.windmill.core.window.OnBackInvokedDispatcher;
import com.agyer.windmill.core.window.OnBackInvokedDispatcherOwner;

public class ComponentActivity extends Activity implements OnBackInvokedDispatcherOwner {
    private final OnBackInvokedDispatcher backInvokedDispatcher = new OnBackInvokedDispatcher(this);

    /**
    * this method is basically a backward compatibility
    * <p>
    * This will not get called in predictive back gesture supported sdk levels
    * unless you enabled OnBackInvokedDispatcher#setAlwaysHoldCallback
    */
    @Override
    public void onBackInvoked() {
        if (isTaskRoot()) {
            // as new system behaviour we just move task to back instead of finish it
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
```
same way in `Dialog`(not included in samples).

[base LuaActivity for OnBackInvokedDispatcherOwner](https://github.com/AyakaAgo/OnBackInvokedLua/blob/main/app_lua/src/main/java/com/agyer/playground/app/OnBackInvokedBaseLuaActivity.java)

#### replace `onBackPressed`/`KeyEvent.KEYCODE_BACK`

old implementations
```lua
-- assume this is a LuaActivity context

function onKeyUp(keyCode, keyEvent)
    if keyCode == KeyEvent.KEYCODE_BACK then
        if xxx.isOpen() then
            -- go back logic
            xxx.close()

            -- this is how the old implementation intercept
            return true
        end
    end
end
```

to new implementation
```lua
-- assume this is a LuaActivity context

require "import"

import "com.agyer.windmill.core.window.lua.LuaOnBackInvokedCallback"
import "com.agyer.windmill.core.window.OnBackInvokedDispatcher"

local xxx -- assume this is what we need to go back with

local openCloseBackCallback = LuaOnBackInvokedCallback({
    onBackInvoked = function(callback)
        webview.goBack()
    end
-- construct with false is as same as setEnabled(false)
-- disabled callbacks will not get called
}, false)

-- register a callback with specified priority
-- expect for the constants in OnBackInvokedDispatcher, priorities should be or greater than 0
activity.registerOnBackInvokedCallback(OnBackInvokedDispatcher.PRIORITY_OVERLAY, openCloseBackCallback)

-- this is a convenience way for registerOnBackInvokedCallback if you don't mind priority
-- this method will return the priority for removal
--local priority = activity.registerOnBackInvokedCallback(openCloseBackCallback)

-- assume we have the state listener
xxx.setOnStateChangedListener(OnStateChangedListener{
    onStateChanged = function(isOpened)
        -- update the state of the callback
        -- setEnable is useful for frequently used callbacks
        openCloseBackCallback.setEnabled(isOpened)
    end
})

-- always remember to disable or remove callbacks when unneeded

-- remove by priority
--activity.unregisterOnBackInvokedCallback(priority)

-- remove by callback instance
--activity.unregisterOnBackInvokedCallback(openCloseBackCallback)

-- this is a convenience way for unregisterOnBackInvokedCallback
openCloseBackCallback.remove()
```

[Lua sample](https://github.com/AyakaAgo/OnBackInvokedLua/blob/main/app_lua/src/main/assets/back_callback.lua)

-----------------------------------

## Add support for custom predictive back animations

With Android 14, if you've already migrated your app to the new system back APIs, you can create custom in-app transitions and animations for your app's custom moments by using [OnBackAnimationCallback](https://developer.android.google.cn/reference/android/window/OnBackAnimationCallback)(library side: [OnBackAnimationCallback](https://github.com/AyakaAgo/OnBackInvokedLua/blob/main/backdispatcher/src/main/java/com/agyer/windmill/core/window/OnBackAnimationCallback.java)) to develop custom in-app transitions and animations.

> **Note**: Learn how to [design custom in-app transitions and animations](https://developer.android.google.cn/design/ui/mobile/guides/patterns/predictive-back).

[Lua sample](https://github.com/AyakaAgo/OnBackInvokedLua/blob/main/app_lua/src/main/assets/back_animation_callback.lua)

-----------------------------------

## Add custom activity transitions on Android 14 and higher

To ensure that custom Activity transitions support predictive back on Android 14 and higher, you can use [overrideActivityTransition](https://developer.android.google.cn/reference/android/app/Activity#overrideActivityTransition(int,%20int,%20int)) instead of `overridePendingTransition`. This means that the transition animation plays as the user swipes back.

To provide an example of how this might work, imagine a scenario in which Activity B is on top of Activity A in the back stack. You would handle custom Activity animations in the following way:

- Call either opening or closing transitions within Activity B's onCreate method.
- When the user navigates to Activity B, use [OVERRIDE_TRANSITION_OPEN](https://developer.android.google.cn/reference/android/app/Activity#OVERRIDE_TRANSITION_OPEN). When the user swipes to navigate back to Activity A, use [OVERRIDE_TRANSITION_CLOSE](https://developer.android.google.cn/reference/android/app/Activity#OVERRIDE_TRANSITION_CLOSE).
- When specifying `OVERRIDE_TRANSITION_CLOSE`, the enterAnim is Activity A's enter animation and the exitAnim is Activity B's exit animation.

> **Note**: If `exitAnim` isn't set or is set to `0`, the default cross-activity predictive animation is used.

-----------------------------------

## Test the predictive back gesture animation
> **Note**: With Android 15, system animations such as back-to-home, cross-task, and cross-activity are no longer behind the developer option. They now appear for apps that have opted into the predictive back gesture either entirely or at an activity level.

If you still use Android 13 or Android 14, you can test the back-to-home animation shown in Figure 1.

To test this animation, complete the following steps:
1. On your device, go to Settings > System > Developer options.
2. Select Predictive back animations.
3. Launch your updated app, and use the back gesture to see it in action.

> **Note**: `OnBackInvokedCallback` is always called regardless of the enable state of Predictive back animations once you set `android:enableOnBackInvokedCallback="true"`. In other words, disabling the system animation doesn't affect your app's back handling logic if it uses `OnBackInvokedCallback`.

-----------------------------------

```
Copyright (C) 2024 The Windmill Open Source Project

	Licensed under the Apache License, Version 2.0 (the "License");
	you may not use this file except in compliance with the License.
	You may obtain a copy of the License at

		http://www.apache.org/licenses/LICENSE-2.0

	Unless required by applicable law or agreed to in writing, software
	distributed under the License is distributed on an "AS IS" BASIS,
	WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
	See the License for the specific language governing permissions and
	limitations under the License.
```

Some content and code samples on this page are subject to the licenses described in the [Content License](https://developer.android.com/license).
