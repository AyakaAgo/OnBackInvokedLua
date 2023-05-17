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
local _M={}
local _G=_G
local table=_G.table
local tostring,tonumber=_G.tostring,_G.tonumber
local print,debug,type=_G.print,_G.debug,_G.type

local function insert(t,o)
  t[#t+1]=o
end

--------------------

--de/serialization for table

--NOTICE
--you will lose any java objects / functions !

local function addSemi(t)
  local last=t[#t]
  --print(last and type(last)=="string" and last:sub(-1)~=";")
  if last and (type(last)~="string" or last:sub(-1)~=";") then
    insert(t,";")
  end
end

function _M.serialize(data)
  local cache={}
  local t=[]
  --local _n={}
  local space,deep="  ",0
  local backspace=--[[b and ]]"\r\n"--or ""

  local function _ToString(o,_k)
    local ty=type(o)
    --print("type",ty)
    if ty=="number" then
      insert(t,o)
     elseif ty=="string" then
      insert(t,("%q"):format(o))
      --print("new",t[#t])
     elseif ty=="table" then
      local mt=getmetatable(o)
      local tostr=mt and mt.__tostring or nil
      --print(mt and mt.__tostring)
      if tostr then
        insert(t,tostr(o))
       else
        deep=deep+2
        insert(t,"{")
        for k,v in pairs(o) do
          --print(v)
          if v==_G then
            --prevent stack overflow
            insert(t,("%s%s%s=_G;"):format(backspace,space:rep(deep-1),k))
           else--if v~=package.loaded then
            if tonumber(k) then
              k=("[%s]"):format(k)
             else
              k=('["%s"]'):format(k)
            end
            insert(t,("%s%s%s="):format(backspace,space:rep(deep-1),k))
            if v==nil then
              insert(t,"nil;")
             elseif type(v)=="table" then
              local string=tostring(v)
              if cache[string]==nil and cache[v]==nil then
                --cache[string]=v
                local _k=_k and ("%s%s"):format(_k,k) or k
                --fix array index must be integer
                if not xpcall(function()
                    cache[string]=_k
                  end,function()
                    cache[v]=_k
                end) then
                  print("failed serialize",string,_k)
                end
                _ToString(v,_k)
               else
                insert(t,tostring(cache[string]))
                addSemi(t)
              end
             else
              --print("key-value",v,_k)
              _ToString(v,_k)
              --addSemi(t)
              --print(v,_k)
            end
          end
        end
        insert(t,("%s%s}"):format(backspace,space:rep(deep-3)))
        deep=deep-2
      end
     else
      insert(t,tostring(o))
    end
    addSemi(t)
    return t
  end

  return table.concat(_ToString(data))
end

function _M.serializeObject(obj)
  --print(string)
  return string.dump(load(("return %s"):format(
    type(obj)=="table" and _M.serialize(obj) or obj
  )))
end

--table
function _M.deserialize(string)
  local t=_M.deserializeObject(string)
  --TODO
  --refactor to return nil?
  return t and type(t)=="table" and t or {}
end

function _M.deserializeObject(string)
  local f,e=pcall(load(("return %s"):format(string)))
  return f and e or nil
end

-----------------

function _M.getStackTrace()
  local stacks=[]
  for m=2,16 do
    local dbs={}
    local info=debug.getinfo(m)
    if info==nil then
      break
    end
    insert(stacks,dbs)
    dbs.info=info
    local func=info.func
    local nups=info.nups
    local ups={}
    dbs.upvalues=ups
    for n=1,nups do
      local n,v=debug.getupvalue(func,n)
      if v==nil then
        v="nil"
      end
      if n:byte()==40 then
        if ups[n]==nil then
          ups[n]=[]
        end
        insert(ups[n],v)
       else
        ups[n]=v
      end
    end

    local vararg=[]
    local lps={
      vararg=vararg,
      --temporary= {},
    }
    dbs.localvalues=lps
    for n=-1,-255,-1 do
      local k,v=debug.getlocal(m,n)
      if k==nil then
        break
      end
      if v==nil then
        v="nil"
      end
      insert(vararg,v)
    end
    for n=1,255 do
      local n,v=debug.getlocal(m,n)
      if n==nil then
        break
      end
      if v==nil then
        v="nil"
      end
      if n:byte()==40 then
        if lps[n]==nil then
          lps[n]=[]
        end
        insert(lps[n],v)
       else
        lps[n]=v
      end
      --insert(lps,("%s=%s"):format(n,v))
    end
  end
  --NOTICE
  --codetest Activities only
  --print(dump(stacks))
  --print("info="..dump(dbs))
  --print("_ENV="..dump(ups._ENV or lps._ENV))
  return stacks
end

--------------

--wrap for
function _M.print(...)
  --if require"windmill".isDebugBuild() then
  --LuaPrint registered
  --print(...)
  --else
  --NOTICE
  --LuaPrint is not registered in LuaActivity
  --only CodeTestActivity
  local info=[...]
  for k,v in ipairs(info) do
    info[k]=tostring(v)
  end
  this.sendMsg(table.concat(info,"\t"))
  --end
end

return _M