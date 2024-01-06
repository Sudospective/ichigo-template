include 'gizmos'


--ni() -- uncomment to require two players


-- ran right after main.lua is loaded
function init()

	if go() then
		Shaders:LoadShader('Colors', '/assets/colors.frag')
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

	if watermark_ready then
		watermark_ready()
	end

end

-- ran on each frame
function update(params)

	if watermark_update then
		watermark_update(params)
	end

end


run '/layout.lua'
run '/gimmicks.lua'
run '/assets/watermark.lua'
