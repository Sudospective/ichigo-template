--ni() -- uncomment to require two players

function init()
  if go() then -- if alpha v
    Shaders:LoadShader('/assets/colors.frag', 'Colors')
  end
end

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
    setupPlayer(Actors[pn], Proxies[pn].Player)
    setupJudgment(Actors[pn], Proxies[pn].Judgment)
    setupCombo(Actors[pn], Proxies[pn].Combo)

    Actors[pn]:zwrite(true)
    Options[pn]:NotePathDrawMode('DrawMode_PolyLineStrip')
  end

  wm_ready()
end

function input(event)
end

function update(params)
  AG:Update(params.time)
  wm_update(params)
end

run '/layout.lua'
run '/gimmicks.lua'
run '/assets/watermark.lua'
