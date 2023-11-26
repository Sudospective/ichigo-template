include 'gizmos'


-- gizmos appear in order created
Shaders = ShaderLoader:new()
BG = Rect:new()
Proxies = {}
for _, pn in ipairs(Players) do
	Proxies['Player'..pn] = Proxy:new()
	Proxies['Judgment'..pn] = Proxy:new()
	Proxies['Combo'..pn] = Proxy:new()
end
R = Rect:new()
I = Image:new()
L = Label:new()
L2 = Label:new()


-- ran right after main.lua is loaded
function init()

	Shaders:LoadShader('Colors', SRC_ROOT..'/assets/breathing-colors.frag')

end

-- ran after all actors are ready
function ready()

	BG:FullScreen():SetShader(Shaders.Colors):glow(0, 0, 0, 0.5)

	for _, pn in ipairs(Players) do
		Proxies['Player'..pn]:SetTarget(ActorTable[pn])
		Proxies['Judgment'..pn]
			:SetTarget(ActorTable[pn]:GetChild('Judgment'))
			:xy(ActorTable[pn]:GetX(), SCREEN_CENTER_Y)
			:zoom(SCREEN_HEIGHT / 480)
		Proxies['Combo'..pn]
			:SetTarget(ActorTable[pn]:GetChild('Combo'))
			:xy(ActorTable[pn]:GetX(), SCREEN_CENTER_Y)
			:zoom(SCREEN_HEIGHT / 480)
		ActorTable[pn]:visible(false)
		ActorTable[pn]:GetChild('Judgment'):visible(false):diffusealpha(0.5):sleep(9e9)
		ActorTable[pn]:GetChild('Combo'):visible(false):diffusealpha(0.5):sleep(9e9)
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

-- ran on input event
function input(event)

	-- handle input here (good for minigames)

end

-- ran on each frame
function update(params)

	-- update stuff here

end

-- ran on each draw
function draw()

	-- draw stuff here

end


run '/gimmicks.lua'
run '/tweens.lua'
