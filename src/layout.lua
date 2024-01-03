-- gizmos appear in order created

-- shader loader
Shaders = ShaderLoader:new()

-- bg
BG = Rect:new()

-- player proxies
Proxies = {}
for _, pn in ipairs(Players) do
	Proxies['Player'..pn] = Proxy:new()
	Proxies['Judgment'..pn] = Proxy:new()
	Proxies['Combo'..pn] = Proxy:new()
end

-- watermark stuff
GoodBoy = Rect:new()
Strawb = Image:new()
Ichigo = Label:new()
Template = Label:new()
