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
	Proxies[pn] = {}
	Proxies[pn].Player = Proxy:new()
	Proxies[pn].Judgment = Proxy:new()
	Proxies[pn].Combo = Proxy:new()
end
