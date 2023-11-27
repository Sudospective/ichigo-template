local ichi = {}
setmetatable(ichi, {
	__index = _G,
	__call = function(self, f)
		setfenv(f or 2, self)
		return f
	end,
})


local ROOT = GAMESTATE:GetCurrentSong():GetSongDir()
loadfile(ROOT..'lib/std.lua')(ichi)
loadfile(ROOT..'lib/class.lua')(ichi)


ichi.run '/main.lua'
if ichi.init then ichi.init() end


-- icky
table.insert(ichi.ActorTable, Def.ActorFrame {
	Name = 'Picasso',
	OnCommand = function(self)
		if ichi.draw then
			self:SetDrawFunction(ichi.draw)
		end
	end
})


return Def.ActorFrame {
	OnCommand = function(self)
		for _, v in pairs(self:GetChildren()) do
			ichi.ActorTable[v:GetName()] = v
		end
		for _, pn in ipairs(ichi.Players) do
			ichi.ActorTable[pn] = SCREENMAN:GetTopScreen():GetChild('Player'..pn)
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
			self:PopulateEases(ichi.ModTable)
			self:PopulatePoptions(ichi.PopTable)
			--self:SetPostCommand('Update')
			self:queuecommand('Update')
		end,
		UpdateCommand = function(self, params)
			params = params or {}
			params.dt = self:GetEffectDelta()
			if ichi.update then ichi.update(params) end
			self:SetUpdateSleep(self:GetEffectDelta())
			self:sleep(self:GetEffectDelta()):queuecommand('Update')
		end
	},
	table.unpack(ichi.ActorTable)
}
