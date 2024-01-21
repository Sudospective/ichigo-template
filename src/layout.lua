-- gizmos appear in order created

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
    Combo = Proxy:new()
  }
end
