-- class.lua

-- Adapted from 32log to work with Ichigo Template
-- Original class function for LOVE written by ishkabible
-- Namespace function written by Sudospective

local ichi = ...

function ichi.class(name)
  local newclass={}
  ichi[name]=newclass
  newclass.__members={}
  newclass.__class = name
  function newclass.define(class,members)
    for k,v in pairs(members) do
      class.__members[k]=v
    end
  end
  function newclass.extends(class,base)
    class.super=ichi[base]
    if class.super == nil then
      error("Class "..base.." does not exist.")
      return
    end
    for k,v in pairs(ichi[base].__members) do
      class.__members[k]=v
    end
    return setmetatable(class,{__index=ichi[base],__call=class.define})
  end
  function newclass.new(class,...)
    local object={}
    for k,v in pairs(class.__members) do
      object[k]=v
    end
    setmetatable(object,{__index=class})
    if object.__init then
      object:__init(...)
    end
    return object
  end
  return setmetatable(newclass,{__call=newclass.define})
end

function ichi.namespace(name)
  local newspace = {}
  ichi[name] = ichi[name] or newspace
  if ichi[name].__class then
    error("Cannot use class as namespace.")
    return
  end
  return function(t)
    for k, v in pairs(t) do
      if type(v) == 'table' then
        ichi[name][k] = DeepCopy(v)
      else
        ichi[name][k] = v
      end
    end
    return setmetatable(ichi[name], {__index = ichi})
  end
end

function ichi.using(namespace)
  return function(func)
    if not ichi[namespace] then
      error("Namespace does not exist.")
      return
    end
    setfenv(func, ichi[namespace])
    func()
  end
end

function ichi.include(name)
  local data = assert(loadfile(ichi.SONG_ROOT.."include/"..name..".lua"))
  if data == nil then
    lua.ReportScriptError("Library \""..name.."\" is empty or otherwise unavailable.")
  end
  ichi(data)()
end
