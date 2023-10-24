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
--wrapper for OnBackInvoked/AnimationCallback and onKeyUp(KeyCode Back)
--sample in main.lua and readme.md

local _M = {
    --you can hard-coded your priority without accessing these constants
    PRIORITY_DEFAULT = 0,
    PRIORITY_OVERLAY = 1000000,
}

local Build = require "androidbuild"
local dispatcherAvailable = Build.isAtLeastT()
local animationCallbackAvailable = Build.isAtLeastU()

--[[
predictive back gesture Q&A

Q: How to enable this feature for my application?
A: add attribute android:enableOnBackInvokedCallback="true"
   to your manifest <application> element

Q: How can I intercept and stop intercept for back gesture?
A: use #register or #registerIfUnregistered method to intercept, see method comment
   for detail usage. They are a bit different from AndroidX library but the same functionality.
   use #unregister to stop intercept.

   NOTICE: don't return true/false in intercept callback, we don't intercept events by return
           value and make sure you #unregister if things done otherwise the user won't be able to
           navigate up

   NOTICE: unless you #unregister or #setEnabled with false to a callback, they will always
           intercept back events, but onKeyUp(Down) may not.

Q: Will it get callback if predictive back animation is disabled?
A: Yes. If you declared callback enabled in manifest, you will always receive then. The option
   in Developer Option only affect visual effect.
            
   NOTICE: If you declared callback enabled in manifest and running in API level 33 or higher platform,
           you will not get onKeyUp(Down) with KEYCODE_BACK event and onBackPressed, but KEYCODE_BACK
           isn't deprecated. (see Q4)

Q: Should I migrate all KEYCODE_BACK to this callback?
A: No, you will get KEYCODE_BACK in some cases, such as a View added by WindowManager#addView.
   But if you are using Activity or Dialog, you should.

more information https://developer.android.google.cn/guide/navigation/predictive-back-gesture
]]

--NOTICE
--new an instance with system class directly cause WRONG class cast (userdata, Proxy)
--and CAN NOT be unregistered

--NOTICE
--see lua/import
--if you have changed class path, don't forget to change it
--if your luajava has right cast for override/new, you can change to import system class
---@type table<function, "java.lang.Class">
local WindowFunctional = dispatcherAvailable and imports "com.windmill.window.*"
        --Android Sv2 and lower
        or require "windowcallback"

--configurations
---@type table<table<function>>
local windowCallbacks = {} --TODO modify to [] if your lua support this syntax
--back interception callbacks
--table/function in Android 13-, OnBackInvoked/AnimationCallback in Android 13+(include)
---@type table<table<table, function>>
local callbacks = {} --TODO modify to [] if your lua support this syntax
---@type table<string>
local tags = {} --TODO modify to [] if your lua support this syntax
---@type table<boolean>
local enables = {} --TODO modify to [] if your lua support this syntax

--[[
changed paramaters

original
onBackInvoked()

changed to
onBackInvoked(_M,ctx,tag)
@_M  backdispatcher module, use to unregister
@ctx callback registered with, Activity
@tag callback tag
]]

---@param ctx "Activity/Dialog/OnBackInvokedDispatcher instance"
---@param id number hashCode of ctx
---@return number max priority and associated callback
local function max(ctx, id)
    local maxPrior--=0
    --callbacks should be exists
    local data = callbacks[id]
    for k in pairs(data) do
        if (maxPrior == nil or k > maxPrior) and _M.isEnabled(ctx, tags[id][k]) then
            maxPrior = k
        end
    end
    if maxPrior then
        return maxPrior, data[maxPrior]
    end
end

---@param ctx "Activity/Dialog/OnBackInvokedDispatcher instance"
---@param id number hashCode of ctx
---@return boolean if has callback
local function callLast(ctx, id)
    --only when we have at least one callback registered
    --this callback will be registered to window
    --otherwise means data always non-nil
    local prior, data = max(ctx, id)
    --NOTICE
    --to stop intercept, call #unregister
    --sync behavior with OnBackInvoked/AnimationCallback
    --sync parameters
    if prior then
        (type(data) ~= "table" and data or data.onBackInvoked)(_M, ctx, tags[id][prior])
        return true
    end
end

