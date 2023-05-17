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
--local Build=luajava.bindClass"android.os.Build"
local VERSION = luajava.bindClass "android.os.Build$VERSION"
--local VERSION_CODES=luajava.bindClass"android.os.Build$VERSION_CODES"
local android_sdk = VERSION.SDK_INT
local _M = {
    SDK_INT = android_sdk,
    --constant in SdkExtensions
    --AD_SERVICES=1000000,
}

-------------------------

local function isAtLeastPreReleaseCodename(codename)
    local systemCodename = VERSION.CODENAME
    if systemCodename == "REL" then
        return false
    end
    return codename:upper() >= systemCodename:upper()
end

--TODO
--if your app supports M- versions

--6
--[[function _M.isAtLeastM()
    return android_sdk>=23
end]]

--7
function _M.isAtLeastN()
    return android_sdk >= 24
end

--7.1
function _M.isAtLeastNMR1()
    return android_sdk >= 25
end

--8
function _M.isAtLeastO()
    return android_sdk >= 26
end

--8.1
function _M.isAtLeastOMR1()
    return android_sdk >= 27
end

--9
function _M.isAtLeastP()
    return android_sdk >= 28
end

--10
function _M.isAtLeastQ()
    return android_sdk >= 29
end

--11
function _M.isAtLeastR()
    return android_sdk >= 30
end

--print(VERSION.CODENAME)

--12
function _M.isAtLeastS()
    return android_sdk >= 31
            or (android_sdk >= 30 and isAtLeastPreReleaseCodename("S"))
end

--12 large
function _M.isAtLeastSv2()
    return android_sdk >= 32
            or (android_sdk >= 31 and isAtLeastPreReleaseCodename("Sv2"))
end

--13
function _M.isAtLeastT()
    return android_sdk >= 33
            or (android_sdk >= 32 and isAtLeastPreReleaseCodename("Tiramisu"))
end

--14
--NOTICE
--prerelease version
function _M.isAtLeastU()
    return android_sdk >= 34
            or (android_sdk >= 33 and isAtLeastPreReleaseCodename("UpsideDownCake"))
end

-------------------

local function isAtMostPreReleaseCodename(codename)
    local systemCodename = VERSION.CODENAME
    if systemCodename == "REL" then
        return true
    end
    return codename:upper() < systemCodename:upper()
end

--6
--[[function _M.isAtMostM()
    return android_sdk<=23
end]]

--7
function _M.isAtMostN()
    return android_sdk <= 24
end

--7.1
function _M.isAtMostNMR1()
    return android_sdk <= 25
end

--8
function _M.isAtMostO()
    return android_sdk <= 26
end

--8.1
function _M.isAtMostOMR1()
    return android_sdk <= 27
end

--9
function _M.isAtMostP()
    return android_sdk <= 28
end

--10
function _M.isAtMostQ()
    return android_sdk <= 29
end

--11
function _M.isAtMostR()
    if android_sdk == 30 then
        return isAtMostPreReleaseCodename("S")
    end
    return android_sdk < 30
end

--TODO
--test isAtMostPreReleaseCodename

--12
function _M.isAtMostS()
    if android_sdk == 31 then
        return isAtMostPreReleaseCodename("Sv2")
    end
    return android_sdk < 31
end

--12 large
function _M.isAtMostSv2()
    if android_sdk == 32 then
        return isAtMostPreReleaseCodename("Tiramisu")
    end
    return android_sdk < 32
end

--13
function _M.isAtMostT()
    if android_sdk == 33 then
        return isAtMostPreReleaseCodename("UpsideDownCake")
    end
    return android_sdk < 33
end

--14
--NOTICE
--prerelease version
function _M.isAtMostU()
    return android_sdk <= 34
end

-----------------------

--@return versions int: immutable 
function _M.getAllSdkExtensionVersions()
    return _M.isAtLeastS() and luajava.bindClass "android.os.ext.SdkExtensions"
                                      .getAllExtensionVersions()
            or []
end

function _M.getSdkExtensionVersion(sdk_int)
    if _M.isAtLeastR() then
        return luajava.bindClass "android.os.ext.SdkExtensions"
                      .getExtensionVersion(sdk_int)
    end
    return -1
end

return setmetatable(_M, { __index = function(_M, key)
    --NOTICE
    --members may have same name
    local value--=rawget(_M,key)
    --print(key,"in table?",value~=nil)
    --if value==nil then
    if not xpcall(function()
        value = luajava.bindClass "android.os.Build"[key]
    end, function()
        value = VERSION[key]
    end) then
        pcall(function()
            value = luajava.bindClass "android.os.Build$VERSION_CODES"[key]
        end)
    end
    --end
    return value
end })