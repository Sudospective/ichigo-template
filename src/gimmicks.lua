--[[

  - {percent, mod}
  - {beat, percent, mod}
  - {beat, length, ease, startPercent, endPercent, mod}

  - {beat, function()}
  - {beat, length, function(beat)}
  - {beat, length, ease, startValue, endValue, function(value)}

--]]

gimmick
  {1.5, "xmod"}
  {100, "modtimersong"}

  {0, 4, Tweens.easeOutElastic, 100, 0, "drunk"}
  {0, 6, Tweens.easeOutElastic, 100, 0, "tipsy"}

notes = {
  {beat = 8, col = 1}
}

notegimmick
  {5, 2, Tweens.easeInOutCircle, OFMath.radians(360) * 100, 0, "confusionoffset"}

notes = nil

-- per-player slumpage-only gimmicks
for i, pn in ipairs(Players) do
  if Charts[pn] == Charts.Edit then
    plr = i

    gimmick
      {0, 2, Tweens.easeOutBounce, 0, 100, "flip"}
      {0, 4, Tweens.easeOutElastic, 0, -100, "invert"}
    
    plr = nil
  end
end
