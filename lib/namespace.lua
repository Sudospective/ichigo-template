local ichi = ...

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
