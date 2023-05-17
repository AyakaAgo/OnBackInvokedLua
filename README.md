# OnBackInvokedLua
[`OnBackInvokedCallback`](https://developer.android.google.cn/reference/android/window/OnBackInvokedCallback) wrapper for Androlua, compatible with Android 6.0 - 14 *(partial tested: 12 - 14)*, `onBackPressed` or `onKeyUp(Down)`(old implementation) migration support.

## Predictive back gesture

<img src="https://developer.android.google.cn/static/images/about/versions/13/predictive-back-nav-home.gif" alt="Figure 1. Mockup of the predictive back gesture look and feel on a phone" width="20%">
Android 13 (API level 33) introduces a predictive back gesture for Android devices such as phones, large screens, and foldables. It is part of a multi-year release; when fully implemented, this feature will let users preview the destination or other result of a back gesture before fully completing it, allowing them to decide whether to continue or stay in the current view.

### documentations
[Predictive back design](https://developer.android.google.cn/design/ui/mobile/guides/patterns/predictive-back)\
[Add support for the predictive back gesture](https://developer.android.google.cn/guide/navigation/predictive-back-gesture)\
[Add support for built-in and custom predictive back animations](https://developer.android.google.cn/about/versions/14/features/predictive-back)

### APIs
[OnBackInvokedCallback](https://developer.android.google.cn/reference/android/window/OnBackInvokedCallback) interception(animated [OnBackAnimationCallback](https://developer.android.google.cn/reference/android/window/OnBackAnimationCallback))\
[OnBackInvokedDispatcher](https://developer.android.google.cn/reference/android/window/OnBackInvokedDispatcher) host

## Add support for the predictive back gesture

this module provides a migration path to properly intercept back navigation, which involves replacing back interceptions from `KeyEvent.KEYCODE_BACK` and any classes with `onBackPressed` methods such as `Activity` and `Dialog` with the new system Back APIs. If your app implements custom back behavior, you can migrate your project with this module.

> **Note: `KeyEvent.KEYCODE_BACK` is not deprecated as there are some supported use cases of `KeyEvent.KEYCODE_BACK`; however, intercepting back events from KeyEvent.KEYCODE_BACK is no longer supported.**

### Opt in predictive back gesture 

To opt in predictive back gesture, set the `android:enableOnBackInvokedCallback` flag to `true` in the `<application>` tag in `AndroidManifest.xml`.

```xml
<application
    ...
    android:enableOnBackInvokedCallback="true"
    ... >
...
</application>
```

If you don't provide a value, it defaults to `false` and does the following:

- Disables the predictive back gesture system animation.
- Ignores OnBackInvokedCallback, old implement calls continue to work.

### Add proxy classes for `luajava.override`

> **Note: If your `luajava` fixed `luajava.override`, `luajava.new` object cast problem, you can ignore this step**

> **Note: This is not a standard Android Studio/IntelliJ IDEA/... project, please move files manually.**

If the object returned by `luajava.override`, `luajava.new` has a wrong type, add classes in `java/` or dex in `libs/` to your project.

- BackInvokedCallback.java
- BackAnimationCallback.java

### Migrate to module API

1. Use `backdispatcher.lua`(this module) in `Activity` or `Dialog` with old implementation used.

2. Register your custom back logic with this module. This prevents the current `Activity` from being finished, and your callback gets a chance to react to the Back action once the user completes the system back navigation.

3. Unregister the callback when ready to stop intercepting the back gesture. Otherwise, users may see undesirable behavior when using a system back navigation—for example, "getting stuck" between views and forcing them to force quit your app.

done.

> **Note: To synchronize behavior with the new platform API, we DO NOT intercept back events by the callback's return value, so DO NOT return boolean in callbacks. You SHOULD always call `unregister` or `setEnabled` to stop intercepting back events.** 

> **Caution: If you don’t update your app by the next major version of Android following 13, users will experience broken Back navigation when running your app.**

Here’s an example of how to migrate logic out of old implementation:
```lua
local backDispatcher = require"backdispatcher"

--you can register in onCreate, onStart or any back stack changes

--NOTICE
--this method will throw if tag or priority already exists
backDispatcher.register(
  activity,
  "finish_interception",--callback tag,
  function(dispatcher, context, tag)
    --[[
      onBackPressed logic goes here - For instance:
      Prevents closing the app to go home screen when in the
      middle of entering data to a form
      or from accidentally leaving a fragment with a WebView in it
    
      Unregistering the callback to stop intercepting the back gesture:
      When the user transitions to the topmost screen (activity, fragment)
      in the BackStack, unregister the callback by calling
    ]]
    dispatcher.unregister(context, tag)
    --or
    --dispatcher.setEnabled(context, tag, false)
  end,
  backDispatcher.PRIORITY_DEFAULT--callback priority
)
```

## Add support for built-in and custom predictive back animations

In **Android 14 and later**, if you've already migrated your app to the new system back APIs, you can opt in to predictive back to automatically receive in-app animations and also support custom transitions with [OnBackAnimationCallback](https://developer.android.google.cn/reference/kotlin/android/window/OnBackAnimationCallback).

After opting in, your app displays animations for back-to-home, cross-activity, and cross-task.

<img src="https://github.com/AyakaAgo/OnBackInvokedLua/blob/main/images/bottom%20sheet.gif?raw=true" alt="animation callback in bottom sheet" width="33%"><img src="https://github.com/AyakaAgo/OnBackInvokedLua/blob/main/images/side%20sheet.gif?raw=true" alt="animation callback in side sheet" width="33%">
<img src="https://github.com/AyakaAgo/OnBackInvokedLua/blob/main/images/search.gif?raw=true" alt="animation callback in search" width="33%">
\**from MDC Android library.*

Here's an example of how you might implement this feature:

```lua
--local BackEvent = luajava.bindClass"android.window.BackEvent"
--TODO
--your view here
local view
local screenWidth = luajava.bindClass"android.content.res.Resources".getSystem().getDisplayMetrics().widthPixels
local maxXShift = screenWidth / 20

require"backdispatcher".register(
  activity,
  "custom_back_animation",
  {
    onBackProgressed=function(backEvent)
      local progress = backEvent.getProgress()
      local translation = progress * maxXShift
      local scale = 1 - 0.1 * backEvent.progress
      view.setTranslationX(backEvent.getSwipeEdge() == backEvent.EDGE_LEFT and translation or -translation)
        .setScaleX(scale).setScaleY(scale)
    end,
    onBackInvoked=function(dispatcher, context, tag) {
      --Do something after the back gesture completes.
    end,
    onBackCancelled=function() {
      --TODO
      --reset view's position and scale
    end,
    onBackStarted=function() {
      --a back gesture started
    end
  },
  backDispatcher.PRIORITY_DEFAULT
)
```

> **Note: onBackStarted, onBackCancelled, onBackProgressed on available in Android 14 and later, see [OnBackAnimationCallback](https://developer.android.google.cn/reference/kotlin/android/window/OnBackAnimationCallback)**

### Test the predictive back gesture animation
Starting with the Android 13 final release, you should be able to enable a developer option to test the back-to-home animation.

To test this animation, complete the following steps:
1. On your device, go to Settings > System > Developer options.
2. Select Predictive back animations.
3. Launch your updated app, and use the back gesture to see it in action.

> **Note: `OnBackInvokedCallback` is always called regardless of the enable state of Predictive back animations. In other words, disabling the system animation doesn't affect your app's back handling logic if it uses `OnBackInvokedCallback`.**

-----------------------------------

```
Copyright (C) 2018-2023 The AGYS Windmill Open Source Project

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

*Some content and code samples on this page are subject to the licenses described in the [Content License](https://developer.android.google.cn/license).*
