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
--NOTICE
--modified, see TODO and NOTICE comments

--NOTICE
--TODO
--do not use directly, migrate with your own import.lua

local _G=_G
local require=_G.require
local table=_G.table--require "table"
--local context=_G.activity or _G.service
--print(activity,service)
local luajava=_G.luajava
--local insert=table.insert
local bindClass=luajava.bindClass

local function insert(t,d)
  t[#t+1]=d
end

local function import_dex_class(packagename)
  local res,class=pcall(bindClass,packagename)
  if res then
    return class
  end
end

--TODO
--modify to your necessary packages
local packages=[
  'android.widget.',
  'android.view.',
  "android.content.",
  'com.androlua.',
  "android.os.",
  "android.app.",
  "android.net.",
  "android.util.",
  "java.io.",
  'java.lang.',
  'java.util.',
  "android.animation.",
  "android.view.animation.",
  "android.graphics.",
  "android.graphics.drawable."
]

--NOTICE
--ONLY accept .* package import
--if you have a specific class use luajava.bindClass
function _G.import(package)
  packages[#packages+1]=package:sub(0,-2)
end

function _G.imports(package)
  package=package:sub(0,-2)
  return setmetatable({},{
    __index=function(T,classname)
      local class=import_dex_class(
        ("%s%s"):format(package,classname)
      )
      T[classname]=class
      return class
    end
  })
end

_G.setmetatable(_G,{
  __index=function(T,classname)
    local p
    for _,pack in ipairs(packages) do
      p=import_dex_class(
        ("%s%s"):format(pack,classname)
      )
      if p then
        T[classname]=p
        break
      end
    end
    return p
  end
})

_G.loadlayout=require"loadlayout"

--return _G