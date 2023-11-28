include 'gizmos'


-- gizmos appear in order created
Shaders = ShaderLoader:new()
BG = Rect:new()

Proxies = {}
loop {Players, function(i, pn)
	Proxies['Player'..pn] = Proxy:new()
	Proxies['Judgment'..pn] = Proxy:new()
	Proxies['Combo'..pn] = Proxy:new()
end}

-- watermark stuff
GoodBoy = Rect:new()
Strawb = Image:new()
Ichigo = Label:new()
Template = Label:new()


-- ran right after main.lua is loaded
function init()

	do Shaders
		:LoadShader('Colors', SRC_ROOT..'/assets/breathing-colors.frag')
	end

end

-- ran after all actors are ready
function ready()

	-- background
	do BG
		:FullScreen()
		:SetShader(Shaders.Colors)
		:glow(0, 0, 0, 0.5)
	end

	-- player proxies
	loop {Players, function(i, pn)

		do Proxies['Player'..pn]
			:SetTarget(Actors[pn])
		end
		do Proxies['Judgment'..pn]
			:SetTarget(Actors[pn]:GetChild('Judgment'))
			:xy(Actors[pn]:GetX(), SCREEN_CENTER_Y)
			:zoom(SCREEN_HEIGHT / 480)
		end
		do Proxies['Combo'..pn]
			:SetTarget(Actors[pn]:GetChild('Combo'))
			:xy(Actors[pn]:GetX(), SCREEN_CENTER_Y)
			:zoom(SCREEN_HEIGHT / 480)
		end
		do Actors[pn]
			:visible(false)
		end
		do Actors[pn]:GetChild('Judgment')
			:diffusealpha(0.5)
			:visible(false)
			:sleep(9e9)
		end
		do Actors[pn]:GetChild('Combo')
			:diffusealpha(0.5)
			:visible(false)
			:sleep(9e9)
		end
		do Options[pn]
			:NotePathDrawMode('DrawMode_PolyLineStrip')
		end

	end}

	-- watermark stuff
	do GoodBoy
		:Center()
		:SetSize(96, 96)
		:zoom(0)
		:rotationz(360)
		:shadowcolor(0, 0, 0, 0.5)
		:shadowlengthy(3)
	end
	do Strawb
		:Center()
		:Load(SRC_ROOT..'/assets/strawb.png')
		:SetSize(64, 64)
		:zoom(0)
	end
	do Ichigo
		:LoadFromFont(THEME:GetPathF('Common', 'Normal'))
		:Center()
		:diffuse(0, 0, 0, 1)
		:settext('イチゴ')
		:wag()
		:effectmagnitude(0, 0, 5)
		:zoom(0)
	end
	do Template
		:LoadFromFont(THEME:GetPathF('Common', 'Normal'))
		:Center()
		:addy(96)
		:settext('Ichigo Template')
		:cropright(1)
		:shadowcolor(0, 0, 0, 0.5)
		:shadowlengthy(3)
	end

end

-- ran on each frame
function update(params)

	-- watermark stuff
	do GoodBoy
		:addrotationz(-30 * params.dt)
	end

end


run '/gimmicks.lua'
run '/tweens.lua'
