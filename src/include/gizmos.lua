include 'node'


class 'Rect' : extends 'Node' {
	__type = 'Quad'
}

class 'Image' : extends 'Rect' {
	__type = 'Sprite'
}

class 'Label' : extends 'Node' {
	__type = 'BitmapText',
	__ready = function(self)
		self.__actor.Font = 'Common Normal'
	end
}

class 'Viewport' : extends 'Node' {
	__type = 'ActorScreenTexture'
}

class 'ShaderLoader' : extends 'Node' {
	__type = 'Actor',
	LoadShader = function(self, name, path)
		local shader = Def.Actor {
			Frag = path,
			InitCommand = function(s)
				self[name] = s:GetShader()
			end
		}
		table.insert(ichi.ActorTable, 1, shader)
		return self
	end,
}

class 'Model3D' : extends 'Node' {
	__type = 'Model'
}

class 'Audio' : extends 'Node' {
	__type = 'Sound'
}

class 'Proxy' : extends 'Node' {
	__type = 'ActorProxy'
}

class 'PlayField' : extends 'Node' {
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
