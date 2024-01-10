if AutoGimmick then return end


class 'AutoGimmick' {
	__version = '1.0',
	__init = function(self, path)
		if path:find('%.json') then path = path:sub(1, path:find('%.json') - 1) end
		local file = SRC_ROOT..path..'.json'
		if not FILEMAN:DoesFileExist(file) then
			file = SRC_ROOT..path..'/default.json'
		end
		if not FILEMAN:DoesFileExist(file) then
			lua.ReportScriptError('Unable to local file "'..SRC_ROOT..path..'.json" or "'..SRC_ROOT..path..'/default.json".')
			return
		end
		local f = RageFileUtil.CreateRageFile()
		f:Open(file, 1)
		self.__data = JsonDecode(f:Read())
		f:Close()
		f:destroy()
		self.__auto = automaton(self.__data)
		for k, _ in pairs(self.__auto.mapNameToChannel) do
			self.__auto.auto(k, function(event)
				local pn = k:sub(1, 2)
				local mod = k:lower():sub(4)
				local amp = event.value * 100
				Options[pn]:FromString('*-1 '..amp..' '..mod)
			end)
		end
	end,
	Define = function(self, name, func)
		for _, pn in ipairs(Players) do
			self.__auto.auto(pn..'/'..name, function(event)
				func(event.value, pn)
			end)
		end
		return self
	end,
	Update = function(self, time)
		self.__auto:update(time)
	end,
}