---@param ctx "Activity/Dialog/OnBackInvokedDispatcher instance"
---@return number hashCode
local function wrapWindowCallback(ctx)
    local id = ctx.hashCode()
    local callback = windowCallbacks[id]
    if callback == nil then
        --TODO
        --NOTICE
        --you should re-register if something also used windowcallback module
        callback = WindowFunctional.new(ctx.getWindow(), {
            dispatchKeyEvent = function(_, super, e)
                --onKeyUp
                --TODO if your lua support lambda syntax
                return e.getKeyCode() == 4 and e.getAction() == 1--KeyEvent.KEYCODE_BACK and KeyEvent.ACTION_UP
                        and callLast(ctx, id)
                        or super(e)--other key event
            end
        })
        windowCallbacks[id] = callback
    end
    --don't worry about to call this multiple times
    callback:attachToWindow()
    return id
end

---------------------

---@param id number hashCode of Activity/Dialog
---@param tag string callback tag
---@param priority number callback with larger priority will get notified first
---@param checkDuplicate boolean true to throw if @tag or @priority exists
---@return table<function, "android.window.OnBackInvokedCallback"> callbacks registered to the dispatcher
local function registerCheck(id, tag, priority, checkDuplicate)
    local tagged = tags[id]
    if tagged == nil then
        tagged = {} --TODO modify to [] if your lua support this syntax
        tags[id] = tagged
    elseif checkDuplicate then
        for k, v in pairs(tagged) do
            --throw exception to stop followup logic
            if k == priority then
                require "exceptions".runtime(("priority %s already exist."):format(k), "backdispatcher", "register")
            elseif v == tag then
                require "exceptions".runtime(("tag \"%s\" already exist."):format(v), "backdispatcher", "register")
            end
        end
    end
    tagged[priority] = tag
    local calls = callbacks[id]
    if calls == nil then
        calls = {} --TODO modify to [] if your lua support this syntax
        callbacks[id] = calls
    end
    local en = enables[id]
    if en == nil then
        en = {}
        enables[id] = en
    end
    en[tag] = true
    return calls
end

---@param ctx "Activity/Dialog/OnBackInvokedDispatcher instance"
---@param tag string callback tag
---@param priority number callback with larger priority will get notified first
---@param checkDuplicate boolean true to throw if @tag or @priority exists
---@return table<function> backdispatcher module for tail call
local function register(ctx, tag, callback, priority, checkDuplicate)
    --[[if tag==nil then
      --generate a tag
      --if you implement this, you may need to return the tag for unregister
    end]]
    if priority == nil then
        priority = _M.nextPriority(ctx)
    elseif priority < 0 then
        require "exceptions".runtime(("priority should be positive."):format(v), "backdispatcher", "register")
    end
    --T+
    if dispatcherAvailable then
        local isTable = type(callback) == "table"
        local wrapperCallback
        if isTable then
            --[[wrapperCallback=table.clone(callback)
                wrapperCallback.onBackInvoked=function()
                --NOTICE
                --sync parameters
                callback.onBackInvoked(_M,ctx,tag--[[,prior] ])
            end]]
            --NOTICE
            --DO NOT change callback functions after registered
            local back = callback.onBackInvoked
            wrapperCallback = callback
            --no wrap for other methods
            wrapperCallback.onBackInvoked = function()
                --NOTICE
                --sync parameters
                back(_M, ctx, tag--[[,prior]])
            end
        else
            wrapperCallback = {
                onBackInvoked = function()
                    callback(_M, ctx, tag--[[,prior]])
                end
            }
        end
        --choose class to implement
        local instance = luajava.override(animationCallbackAvailable and isTable and table.size(callback) > 1
                and WindowFunctional.BackAnimationCallback
                or WindowFunctional.BackInvokedCallback, wrapperCallback)
        ctx.getOnBackInvokedDispatcher().registerOnBackInvokedCallback(priority, instance)
        registerCheck(ctx.hashCode(), tag, priority, checkDuplicate)[priority] = instance
    else
        registerCheck(wrapWindowCallback(ctx), tag, priority, checkDuplicate)[priority] = callback
    end
    return _M
end

---register a OnBackInvoked/AnimationCallback
---@param ctx "Activity/Dialog/OnBackInvokedDispatcher instance"
---@param tag string callback name for unregister, must be non-nil
---@param callback any<table, function> function corresponding to OnBackInvoked/AnimationCallback#onBackInvoked or table include any method in OnBackInvoked/AnimationCallback. **DO NOT** change table values(functions) after registered (suggested)
---@param priority number larger priority will get callback first, **CAN NOT** be negative, leave nil to +1 to previous
---@throws   exceptions.runtime if tag or priority already exists
---@return table<function> backdispatcher module for tail call
function _M.register(ctx, tag, callback, priority)
    return register(ctx, tag, callback, priority, true)
