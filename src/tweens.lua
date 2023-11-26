ease

	{0, function()

		R:stoptweening()
			:easeoutquint(2)
			:zoom(1)
			:rotationz(-45)
		
		I:stoptweening()
			:easeoutback(0.25)
			:zoom(1)
		
		L:stoptweening()
			:easeoutback(0.25)
			:zoom(1)
		
		L2:stoptweening()
			:sleep(1)
			:linear(0.25)
			:cropright(0)
		
	end}

	{9, function()
		
		R:stoptweening()
			:easeinquad(0.5)
			:addrotationz(-360)
			:zoom(0)
		
		I:stoptweening()
			:easeinback(0.25)
			:zoom(0)
		
		L:stoptweening()
			:easeinback(0.25)
			:zoom(0)
		
		L2:stoptweening()
			:linear(0.25)
			:cropright(1)
		
	end}
