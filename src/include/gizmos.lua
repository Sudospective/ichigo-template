class 'Gizmo' {

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

class 'Rect' : extends 'Gizmo' {
	__type = 'Quad'
}

class 'Image' : extends 'Gizmo' {
	__type = 'Sprite'
}

class 'Label' : extends 'Gizmo' {
	__type = 'BitmapText',
	__ready = function(self)
		self.__actor.Font = 'Common Normal'
	end
}

class 'Viewport' : extends 'Gizmo' {
	__type = 'ActorScreenTexture'
}

class 'ShaderLoader' : extends 'Gizmo' {
	__type = 'Actor',
	LoadShader = function(self, name, path)
		local shader = Def.Actor {
			Frag = path,
			InitCommand = function(s)
				self[name] = s:GetShader()
			end
		}
		table.insert(ichi.Actors, 1, shader)
		return self
	end,
}

class 'Model3D' : extends 'Gizmo' {
	__type = 'Model'
}

class 'Audio' : extends 'Gizmo' {
	__type = 'Sound'
}

class 'Proxy' : extends 'Gizmo' {
	__type = 'ActorProxy'
}

class 'PlayField' : extends 'Gizmo' {
	__type = 'ActorFrame',
	__ready = function(self)
		local function metric(str)
			return tonumber(THEME:GetMetric('Player', str))
		end
		self.__actor.FOV = 45
		local nf = Def.NoteField {
			Name = 'NoteField',
			DrawDistanceAfterTargetsPixels = metric 'DrawDistanceAfterTargetsPixels',
			DrawDistanceBeforeTargetsPixels = metric 'DrawDistanceBeforeTargetsPixels',
			YReverseOffsetPixels = metric 'ReceptorArrowsYReverse' - metric 'ReceptorArrowsYStandard',
			InitCommand = function(self)
				local plr = self:GetParent()
				local po = self:GetPlayerOptions('ModsLevel_Current')
				table.insert(PopTable, po)
				Options['P'..#PopTable] = po
				local vanishx = plr.vanishpointx
				local vanishy = plr.vanishpointy
				function plr:vanishpointx(n)
					local offset = scale(po:Skew(), 0, 1, plr:GetX(), SCREEN_CENTER_X)
					vanishx(plr, offset + n)
					return self
				end
				function plr:vanishpointy(n)
					local offset = SCREEN_CENTER_Y
					vanishy(plr, offset + n)
					return self
				end
				function plr:vanishpoint(x, y)
					return plr:vanishpointx(x):vanishpointy(y)
				end
				local nfmid = (metric 'ReceptorArrowsYStandard' + metric 'ReceptorArrowsYReverse') / 2
				plr:Center():zoom(SCREEN_HEIGHT / 480)
				self:y(nfmid)
			end,
		}
		table.insert(self.__actor, nf)
	end
}

class 'Polygon' : extends 'Gizmo' {
	__type = 'ActorMultiVertex'
}

class 'Input' : extends 'Gizmo' {
	__type = 'Actor',
	__ready = function(self)
		self.__actor.OffCommand = function(s)
			SCREENMAN:GetTopScreen():RemoveInputCallback(self.__func)
		end
	end,
	SetInputCallback = function(self, func)
		if self.__func then
			SCREENMAN:GetTopScreen():RemoveInputCallback(self.__func)
		end
		self.__func = func
		SCREENMAN:GetTopScreen():AddInputCallback(self.__func)
	end
}
