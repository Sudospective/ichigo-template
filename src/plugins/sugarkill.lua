function sugarkill(t)
  local frame = 0
  gimmick {t[1], t[2], function(beat)
    local i, f, s
    if frame == 0 then
      i = 1
      f = 0
      s = 0.9
    elseif frame == 1 then
      i = 0
      f = 1
      s = 0.9
    elseif frame == 2 then
      i = -1
      f = 1
      s = 0.9
    elseif frame == 3 then
      i = 0
      f = 0
      s = 0.5
    end
    for _, pn in ipairs(Players) do
      Options[pn]:Invert(i, 9e9)
      Options[pn]:Flip(f, 9e9)
      Options[pn]:Stealth(s, 9e9)
    end
    frame = (frame + 1) % 4
  end}
  return sugarkill
end
