--[[

	- {beat, percent, mod}
	- {beat, length, ease, startPercent, endPercent, mod}

	- {beat, function()}
	- {beat, length, function(time)}
	- {beat, length, ease, startValue, endValue, function(value)}

--]]

ease
	{0, 2, 'xmod'}
	{0, 100, 'modtimersong'}
	{0, 4, Tweens.easeOutElastic, 0, -100, 'invert'}
	{0, 4, Tweens.easeOutElastic, 100, 0, 'drunk'}
	{0, 2, Tweens.easeOutBounce, 0, 100, 'flip'}
	{0, 6, Tweens.easeOutElastic, 100, 0, 'tipsy'}