end

---register if a OnBackInvoked/AnimationCallback doesn't exists
---@param ctx "Activity/Dialog/OnBackInvokedDispatcher instance"
---@param tag string callback name for unregister, must be non-nil
---@param callback any<table, function> function corresponding to OnBackInvoked/AnimationCallback#onBackInvoked or table include any method in OnBackInvoked/AnimationCallback. **DO NOT** change table values(functions) after registered (suggested)
---@param priority number larger priority will get callback first, **CAN NOT** be negative, leave nil to +1 to previous
---@return table<function> backdispatcher module for tail call
function _M.registerIfUnregistered(ctx, tag, callback, priority)
    local tagged = tags[ctx.hashCode()]
    if tagged then
        for k, v in pairs(tagged) do
            if k == priority or v == tag then
                return _M
            end
        end
    end
    return register(ctx, tag, callback, priority, false)
end

--NOTICE
--once you call #register(Xxx) to intercept a back event you MUST call #unregister if no longer needed
--we DO NOT intercept by true/false return value (sync with OnBackInvoked/AnimationCallback)

---unregister a callback to stop interception, you can call this in #onBackInvoked
---@param ctx "Activity/Dialog/OnBackInvokedDispatcher instance"
---@param tag string callback name
---@return table<function> backdispatcher module for tail call
function _M.unregister(ctx, tag)
    local id = ctx.hashCode()
    local tagged = tags[id]
    if tagged then
        local prior
        for k, v in pairs(tagged) do
            if v == tag then
                prior = k
                break
            end
        end
        --tag exist
        if prior then
            local calls = callbacks[id]
            --T+
            if dispatcherAvailable then
                ctx.getOnBackInvokedDispatcher().unregisterOnBackInvokedCallback(calls[prior])
            end
            calls[prior], tagged[prior] = nil
            if table.size(calls) == 0 then
                if not dispatcherAvailable then
                    --restore the original callback
                    windowCallbacks[id]:detachFromWindow()
                end
                callbacks[id] = nil
                tags[id] = nil
                enables[id] = nil
            end
        end
    end
    return _M
end

-------------------

--NOTICE
--check dispatcherAvailable before calling this
---@param en table<boolean> enable states
---@param id number dispatcher hashCode
local function enableCallback(en, id)
    local disabledCount = 0
    for _, v in pairs(en) do
        if v then
            windowCallbacks[id]:attachToWindow()
            return
        end
        disabledCount = 1 + disabledCount
    end
    if disabledCount == table.size(en) then
        windowCallbacks[id]:detachFromWindow()
    end
end

---@param ctx "Activity/Dialog/OnBackInvokedDispatcher instance"
---@param tag string callback name
---@param enabled boolean enable state of @tag
---@param id number dispatcher hashCode
---@param en table<boolean> enable states
---@param checkCallback boolean check and register WindowCallback
local function setEnabled(ctx, tag, enabled, id, en, checkCallback)
    local prev = en[tag]
    if prev == nil then
        --prevent re-re/unregister in Android 13+
    elseif prev ~= enabled then
        en[tag] = enabled
        --T+
        if dispatcherAvailable then
            local prior
            local tagged = tags[id]
            for k, v in pairs(tagged) do
                if v == tag then
                    prior = k
                    break
                end
            end
            if prior == nil then
                return
            end
            local callback = callbacks[id][prior]
            --stop intercept
            if enabled then
                ctx.getOnBackInvokedDispatcher().registerOnBackInvokedCallback(prior, callback)
            else
                --DO NOT remove in #callbacks
                ctx.getOnBackInvokedDispatcher().unregisterOnBackInvokedCallback(callback)
            end
        else
            --no need to remove below 13
            --see #isEnabled
            if checkCallback then
                enableCallback(en, id)
            end
        end
    end
end

--@Deprecated test only
--[[en/disable all existing callbacks whatever they are enabled or not
--If you add a callback later, you need to manually set its enabled state
function _M.setAllEnabled(ctx,enabled)
  local id=ctx.hashCode()
  local tagged=tags[id]
  if tagged then
    local en=enables[id]
    for _,tag in pairs(tagged) do
      setEnabled(ctx,tag,enabled,id,en)
    end
    if not dispatcherAvailable then
      enableCallback(en,id)
    end
  end
  return _M
end]]

