# [backdispatcher.lua](https://github.com/AyakaAgo/OnBackInvokedLua/blob/main/lua/backdispatcher.lua)
Equivalent to [`OnBackInvokedDispatcher`](https://developer.android.google.cn/reference/android/window/OnBackInvokedDispatcher).

Dispatcher to register `OnBackInvokedCallback`(as function or functions table) instances for handling back invocations. It also provides interfaces to update the attributes of `OnBackInvokedCallback`. Attribute updates are proactively pushed to the window manager if they change the dispatch target (a.k.a. the callback to be invoked next), or its behavior. Compatible with Android12L and below. [code samples](https://github.com/AyakaAgo/OnBackInvokedLua/tree/main/sample)

## Constants

### PRIORITY_DEFAULT
```lua
PRIORITY_DEFAULT = 0
```
Default priority level of `OnBackInvokedCallback`s.

### PRIORITY_OVERLAY
```lua
PRIORITY_OVERLAY = 1000000
```
Priority level of OnBackInvokedCallbacks for overlays such as menus and navigation drawers that should receive back dispatch before non-overlays.

### isBackGesturePredictable
```lua
isBackGesturePredictable = android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.TIRAMISU
```
If platform version supports `OnBackInvokedCallback`.

### isBackGestureAnimationPredictable
```lua
isBackGestureAnimationPredictable = android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.UPSIDE_DOWN_CAKE
```
If platform version supports `OnBackAnimationCallback`.

## Methods

### register
```lua
function register(context, tag, callback, priority)
```
Equivalent to [registerOnBackInvokedCallback](https://developer.android.google.cn/reference/android/window/OnBackInvokedDispatcher#registerOnBackInvokedCallback(int,%20android.window.OnBackInvokedCallback)). Registers a `OnBackInvokedCallback`. **The same priority or tag of callbacks are not allowed**. Higher priority callbacks are invoked before lower priority ones.

if `callback` is table value and it only contains `onBackInvoked`:
```lua
register(activity,"sample_tag",{
  onBackInvoked=function(dispatcher, context, tag)
  
  end
})
```
it can be simplified to：
```lua
register(activity,"sample_tag",function(dispatcher, context, tag)
  
end)
```
**paramaters**
| name | type | description |
| :----- | :----- | :----- |
| context | / | Activity or Dialog to intercept back events. This value **MUST NOT** be nil. |
| tag | string | The tag of the callback, for global unregister or setEnabled. This value **MUST NOT** be nil. |
| callback | function or table | `OnBackInvokedCallback`. This value **MUST NOT** be nil. |
| priority | number | The priority of the callback. Value is `PRIORITY_DEFAULT`, or `PRIORITY_OVERLAY` or any 0-greater value. This value maybe nil. |

**returns**
| type | description |
| :----- | :----- |
| table | module itself |

**throws**
| type | description |
| :----- | :----- |
| `java.lang.IllegalArgumentException` | if the priority is negative. |
| lua exception | if the priority is negative. |
| lua exception | if the priority is already exists. |
| lua exception | if the tag is already exists. |

### registerIfUnregistered
```lua
function registerIfUnregistered(context, tag, callback, priority)
```
Equivalent to [registerOnBackInvokedCallback](https://developer.android.google.cn/reference/android/window/OnBackInvokedDispatcher#registerOnBackInvokedCallback(int,%20android.window.OnBackInvokedCallback)). Registers a `OnBackInvokedCallback`. **The same priority or tag of callbacks are not allowed**. Higher priority callbacks are invoked before lower priority ones.

**paramaters**
| name | type | description |
| :----- | :----- | :----- |
| context | / | Activity or Dialog to intercept back events. This value **MUST NOT** be nil. |
| tag | string | The tag of the callback, for global unregister or setEnabled. This value **MUST NOT** be nil. |
| callback | function or table | `OnBackInvokedCallback`. This value **MUST NOT** be nil. |
| priority | number | The priority of the callback. Value is `PRIORITY_DEFAULT`, or `PRIORITY_OVERLAY` or any 0-greater value. This value maybe nil. |

**returns**
| type | description |
| :----- | :----- |
| table | module itself |

**throws**
| type | description |
| :----- | :----- |
| `java.lang.IllegalArgumentException` | if the priority is negative. |
| lua exception | if the priority is negative. |

### unregister
```lua
function unregister(context, tag)
```
Equivalent to [unregisterOnBackInvokedCallback](https://developer.android.google.cn/reference/android/window/OnBackInvokedDispatcher#unregisterOnBackInvokedCallback(android.window.OnBackInvokedCallback)). Unregisters an `OnBackInvokedCallback`.

**paramaters**
| name | type | description |
| :----- | :----- | :----- |
| context | / | Activity or Dialog to intercept back events. This value **MUST NOT** be nil. |
| tag | string | The tag of the callback, for global unregister or setEnabled. This value **MUST NOT** be nil. |

**returns**
| type | description |
| :----- | :----- |
| table | module itself |

### setAllEnabled
```lua
function setAllEnabled(context, enabled)
```
> **Deprecated: test only**

Set the enabled state of all registered callbacks, subsequent registered callbacks will be added with enabled state. Only enabled callback will receive callbacks to `onBackInvoked`.

**paramaters**
| name | type | description |
| :----- | :----- | :----- |
| context | / | Activity or Dialog to intercept back events. This value **MUST NOT** be nil. |
| enabled | boolean | The new enabled state of all registered callback. This value **MUST NOT** be nil. |

**returns**
| type | description |
| :----- | :----- |
| table | module itself |

### setEnabled
```lua
function setEnabled(context, tag, enabled)
```
Equivalent to [androidx.activity.OnBackPressedCallback#setIsEnabled](https://developer.android.google.cn/reference/androidx/activity/OnBackPressedCallback#setIsEnabled(kotlin.Boolean)). Set the enabled state of the callback. Only enabled callback will receive callbacks to `onBackInvoked`.

**paramaters**
| name | type | description |
| :----- | :----- | :----- |
| context | / | Activity or Dialog to intercept back events. This value **MUST NOT** be nil. |
| tag | string | The tag of the callback. This value **MUST NOT** be nil. |
| enabled | boolean | The new enabled state of all registered callback. This value **MUST NOT** be nil. |

**returns**
| type | description |
| :----- | :----- |
| table | module itself |

### isEnabled
```lua
function isEnabled(context, tag)
```
Equivalent to [androidx.activity.OnBackPressedCallback#isEnabled](https://developer.android.google.cn/reference/androidx/activity/OnBackPressedCallback#getIsEnabled()). The enabled state of the callback. Only enabled callback will receive callbacks to `onBackInvoked`.

**paramaters**
| name | type | description |
| :----- | :----- | :----- |
| context | / | Activity or Dialog to intercept back events. This value **MUST NOT** be nil. |
| tag | string | The tag of the callback. This value **MUST NOT** be nil. |

**returns**
| type | description |
| :----- | :----- |
| boolean | The enabled state of the callback. Only enabled callback will receive callbacks to `onBackInvoked`. |

### getRegisteredTags
```lua
function getRegisteredTags(context)
```
Get the tags of all registered callbacks, whether they are enabled or not.

**paramaters**
| name | type | description |
| :----- | :----- | :----- |
| context | / | Activity or Dialog to intercept back events. This value **MUST NOT** be nil. |

**returns**
| type | description |
| :----- | :----- |
| table | The tags of all registered callbacks, whether they are enabled or not. |

### getRegisteredPriorities
```lua
function getRegisteredPriorities(context)
```
Get the priorities of all registered callbacks, whether they are enabled or not.

**paramaters**
| name | type | description |
| :----- | :----- | :----- |
| context | / | Activity or Dialog to intercept back events. This value **MUST NOT** be nil. |

**returns**
| type | description |
| :----- | :----- |
| table | The priorities of all registered callbacks, whether they are enabled or not. |

### isPriorityRegistered
```lua
function isPriorityRegistered(context, priority)
```
Determine whether a specified priority has been registered.

**paramaters**
| name | type | description |
| :----- | :----- | :----- |
| context | / | Activity or Dialog to intercept back events. This value **MUST NOT** be nil. |
| priority | number | The priority of the callback. |

**returns**
| type | description |
| :----- | :----- |
| boolean | If a specified priority has been registered. |

### isTagRegistered
```lua
function isTagRegistered(context, tag)
```
Determine whether a specified tag has been registered.

**paramaters**
| name | type | description |
| :----- | :----- | :----- |
| context | / | Activity or Dialog to intercept back events. This value **MUST NOT** be nil. |
| tag | string | The tag of the callback. |

**returns**
| type | description |
| :----- | :----- |
| boolean | If a specified tag has been registered. |

### hasCallback
```lua
function hasCallback(context)
```
Determine if a context has any registered `OnBackInvokedCallback`.

**paramaters**
| name | type | description |
| :----- | :----- | :----- |
| context | / | Activity or Dialog to intercept back events. This value **MUST NOT** be nil. |

**returns**
| type | description |
| :----- | :----- |
| boolean | If there is any `OnBackInvokedCallback` registered. |

### isBackGesturePredictable
```lua
function isBackGesturePredictable()
```
> **Deprecated: access isBackGesturePredictable instead**
If platform version supports `OnBackInvokedCallback`.

**returns**
| type | description |
| :----- | :----- |
| boolean | If platform version supports `OnBackInvokedCallback`. |

### nextPriority
```lua
function nextPriority(context, base)
```
get the next priority that doesn't conflict with existing callbacks.

**paramaters**
| name | type | description |
| :----- | :----- | :----- |
| context | / | Activity or Dialog to intercept back events. This value **MUST NOT** be nil. |
| base | number | The excepted lowest non-negative priority. If nil, return next priority of existing callbacks, else return the larger one of base and the next priority of existing callbacks. This value maybe nil. |

**returns**
| type | description |
| :----- | :----- |
| number | The next priority that doesn't conflict with existing callbacks. |

### back
```lua
function back(context, finish)
```
Trigger a back event manually without system navigation event.

**paramaters**
| name | type | description |
| :----- | :----- | :----- |
| context | / | Activity or Dialog to intercept back events. This value **MUST NOT** be nil. |
| finish | boolean | If true, finish Activity or dismiss Dialog when no more registered `OnBackInvokedCallback`. |

**returns**
| type | description |
| :----- | :----- |
| boolean | if has any registered `OnBackInvokedCallback`. |

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