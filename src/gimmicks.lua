--[[

	- {beat, percent, mod}
	- {beat, length, ease, startPercent, endPercent, mod}

	- {beat, function()}
	- {beat, length, function(beat)}
	- {beat, length, ease, startValue, endValue, function(value)}

--]]

gimmick
	{-10, 2, 'xmod'}
	{-10, 100, 'modtimersong'}
	{-10, 100, 'dark'}
	
	{0, 2, Tweens.easeLinear, 100, 0, 'dark'}
	{0, 2, Tweens.easeOutBounce, 0, 100, 'flip', plr = 1}
	{0, 4, Tweens.easeOutElastic, 0, -100, 'invert', plr = 1}
	{0, 4, Tweens.easeOutElastic, 100, 0, 'drunk'}
	{0, 6, Tweens.easeOutElastic, 100, 0, 'tipsy'}
	
	{0, function()

		do GoodBoy
			:stoptweening()
			:easeoutquint(2)
			:zoom(1)
			:rotationz(-45)
		end
		do Strawb
			:stoptweening()
			:easeoutback(0.25)
			:zoom(1)
		end
		do Ichigo
			:stoptweening()
			:easeoutback(0.25)
			:zoom(1)
		end
		do Template
			:stoptweening()
			:sleep(1)
			:linear(0.25)
			:cropright(0)
		end

	end}
	{9, function()
		
		do GoodBoy
			:stoptweening()
			:easeinquad(0.5)
			:addrotationz(-360)
			:zoom(0)
		end
		do Strawb
			:stoptweening()
			:easeinback(0.25)
			:zoom(0)
		end
		do Ichigo
			:stoptweening()
			:easeinback(0.25)
			:zoom(0)
		end
		do Template
			:stoptweening()
			:linear(0.25)
			:cropright(1)
		end
		
	end}
