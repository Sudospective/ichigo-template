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
	__type = 'Sprite',
	LoadShader = function(self, name, path)
		local shader = Def.Actor {
			Frag = path,
			InitCommand = function(s)
				self[name] = s:GetShader()
			end
		}
		table.insert(ichi.ActorTable, 1, shader)
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

class 'Playfield' : extends 'Node' {
	__type = 'NoteField'
}
