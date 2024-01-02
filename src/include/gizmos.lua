if Gizmo then return end

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
				return v(self.__actor, ...) or self.__actor
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
		if not self.__actor.Font then
			self.__actor.Font = 'Common Normal'
		end
	end
}

class 'Viewport' : extends 'Gizmo' {
	__type = 'ActorScreenTexture'
}

class 'ShaderLoader' : extends 'Gizmo' {
	__type = 'Actor',
	LoadShader = function(self, name, path)
		local shader = Def.Actor {
			Frag = SRC_ROOT..path,
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
	__enabled = true,
	__ready = function(self)
		self.__actor.OffCommand = function(s)
			if self.__callback then
				SCREENMAN:GetTopScreen():RemoveInputCallback(self.__callback)
			end
		end
	end,
	SetEnabled = function(self, b)
		if b == nil then return end
		self.__enabled = b
	end,
	SetInputCallback = function(self, callback)
		if self.__callback then
			SCREENMAN:GetTopScreen():RemoveInputCallback(self.__callback)
		end
		self.__callback = function(event)
			if not self.__enabled then return end
			callback(event)
		end
		SCREENMAN:GetTopScreen():AddInputCallback(self.__callback)
	end
}
