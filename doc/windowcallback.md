# [windowcallback.lua](https://github.com/AyakaAgo/OnBackInvokedLua/blob/main/lua/windowcallback.lua)

Wrapper for [Window.Callback](https://developer.android.google.cn/reference/android/view/Window.Callback). `Window.Callback` is an API from a Window back to its caller. This allows the client to intercept key dispatching, panels and menus, etc.

> **Note**: The design purpose of this module has changed from targeting multiple windows to a single window.

You can nested wrap multiple times, but may impact performance.

> **Note**: ~~Deprecated~~ methods are commented.

## Constructor

> **Note**: use `.` to call constructor method. `require"windowcallback".new(...)`

### new
```lua
function new(window, callback)
```
**paramaters**
| name | type | description |
| :----- | :----- | :----- |
| window | [android.view.Window](https://developer.android.google.cn/reference/android/view/Window) | A `Window` to wrap its callback. This value **MUST NOT** be nil. |
| callback | table | functions table to wrap windows's callback. This value maybe nil. (wait... you don't need to wrap it if your callback is nil!) |

**returns**
| type | description |
| :----- | :----- |
| table | `windowcallback` instance |

## Metatdata

> **Note**: Prefer calling defined methods to get values in metatable instead of accessing them directly.

### callback
```lua
callback = luajavaoverride(Window.Callback, ...)
```
`Window.Callback` wrapper

### attached
```lua
attached = false
```
Determine if the wrapped `Window.Callback` is set to the Window.

### window
```lua
window = Window
```
`Window` to wrap its `Callback`.

### superCallback
```lua
window = Window.Callback
```
the original `Window.Callback` of the window.

### functions
```lua
functions = table
```
callback table

## Methods

> **Note**: use `:` to call non-constructor method. `require"windowcallback".new(...):attachToWindow()`

### ~~setCallbackFunction~~
```lua
function setCallbackFunction(self, voidName, callbackFunction)
```
> **Deprecated**: It's not recommended to modify the wrapper function(s).

set or replace a callback table value, for example:
```lua
local wrappedCallback = require"windowcallback".new(activity.getWindow(), {
  dispatchTouchEvent = function(callback, super, event)
    return false
  end,
  onAttachedToWindow = function(callback, super)
    super()
  end
})

wrappedCallback:setCallbackFunction("dispatchTouchEvent", function(callback, super, event)
  return super(event)
end)
```

**paramaters**
| name | type | description |
| :----- | :----- | :----- |
| self | table | `windowcallback` instance. This value **MUST NOT** be nil. |
| voidName | string | any void name in [Window.Callback](https://developer.android.google.cn/reference/android/view/Window.Callback). This value **MUST NOT** be nil. |
| callbackFunction | function | function to set or replace. This value maybe nil. |

**returns**
| type | description |
| :----- | :----- |
| table | `windowcallback` instance |

### ~~setCallback~~
```lua
function setCallback(self, callback)
```
> **Deprecated**: It's not recommended to modify the wrapper function(s).

set or replace callback table

**paramaters**
| name | type | description |
| :----- | :----- | :----- |
| self | table | `windowcallback` instance. This value **MUST NOT** be nil. |
| callback | table | functions table to wrap windows's callback. This value maybe nil. (wait... you don't need to wrap it if your callback is nil!) |

**returns**
| type | description |
| :----- | :----- |
| table | `windowcallback` instance |

### ~~setSuperCallback~~
```lua
function setSuperCallback(self, callback)
```
> **Deprecated**: Methods have been refactored and this method is no longer valid.

> **Warning**: You may lose the original `Window.Callback`. 

set [Window.Callback](https://developer.android.google.cn/reference/android/view/Window.Callback) to super.

**paramaters**
| name | type | description |
| :----- | :----- | :----- |
| self | table | `windowcallback` instance. This value **MUST NOT** be nil. |
| callback | `Window.Callback` | new `Window.Callback` to super. |

**returns**
| type | description |
| :----- | :----- |
| table | `windowcallback` instance |

### getOriginalWindowCallback
```lua
function getOriginalWindowCallback(self)
```
get the original `Window.Callback` of the window

**paramaters**
| name | type | description |
| :----- | :----- | :----- |
| self | table | `windowcallback` instance. This value **MUST NOT** be nil. |

**returns**
| type | description |
| :----- | :----- |
| `Window.Callback` | the original `Window.Callback` |

### ~~getCallback~~
```lua
function getCallback(self)
```
> **Deprecated**: use `attachToWindow` instead.

get the wrapped `Window.Callback`

**paramaters**
| name | type | description |
| :----- | :----- | :----- |
| self | table | `windowcallback` instance. This value **MUST NOT** be nil. |

**returns**
| type | description |
| :----- | :----- |
| `Window.Callback` | the wrapped `Window.Callback` |

### attachToWindow
```lua
function attachToWindow(self)
```
set wrapped `Window.Callback` to Window

**paramaters**
| name | type | description |
| :----- | :----- | :----- |
| self | table | `windowcallback` instance. This value **MUST NOT** be nil. |

**returns**
| type | description |
| :----- | :----- |
| table | `windowcallback` instance |

### detachToWindow
```lua
function detachToWindow(self)
```
restore the original `Window.Callback` to Window

**paramaters**
| name | type | description |
| :----- | :----- | :----- |
| self | table | `windowcallback` instance. This value **MUST NOT** be nil. |

**returns**
| type | description |
| :----- | :----- |
| table | `windowcallback` instance |

### isAttachedToWindow
```lua
function isAttachedToWindow(self)
```
Determine if the wrapped `Window.Callback` is set to the Window.

**paramaters**
| name | type | description |
| :----- | :----- | :----- |
| self | table | `windowcallback` instance. This value **MUST NOT** be nil. |

**returns**
| type | description |
| :----- | :----- |
| boolean | the wrapped `Window.Callback` is set to the Window |

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

<sub>Some content and code samples on this page are subject to the licenses described in the [Content License](https://developer.android.google.cn/license).</sub>
