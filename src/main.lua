include 'gizmos'


-- gizmos appear in order created
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


-- initialize custom objects here
function init()

	Shaders:LoadShader('Colors', SRC_ROOT..'/assets/breathing-colors.frag')

end

-- initialize gizmos and actors
function ready()

	BG:FullScreen():SetShader(Shaders.Colors):glow(0, 0, 0, 0.5)

	for _, pn in ipairs(Players) do
		Proxies[pn]:SetTarget(ActorTable[pn])
		ActorTable[pn]:visible(false)
		Options[pn]:NotePathDrawMode('DrawMode_PolyLineStrip')
	end

	R:name('GoodBoy')
		:Center()
		:SetSize(96, 96)
		:zoom(0)
		:rotationz(360)
		:shadowcolor(0, 0, 0, 0.5)
		:shadowlengthy(3)
	
	I:name('Strawb')
		:Center()
		:Load(SRC_ROOT..'/assets/strawb.png')
		:SetSize(64, 64)
		:zoom(0)
	
	L:name('Ichigo')
		:LoadFromFont(THEME:GetPathF('Common', 'Normal'))
		:Center()
		:diffuse(0, 0, 0, 1)
		:settext('イチゴ')
		:wag()
		:effectmagnitude(0, 0, 5)
		:zoom(0)

	L2:name('Template')
		:LoadFromFont(THEME:GetPathF('Common', 'Normal'))
		:Center()
		:addy(96)
		:settext('Ichigo Template')
		:cropright(1)
		:shadowcolor(0, 0, 0, 0.5)
		:shadowlengthy(3)

end

-- please delete these if unused to improve performance
function input(event)

	-- handle input here (good for minigames)

end

function update(params)

	-- update stuff here

end

function draw()

	-- draw stuff here

end


run '/gimmicks.lua'
run '/tweens.lua'
