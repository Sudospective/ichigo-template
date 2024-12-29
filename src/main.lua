-- Documentation at: https://ichigo-docs.sudospective.net
-- Small example in /assets/watermark.lua

function init()
  -- if alpha v
  if go() then
    Shaders:LoadShader("/assets/colors.frag", "Colors")
  end
end

function ready()
  -- hide gameplay elements for performance
  if Actors.Screen.HideGameplayElements then
    Actors.Screen:HideGameplayElements()
  end

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
    Options[pn]:NotePathDrawMode("DrawMode_PolyLineStrip")
  end
end

-- function update(params)
-- end

-- function input(event)
-- end

-- function draw()
-- end

run "layout.lua"
run "gimmicks.lua"
run "assets/watermark.lua"
