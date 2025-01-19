# OnBackInvokedLua
用于 Androlua+ 的 [`OnBackInvokedCallback`](https://developer.android.com/reference/android/window/OnBackInvokedCallback)(库端实现: [LuaOnBackInvokedCallback](https://github.com/AyakaAgo/OnBackInvokedLua/blob/main/backdispatcher_lua/src/main/java/com/agyer/windmill/core/window/lua/LuaOnBackInvokedCallback.java))封装。
非 Androlua+ 亦可使用（[核心逻辑](https://github.com/AyakaAgo/OnBackInvokedLua/tree/main/backdispatcher)）。

## 添加预测性返回手势的支持

### 启用预测性返回手势

在 `AndroidManifest.xml` 添加属性。

```xml
<application
    ...
    android:enableOnBackInvokedCallback="true"
    ... >
...
</application>
```

**在 Android 14 Beta 2 及更高版本**, 可以[**为每个 Activity 单独启用**](https://developer.android.com/about/versions/14/features#predictive-back-animations)而不是启用到整个 Application 。

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

未设置时，默认为`false`并会如下处理：

- 关闭预测性返回手势的系统动画
- 忽略 `OnBackInvokedCallback`, 旧实现会继续执行。

启用后，App 将显示返回到桌面, 跨 Activity 和跨任务的预测性返回手势动画。

### 迁移到库 API

#### 实现 OnBackInvokedDispatcherOwner

一个 OnBackInvokedDispatcherOwner 的基本 Activity

```java
import android.view.KeyEvent;
import android.app.Activity;

import androidx.annotation.NonNull;

import com.agyer.windmill.core.window.OnBackInvokedDispatcher;
import com.agyer.windmill.core.window.OnBackInvokedDispatcherOwner;

public class ComponentActivity extends Activity implements OnBackInvokedDispatcherOwner {
    private final OnBackInvokedDispatcher backInvokedDispatcher = new OnBackInvokedDispatcher(this);

    /**
    * 除非启用 OnBackInvokedDispatcher#setAlwaysHoldCallback，
    * 此方法不会在支持且启用预测性返回手势的平台上收到回调
    */
    @Override
    public void onBackInvoked() {
        if (isTaskRoot()) {
            // 跟随 Android 12 行为变更
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
`Dialog`以同样的方式实现(不含sample).

[OnBackInvokedDispatcherOwner 的基本 Activity](https://github.com/AyakaAgo/OnBackInvokedLua/blob/main/app_lua/src/main/java/com/agyer/playground/app/OnBackInvokedBaseLuaActivity.java)

#### 替代 `onBackPressed`/`KeyEvent.KEYCODE_BACK`

旧实现
```lua
-- 假设运行于 OnBackInvokedDispatcherOwner 的 LuaActivity 中

local xxx -- 假设这是需要返回的内容

function onKeyUp(keyCode, keyEvent)
    if keyCode == KeyEvent.KEYCODE_BACK then
        if xxx.isOpen() then
            -- 返回逻辑
            xxx.close()

            -- 以 boolean 指示是否拦截返回事件
            return true
        end
    end
end
```

转到新实现
```lua
-- 假设运行于 OnBackInvokedDispatcherOwner 的 LuaActivity 中

require "import"

import "com.agyer.windmill.core.window.lua.LuaOnBackInvokedCallback"
import "com.agyer.windmill.core.window.OnBackInvokedDispatcher"

local xxx -- 假设这是需要返回的内容

local openCloseBackCallback = LuaOnBackInvokedCallback({
    onBackInvoked = function(callback)
        xxx.close()
    end
-- 以 false 构建的 callback 即默认 setEnabled(false)
-- 已禁用的 callback 不会收到回调
}, false)

-- 以指定优先级注册回调
-- 除 OnBackInvokedDispatcher 中的 PRIORITY_XXX 常量外，不接受其他数值优先级，否则会抛异常
activity.registerOnBackInvokedCallback(OnBackInvokedDispatcher.PRIORITY_OVERLAY, openCloseBackCallback)

-- registerOnBackInvokedCallback 的简便方法
-- 返回此回调关联的优先级
--local priority = activity.registerOnBackInvokedCallback(openCloseBackCallback)

-- 假设状态监听器
xxx.setOnStateChangedListener(OnStateChangedListener{
    onStateChanged = function(isOpened)
        -- 更新回调状态
        -- 如果某个 callback 会经常注册/反注册，setEnable 提供一个更好的管理方式
        openCloseBackCallback.setEnabled(isOpened)
    end
})

-- 记得在不需要时禁用或反注册回调，否则用户可能无法退出应用

-- 以优先级移除
--activity.unregisterOnBackInvokedCallback(priority)

-- 以实例移除
--activity.unregisterOnBackInvokedCallback(openCloseBackCallback)

-- 或者使用回调中的 unregisterOnBackInvokedCallback 简便方法
--openCloseBackCallback.remove()
```

新实现并非以 boolean 指示是否拦截，请注意区分。

[Lua sample](https://github.com/AyakaAgo/OnBackInvokedLua/blob/main/app_lua/src/main/assets/back_callback.lua)

-----------------------------------

## 添加自定预测性返回手势动画

在 Android 14 中, 如果已迁移到新的返回 API, 可以使用 [OnBackAnimationCallback](https://developer.android.google.cn/reference/android/window/OnBackAnimationCallback)(库端实现: [OnBackAnimationCallback](https://github.com/AyakaAgo/OnBackInvokedLua/blob/main/backdispatcher/src/main/java/com/agyer/windmill/core/window/OnBackAnimationCallback.java))创建自定义应用内动画。

> **注意**: 查看如何[自定应用内动画](https://developer.android.google.cn/design/ui/mobile/guides/patterns/predictive-back).

[Lua sample](https://github.com/AyakaAgo/OnBackInvokedLua/blob/main/app_lua/src/main/assets/back_animation_callback.lua)

-----------------------------------

## 在 Android 14 及更高版本中添加自定 Activity 过渡动画

为了确保自定 Activity 过渡动画支持 Android 14 及更高版本上的预测性返回手势，可以使用 [overrideActivityTransition](https://developer.android.google.cn/reference/android/app/Activity#overrideActivityTransition(int,%20int,%20int)) 替代 overridePendingTransition。过渡动画将在用户使用手势时执行。

为解释工作原理，假设任务栈中 Activity B 处于 Activity A 之上，以如下方式处理 Activity 的过渡动画：

- 在Activity B 的 onCreate 方法中设定开闭过渡动画.
- 当用户要前往到 Activity B 时，使用 [OVERRIDE_TRANSITION_OPEN](https://developer.android.google.cn/reference/android/app/Activity#OVERRIDE_TRANSITION_OPEN)。返回到 Activity A 时，使用 [OVERRIDE_TRANSITION_CLOSE](https://developer.android.google.cn/reference/android/app/Activity#OVERRIDE_TRANSITION_CLOSE)。
- 当指定`OVERRIDE_TRANSITION_CLOSE`时表示`enterAnim`是 Activity A 的进入动画， `exitAnim`是 Activity B 的退出动画。

> **注意**: 未指定 `exitAnim` 或指定为 `0` 时将使用系统默认动画。

-----------------------------------

## 测试预测性返回手势
> **注意**: Android 15 起, 返回到桌面, 跨 Activity 和跨任务等系统动画不需要在开发者选项开启。已启用预测性返回手势支持的应用或 Activity 都会显示动画。

在 Android 13 或 14 中以以下步骤测试动画：
1. 设置 > 系统 > 开发者选项.
2. 启用“预见式返回动画”.
3. 启动已启用支持d App

> **注意**: 无论是否开启此动画效果，已启用`android:enableOnBackInvokedCallback`的应用都会照常收到`OnBackInvokedCallback`回调。也就是说，系统动画不会影响`OnBackInvokedCallback`的逻辑。

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
