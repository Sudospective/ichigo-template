local ichi = {}
setmetatable(ichi, {
	__index = _G,
	__call = function(self, f)
		setfenv(f or 2, self)
		return f
	end,
})


ichi.__version = '1.0-RC2'
ichi.ichi = ichi
ichi.Actors = Def.ActorFrame {}
ichi.SONG = GAMESTATE:GetCurrentSong()
ichi.SONG_POS = GAMESTATE:GetSongPosition()
ichi.SRC_ROOT = ichi.SONG:GetSongDir()..'src'

ichi.Players = {}
ichi.Options = {}
ichi.Charts = {}
for i, pn in ipairs(GAMESTATE:GetEnabledPlayers()) do
	ichi.Players[i] = ToEnumShortString(pn)
	ichi.Options[ichi.Players[i]] = GAMESTATE:GetPlayerState(pn):GetPlayerOptions('ModsLevel_Song')
	ichi.Charts[ichi.Players[i]] = GAMESTATE:GetCurrentSteps(pn)
end


-- run a file from src
function ichi.run(path)
	local data = assert(loadfile(ichi.SRC_ROOT..path))
	return ichi(data)()
end
-- include a file from src/include
function ichi.include(name)
	local data = assert(loadfile(ichi.SRC_ROOT..'/include/'..name..'.lua'))
	return ichi(data)()
end


local ROOT = GAMESTATE:GetCurrentSong():GetSongDir()
local LIBS = FILEMAN:GetDirListing(ROOT..'lib/', false, true)
local LibActors = Def.ActorFrame {}
for k, v in pairs(LIBS) do
	table.insert(LibActors, assert(loadfile(v))(ichi) or nil)
end


ichi.run '/main.lua'
if ichi.init then ichi.init() end


return Def.ActorFrame {
	OnCommand = function(self)
		for _, pn in ipairs(ichi.Players) do
			ichi.Actors[pn] = SCREENMAN:GetTopScreen():GetChild('Player'..pn)
		end
		if ichi.ready then ichi.ready() end
		if ichi.input then
			SCREENMAN:GetTopScreen():AddInputCallback(ichi.input)
		end
	end,
	OffCommand = function(self)
		if ichi.input then
			SCREENMAN:GetTopScreen():RemoveInputCallback(ichi.input)
		end
	end,
	Def.Actor {
		Name = 'Sleepyhead',
		InitCommand = function(self) self:sleep(9e9) end
	},
	Def.Actor {
		Name = 'Newsboy',
		OnCommand = function(self)
			self:sleep(self:GetEffectDelta()):queuecommand('Update')
		end,
		UpdateCommand = function(self, params)
			params = params or {}
			params.dt = params.dt or self:GetEffectDelta()
			params.beat = params.beat or ichi.SONG_POS:GetSongBeat()
			if ichi.update then ichi.update(params) end
			self:sleep(params.dt):queuecommand('Update')
		end,
	},
	LibActors,
	ichi.Actors,
	Def.ActorFrame {
		Name = 'Picasso',
		OnCommand = function(self)
			if ichi.draw then
				self:SetDrawFunction(ichi.draw)
			end
		end
	}
}
