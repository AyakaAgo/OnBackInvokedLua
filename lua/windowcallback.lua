--[[
Copyright (C) 2018-2022 The AGYS Windmill Open Source Project

	Licensed under the Apache License, Version 2.0 (the "License");
	you may not use this file except in compliance with the License.
	You may obtain a copy of the License at

		http://www.apache.org/licenses/LICENSE-2.0

	Unless required by applicable law or agreed to in writing, software
	distributed under the License is distributed on an "AS IS" BASIS,
	WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
	See the License for the specific language governing permissions and
	limitations under the License.
]]
local _M = {}
local rawget = rawget
local Callback = luajava.bindClass "android.view.Window$Callback"

local function doCallback(self, key, defVal, ...)
    --super
    local super = rawget(self, "superCallback")
    local ret, hasCustom
    --custom
    local funcs = rawget(self, "functions")
    --super function
    local superVoid = super and super[key] --or function()end
    if funcs then
        local func = funcs[key]
        if func then
            hasCustom = true
            --local args={...}
            local f, e = pcall(function(...)
                --invoke superVoid if you need
                ret = func(self, superVoid, ...--[[unpack(args)]])
            end, ...)
            if not f then
                require "trace".print(
                        require "exceptions".runtimeOf(e, "windowcallback", key)
                )
            end
        end
    end
    if superVoid and not hasCustom then
        --important! if is not overridden
        return superVoid(...)
    elseif ret ~= nil then
        return ret
    end
    return defVal
end

-----------------

--the window here is for super its callback
--for set to windows, use attachToWindow
function _M.new(self, window, callbacks)
    self = {}
    self.callback = luajava.new(Callback, {
        dispatchGenericMotionEvent = function(e)
            return doCallback(self, "dispatchGenericMotionEvent", false, e)
        end,
        dispatchKeyEvent = function(e)
            --print(e)
            return doCallback(self, "dispatchKeyEvent", false, e)
        end,
        dispatchKeyShortcutEvent = function(e)
            return doCallback(self, "dispatchKeyShortcutEvent", false, e)
        end,
        dispatchPopulateAccessibilityEvent = function(e)
            return doCallback(self, "dispatchPopulateAccessibilityEvent", false, e)
        end,
        dispatchTouchEvent = function(e)
            return doCallback(self, "dispatchTouchEvent", false, e)
        end,
        dispatchTrackballEvent = function(e)
            return doCallback(self, "dispatchTrackballEvent", false, e)
        end,
        onActionModeFinished = function(m)
            doCallback(self, "onActionModeFinished", nil, m)
        end,
        onActionModeStarted = function(m)
            doCallback(self, "onActionModeStarted", nil, m)
        end,
        onContentChanged = function()
            doCallback(self, "onContentChanged")
        end,
        onCreatePanelMenu = function(id, m)
            return doCallback(self, "onCreatePanelMenu", false, id, m)
        end,
        onProvideKeyboardShortcuts = function(list, m, id)
            doCallback(self, "onCreatePanelMenu", nil, list, m, id)
        end,
        onPointerCaptureChanged = function(hasCapture)
            doCallback(self, "onPointerCaptureChanged", nil, hasCapture)
        end,
        onCreatePanelView = function(id)
            return doCallback(self, "onCreatePanelView", false, id)
        end,
        onMenuItemSelected = function(_, id, m)
            return doCallback(self, "onMenuItemSelected", false, id, m)
        end,
        onMenuOpened = function(id, m)
            return doCallback(self, "onMenuOpened", false, id, m)
        end,
        onPanelClosed = function(id, m)
            doCallback(self, "onPanelClosed", nil, id, m)
        end,
        onPreparePanel = function(id, v, m)
            return doCallback(self, "onPreparePanel", false, id, v, m)
        end,
        onSearchRequested = function(e)
            --if e then
            return doCallback(self, "onSearchRequested", false, e)
            --end
            --return doCallback(self,"onSearchRequested",false)
        end,
        onWindowAttributesChanged = function(lp)
            doCallback(self, "onWindowAttributesChanged", nil, lp)
        end,
        onWindowFocusChanged = function(focused)
            doCallback(self, "onWindowFocusChanged", nil, focused)
        end,
        onWindowStartingActionMode = function(callback, type)
            --if type then
            return doCallback(self, "onWindowStartingActionMode", false, callback, type)
            --end
            --return doCallback(self,"onWindowStartingActionMode",false,callback)
        end,
        onAttachedToWindow = function()
            doCallback(self, "onAttachedToWindow")
        end,
        onDetachedFromWindow = function()
            doCallback(self, "onDetachedFromWindow")
        end
    })
    --lazy init when set
    if window then
        --local originalCallback=window.getCallback()
        --self.window=Window
        --self.windowOriginalCallback=originalCallback
        self.superCallback = window.getCallback()
        --print(self.superCallback)
    end
    self.functions = callbacks
    return setmetatable(self, { __index = _M })
end

------------------

--set or replace a callback table value
function _M.setCallbackFunction(self, key, func)
    local funcs = rawget(self, "functions")
    if funcs == nil then
        funcs = {}
        rawset(self, "functions", funcs)
    end
    funcs[key] = func
    return self
end

--set or replace whole callback table
function _M.setCallbacks(self, calls)
    rawset(self, "functions", calls)
    return self
end

--set another Window$Callback instance
function _M.setSuperCallback(self, call)
    rawset(self, "superCallback", call)
    return self
end

function _M.getOriginalWindowCallback(self)
    return rawget(self, "windowOriginalCallback")
end

--------------------

--get instance
--use attachToWindow instead
--[[function _M.getCallback(self)
return self.callback
end]]

--TODO
--may have multiple, keep last one
function _M.attachToWindow(self, window)
    local pre = self.window
    --_M.detachFromWindow(self)
    if pre == window then
    elseif pre == nil then
        --print("wrap")
        self.windowOriginalCallback = window.getCallback()
        self.window = window.setCallback(self.callback)
    end
    return self
end

--make sure have attached one
function _M.detachFromWindow(self)
    local window = self.window
    if window then
        window.setCallback(rawget(self, "windowOriginalCallback"))
        self.window = nil
        self.windowOriginalCallback = nil
    end
    return self
end

return _M