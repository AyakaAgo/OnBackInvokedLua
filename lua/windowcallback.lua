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

---@param self table<function> table created from _M.new()
---@param key string void name in WindowCallback
---@param defVal any alternative return value
---@return any
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
            local f, e = pcall(function(...)
                --invoke superVoid if you need
                ret = func(self, superVoid, ...)
            end, ...)
            if not f then
                require "exceptions".runtime(e, "windowcallback", key)
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

--call #attachToWindow to apply wrapped callback
---@param window "android.view.Window" callback to super
---@param callbacks table<function> custom callback
function _M.new(window, callbacks)
    local self
    self = setmetatable({
        callback = luajava.new(Callback, {
            dispatchGenericMotionEvent = function(e)
                return doCallback(self, "dispatchGenericMotionEvent", false, e)
            end,
            dispatchKeyEvent = function(e)
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
        }),
        attached = false,
        superCallback = window.getCallback(),
        window = window,
        functions = callbacks
    }, { __index = _M })
    return self
end

------------------

---@Deprecated
---set or replace a callback table value
--[[function _M.setCallbackFunction(self, key, func)
    local funcs = rawget(self, "functions")
    if funcs == nil then
        funcs = {}
        rawset(self, "functions", funcs)
    end
    funcs[key] = func
    return self
end]]

---@Deprecated
---set or replace whole callback table
--[[function _M.setCallback(self, calls)
    rawset(self, "functions", calls)
    return self
end]]

---@Deprecated
--[[function _M.setSuperCallback(self, call)
    rawset(self, "superCallback", call)
    return self
end]]

---@param self table<function> table created from _M.new()
function _M.getOriginalWindowCallback(self)
    return rawget(self, "superCallback")
end

--------------------

---@Deprecated
---get instance. use attachToWindow instead
--[[function _M.getCallback(self)
    return self.callback
end]]

---@param self table<function> table created from _M.new()
function _M.attachToWindow(self)
    if not rawget(self, "attached") then
        self.attached = true
        rawget(self, "window").setCallback(self.callback)
    end
    return self
end

---@param self table<function> table created from _M.new()
function _M.detachFromWindow(self)
    if rawget(self, "attached") then
        rawget(self, "window").setCallback(rawget(self, "superCallback"))
        self.attached = false
    end
    return self
end

---@param self table<function> table created from _M.new()
function _M.isAttachedToWindow(self)
    return rawget(self, "attached")
end

return _M