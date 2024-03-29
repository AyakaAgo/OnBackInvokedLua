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

---@param excName string @NonNull, exception type name, ValueNotFoundException -> ValueNotFound
---@param msg string @NonNull, detailed information
---@param module string @Nullable, where this exception is thrown
---@param method string @Nullable, where this exception is thrown from @module
---@return string a combined exception message
local function formatMessage(excName, msg, module, method)
    local tag
    if module and method then
        tag = (": %s#%s, "):format(module, method)
    else
        local t = module or method
        if t then
            tag = (": %s, "):format(t)
        else
            tag = ""
        end
    end
    local message
    if msg then
        if tag == "" then
            tag = ": "
        end
        message = msg
    else
        message = ""
    end
    return ("%sException%s%s"):format(excName, tag, message)
end

---error wrapper
---@param msg string @NonNull, error message
---@param level number @Nullable, error message information level
local function throwMsg(msg, level)
    error(msg, level or 2)
end

---@param excName string @NonNull, exception type name, ValueNotFoundException -> ValueNotFound
---@param msg string @NonNull, detailed information
---@param module string @Nullable, where this exception is thrown
---@param method string @Nullable, where this exception is thrown
---@param level number @Nullable, error message information level
local function throw(excName, msg, module, method, level)
    throwMsg(formatMessage(excName, msg, module, method), level)
end

----------------------

--[[
@... @message,@module,@method
  @message error information
  @module where the error from
  @method where the error from the module
]]

function _M.illegalArgumentOf(...)
    return formatMessage("IllegalArgument", ...)
end

function _M.nullPointerOf(...)
    return formatMessage("NullPointer", ...)
end

function _M.illegalStateOf(...)
    return formatMessage("IllegalState", ...)
end

function _M.unsupportedOperationOf(...)
    return formatMessage("UnsupportedOperation", ...)
end

function _M.securityOf(...)
    return formatMessage("Security", ...)
end

function _M.fileNotFoundOf(...)
    return formatMessage("FileNotFound", ...)
end

function _M.runtimeOf(...)
    return formatMessage("Runtime", ...)
end

--------------------

--tables
function _M.negativeIndexOf(...)
    return formatMessage("NegativeIndex", ...)
end

function _M.indexOutOfBoundsOf(...)
    return formatMessage("IndexOutOfBounds", ...)
end

---------------------

local tmp = {}
for k, v in pairs(_M) do
    tmp[k:match("(.-)Of")] = function(msg, module, method, level)
        throwMsg(v(msg, module, method), level)
    end
end

for k, v in pairs(tmp) do
    _M[k] = v
end

table.clear(tmp)
tmp = nil

----------------------

_M.throw = throw

_M.formatMessage = formatMessage

return _M