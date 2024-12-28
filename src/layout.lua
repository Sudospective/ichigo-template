include "gizmos"

-- if alpha v
if go() then
  -- shader loader
  Shaders = ShaderLoader:new()
end

-- bg
BG = Rect:new()

-- player proxies
Proxies = {}
for _, pn in ipairs(Players) do
  Proxies[pn] = {
    Player = Proxy:new(),
    Judgment = Proxy:new(),
    Combo = Proxy:new(),
  }
end

AddGizmo(Shaders)
AddGizmo(BG)
for _, pn in ipairs(Players) do
  AddGizmo(Proxies[pn].Player)
  AddGizmo(Proxies[pn].Judgment)
  AddGizmo(Proxies[pn].Combo)
end
