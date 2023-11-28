ease

	-- watermark stuff
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