---@param ctx "Activity/Dialog/OnBackInvokedDispatcher instance"
---@param tag string callback to set enabled state
---@param enabled boolean
---@return table<function> backdispatcher module for tail call
function _M.setEnabled(ctx, tag, enabled)
    local id = ctx.hashCode()
    local en = enables[id]
    if en then
        setEnabled(ctx, tag, enabled, id, en, true)
    end
    return _M
end

---@param ctx "Activity/Dialog/OnBackInvokedDispatcher instance"
---@param tag string callback to set enabled state
---@return boolean false if tag is disabled or not registered
function _M.isEnabled(ctx, tag)
    local en = enables[ctx.hashCode()]
    return en and en[tag]
end

-------------------------

---@param ctx "Activity/Dialog/OnBackInvokedDispatcher instance"
---@return table<string>
function _M.getRegisteredTags(ctx)
    local tagged = tags[ctx.hashCode()]
    local registered = {} --TODO modify to [] if your lua support this syntax
    if tagged then
        for _, v in pairs(tagged) do
            registered[#registered + 1] = v
        end
    end
    return registered
end

---@param ctx "Activity/Dialog/OnBackInvokedDispatcher instance"
---@return table<number>
function _M.getRegisteredPriorities(ctx)
    local tagged = tags[ctx.hashCode()]
    local priors = {} --TODO modify to [] if your lua support this syntax
    if tagged then
        for k in pairs(tagged) do
            priors[#priors + 1] = k
        end
    end
    return priors
end

---@param ctx "Activity/Dialog/OnBackInvokedDispatcher instance"
---@param prior number priority to check is registered
---@return boolean
function _M.isPriorityRegistered(ctx, prior)
    local tagged = tags[ctx.hashCode()]
    if tagged then
        for k in pairs(tagged) do
            if k == prior then
                return true
            end
        end
    end
    return false
end

---@param ctx "Activity/Dialog/OnBackInvokedDispatcher instance"
---@param tag string tag to check is registered
---@return boolean
function _M.isTagRegistered(ctx, tag)
    local tagged = tags[ctx.hashCode()]
    if tagged then
        for _, v in pairs(tagged) do
            if v == tag then
                return true
            end
        end
    end
    return false
end

-----------------------

---@param ctx "Activity/Dialog/OnBackInvokedDispatcher instance"
---@return boolean if a callback exists
function _M.hasCallback(ctx)
    return tags[ctx.hashCode()] ~= nil
end

--@Deprecated access isBackGesturePredictable instead
--[[function _M.isBackGesturePredictable()
  return dispatcherAvailable
end]]

_M.isBackGesturePredictable = dispatcherAvailable

_M.isBackGestureAnimationPredictable = animationCallbackAvailable

-------------------------

---get the next priority that does not conflict with existing callbacks, larger priority will get callback first
---@param ctx "Activity/Dialog/OnBackInvokedDispatcher instance"
---@param base number non-negative number(int), expected lowest priority
---@return number if @base is nil, return next priority of existing callbacks; if non-nil, return the larger one of @base or the next priority of existing callbacks
function _M.nextPriority(ctx, base)
    local tagged = tags[ctx.hashCode()]
    local maxPrior = 0
    if tagged then
        --local d
        for k in pairs(tagged) do
            if k > maxPrior then
                maxPrior = k
            end
        end
        maxPrior = maxPrior + 1
    end
    return base and math.max(base, maxPrior) or maxPrior
end

--[[
NOTICE
onBackPressed/onKeyUp(Down) will be ignored
]]
---go back without a actual key event
---@param ctx "Activity/Dialog/OnBackInvokedDispatcher instance"
---@param finish boolean end this OnBackInvokedDispatcher instance if no further go back
---@return boolean true if there are still any callbacks registered, otherwise you can finish the Activity
function _M.back(ctx, finish)
    local id = ctx.hashCode()
    if callbacks[id] then
        callLast(ctx, id)
        return true
    elseif finish then
        if luajava.instanceof(ctx, luajava.bindClass "android.app.Activity") then
            ctx.finish()
        else
            ctx.dismiss()
        end
    end
    return false
end

return _M