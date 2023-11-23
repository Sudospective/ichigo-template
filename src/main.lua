include 'actors'


Shaders = ShaderLoader:new()
BG = Rect:new()

Proxies = {}
for _, pn in ipairs(Players) do
	Proxies[pn] = Proxy:new()
end

R = Rect:new()
I = Image:new()
L = Label:new()
L2 = Label:new()


function init()

	Shaders:LoadShader(SRC_ROOT..'/assets/breathing-colors.frag', 'Colors')

end

function ready()

	BG:FullScreen():SetShader(Shaders.Colors):glow(0, 0, 0, 0.5)

	for _, pn in ipairs(Players) do
		Proxies[pn]:SetTarget(ActorTable[pn])
		ActorTable[pn]:visible(false)
	end

	R:name('GoodBoy')
		:Center()
		:SetSize(96, 96)
		:zoom(0)
		:rotationz(360)
		:easeoutquint(2)
		:zoom(1)
		:rotationz(-45)
	
	I:name('Strawb')
		:Center()
		:Load(SRC_ROOT..'/assets/strawb.png')
		:SetSize(64, 64)
		:zoom(0)
		:easeoutback(0.25)
		:zoom(1)
	
	L:name('Ichigo')
		:LoadFromFont(THEME:GetPathF('Common', 'Normal'))
		:Center()
		:diffuse(0, 0, 0, 1)
		:settext('イチゴ')
		:wag()
		:effectmagnitude(0, 0, 5)
		:zoom(0)
		:easeoutback(0.25)
		:zoom(1)

	L2:name('Template')
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

	R:addrotationz(params.dt * -90)

end


run '/gimmicks.lua'
run '/tweens.lua'
