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
loadfile(ROOT..'lib/classes.lua')(ichi)

ichi.run '/main.lua'
if ichi.init then ichi.init() end


return Def.ActorFrame {
	OnCommand = function(self)
		for _, v in pairs(self:GetChildren()) do
			ichi.ActorTable[v:GetName()] = v
		end
		for _, pn in ipairs(ichi.Players) do
			ichi.ActorTable[pn] = SCREENMAN:GetTopScreen():GetChild('Player'..pn)
		end
	end,
	Def.Actor {
		Name = 'Sleepyhead',
		InitCommand = function(self) self:sleep(9e9) end
	},
	Def.PandaTemplate {
		Name = 'Bookworm',
		ClearDoneMods = false,
		ClearDoneEases = false,
		OnCommand = function(self)
			if ichi.ready then ichi.ready() end
			if ichi.mods then
				local t = ichi.mods()
				for _, v in ipairs(t) do
					table.insert(ichi.ModTable, {v[1], v[2], v[4], v[5], v[6], 'len', v[3]})
				end
			end
			self:PopulateEases(ichi.ModTable)
			--self:SetPostCommand('Update')
			self:queuecommand('Update')
		end,
		UpdateCommand = function(self, params)
			params = params or {}
			params.dt = self:GetEffectDelta()
			if ichi.update then ichi.update(params) end
			self:SetUpdateSleep(self:GetEffectDelta())
			self:sleep(self:GetEffectDelta()):queuecommand('Update')
		end,
	},
	table.unpack(ichi.ActorTable),
	Def.ActorFrame {
		Name = 'Picasso',
		OnCommand = function(self)
			if ichi.draw then
				self:SetDrawFunction(ichi.draw)
			end
		end,
	},
}
