class 'Node' {

	__type = 'Actor',

	
	__init = function(self)
		self.__actor = Def[self.__type] {}
		local t = _G[self.__type] or {}
		for k, v in pairs(Actor) do
			t[k] = v
		end
		for k, v in pairs(t) do
			self[k] = function(s, ...)
				v(self.__actor, ...)
				return self
			end
		end
		self.__actor.InitCommand = function(s)
			self.__actor = s
		end
		table.insert(Actors, self.__actor)
		if self.__ready then
			self:__ready()
		end
	end,


	-- shouldnt be needed, but just in case
	GetActor = function(self)
		return self.__actor
	end,

}
