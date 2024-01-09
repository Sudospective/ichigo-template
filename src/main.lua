include 'gizmos'
include 'autogimmick'


--ni() -- uncomment to require two players


-- open this json file in automaton to edit some gimmicks visually!
AG = AutoGimmick:new('/assets/mods.json')


-- ran right after main.lua is loaded
function init()

	-- if alpha v
	if go() then
		Shaders:LoadShader('/assets/colors.frag', 'Colors')
	end

end

-- ran after all actors are ready
function ready()

	-- background
	do BG
		:FullScreen()
		:diffuse(0, 0, 0, 1)
		:glow(0, 0, 0, 0.5)
	end

	-- if alpha v
	if go() then
		BG:SetShader(Shaders.Colors)
	end


	-- per-player setup
	for _, pn in ipairs(Players) do

		-- players
		do Proxies['Player'..pn]
			:SetTarget(Actors[pn])
		end
		do Actors[pn]
			:visible(false)
		end

		-- judgments
		do Proxies['Judgment'..pn]
			:SetTarget(Actors[pn]:GetChild('Judgment'))
			:xy(Actors[pn]:GetX(), SCREEN_CENTER_Y)
			:zoom(SCREEN_HEIGHT / 480)
		end
		do Actors[pn]:GetChild('Judgment')
			:diffusealpha(0.5)
			:visible(false)
			:sleep(9e9)
		end

		-- combos
		do Proxies['Combo'..pn]
			:SetTarget(Actors[pn]:GetChild('Combo'))
			:xy(Actors[pn]:GetX(), SCREEN_CENTER_Y)
			:zoom(SCREEN_HEIGHT / 480)
		end
		do Actors[pn]:GetChild('Combo')
			:diffusealpha(0.5)
			:visible(false)
			:sleep(9e9)
		end

		-- misc.
		do Options[pn]
			:NotePathDrawMode('DrawMode_PolyLineStrip')
		end

	end

	watermark_ready()

end

-- ran on each frame
function update(params)

	watermark_update(params)
	AG:Update(params.time)

end


run '/layout.lua'
run '/gimmicks.lua'
run '/assets/watermark.lua'
