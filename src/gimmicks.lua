--[[

  - {percent, mod}
  - {beat, percent, mod}
  - {beat, length, ease, startPercent, endPercent, mod}

  - {beat, function()}
  - {beat, length, function(beat)}
  - {beat, length, ease, startValue, endValue, function(value)}

--]]

gimmick
  {200, 'cmod'}
  {100, 'modtimersong'}
  
  {-10, 100, 'dark'}
  
  {0, 2, Tweens.easeLinear, 100, 0, 'dark'}
  {0, 4, Tweens.easeOutElastic, 100, 0, 'drunk'}
  {0, 6, Tweens.easeOutElastic, 100, 0, 'tipsy'}

if Charts.P1 == Charts.Challenge then
  gimmick
    {0, 2, Tweens.easeOutBounce, 0, 100, 'flip', plr = 1}
    {0, 4, Tweens.easeOutElastic, 0, -100, 'invert', plr = 1}
end
