local ichi = {}
setmetatable(ichi, {
	__index = _G,
	__call = function(self, f)
		setfenv(f or 2, self)
		return f
	end,
})


local ROOT = GAMESTATE:GetCurrentSong():GetSongDir()
local LIBS = FILEMAN:GetDirListing(ROOT..'lib/', false, true)
for k, v in pairs(LIBS) do
	loadfile(v)(ichi)
end


ichi.run '/main.lua'
if ichi.init then ichi.init() end

return Def.ActorFrame {
	OnCommand = function(self)
		for _, pn in ipairs(ichi.Players) do
			ichi.Actors[pn] = SCREENMAN:GetTopScreen():GetChild('Player'..pn)
		end
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
	Def.PandaTemplate {
		Name = 'Bookworm',
		ClearDoneMods = true,
		ClearDoneEases = true,
		ClearAllPoptions = true,
		LoopModsAllPoptions = true,
		OnCommand = function(self)
			if ichi.ready then ichi.ready() end
			self:PopulateBeatMods(ichi.ModTable)
			self:PopulateBeatMessages(ichi.MsgTable)
			self:PopulateEases(ichi.EaseTable)
			self:PopulatePoptions(ichi.PopTable)
			self:SetPostCommand('Update')
		end,
		UpdateCommand = function(self, params)
			params = params or {}
			params.dt = self:GetEffectDelta()
			if ichi.update then ichi.update(params) end
			self:SetUpdateSleep(params.dt)
		end
	},
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
