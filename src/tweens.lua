ease

	{0, function()

		GoodBoy
			:stoptweening()
			:easeoutquint(2)
			:zoom(1)
			:rotationz(-45)
		
		Strawb
			:stoptweening()
			:easeoutback(0.25)
			:zoom(1)
		
		Ichigo
			:stoptweening()
			:easeoutback(0.25)
			:zoom(1)
		
		Template
			:stoptweening()
			:sleep(1)
			:linear(0.25)
			:cropright(0)
		
	end}

	{9, function()
		
		GoodBoy
			:stoptweening()
			:easeinquad(0.5)
			:addrotationz(-360)
			:zoom(0)
		
		Strawb
			:stoptweening()
			:easeinback(0.25)
			:zoom(0)
		
		Ichigo
			:stoptweening()
			:easeinback(0.25)
			:zoom(0)
		
		Template
			:stoptweening()
			:linear(0.25)
			:cropright(1)
		
	end}
