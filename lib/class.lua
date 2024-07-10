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
  ichi[name] = newspace
  return function(t)
    for k, v in pairs(t) do
      if type(v) == 'table' then
        newspace[k] = DeepCopy(v)
      else
        newspace[k] = v
      end
    end
    return setmetatable(newspace, {__index = newspace})
  end
end
