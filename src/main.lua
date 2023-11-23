include 'actors'


local shaders = ShaderLoader:new()
local bg = Rect:new()

local proxy = {}
for _, pn in ipairs(Players) do
	proxy[pn] = Proxy:new()
end

local r = Rect:new()
local i = Image:new()
local l = Label:new()
local l2 = Label:new()


function init()

	shaders:LoadShader(SRC_ROOT..'/assets/breathing-colors.frag', 'Colors')

end

function ready()

	bg:FullScreen():SetShader(shaders.Colors):glow(0, 0, 0, 0.5)

	for _, pn in ipairs(Players) do
		proxy[pn]:SetTarget(ActorTable[pn])
		ActorTable[pn]:visible(false)
	end

	r:name('GoodBoy')
		:Center()
		:SetSize(96, 96)
		:zoom(0)
		:rotationz(360)
		:easeoutquint(2)
		:zoom(1)
		:rotationz(-45)
	
	i:name('Strawb')
		:Center()
		:Load(SRC_ROOT..'/assets/strawb.png')
		:SetSize(64, 64)
		:zoom(0)
		:easeoutback(0.25)
		:zoom(1)
	
	l:name('Ichigo')
		:LoadFromFont(THEME:GetPathF('Common', 'Normal'))
		:Center()
		:diffuse(0, 0, 0, 1)
		:settext('イチゴ')
		:wag()
		:effectmagnitude(0, 0, 5)
		:zoom(0)
		:easeoutback(0.25)
		:zoom(1)

	l2:name('Template')
		:LoadFromFont(THEME:GetPathF('Common', 'Normal'))
		:Center()
		:addy(96)
		:settext('Ichigo Template')
		:cropright(1)
		:sleep(1)
		:linear(0.25)
		:cropright(0)

end

function update(params)

	r:addrotationz(params.dt * -90)

end


ease {9, function()
		
	r:stoptweening()
		:easeinquad(0.5)
		:addrotationz(-360)
		:zoom(0)
	
	i:stoptweening()
		:easeinback(0.25)
		:zoom(0)
	
	l:stoptweening()
		:easeinback(0.25)
		:zoom(0)
	
	l2:stoptweening()
		:linear(0.25)
		:cropright(1)
	
end}


run '/gimmicks.lua'
