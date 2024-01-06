local ichi = ...


local ModTable = {}
local MsgTable = {}
local EaseTable = {}
local PopTable = {}


ichi.Players = {}
ichi.Options = {}


for _, pn in ipairs(GAMESTATE:GetEnabledPlayers()) do
	PopTable[#PopTable + 1] = GAMESTATE:GetPlayerState(pn):GetPlayerOptions('ModsLevel_Song')
	ichi.Players[#ichi.Players + 1] = ToEnumShortString(pn)
	ichi.Options['P'..#PopTable] = PopTable[#PopTable]
end


-- require two players
function ichi.ni()
	if GAMESTATE:GetNumPlayersEnabled() < 2 then
		table.insert(ichi.Actors, Def.Actor {
			OnCommand = function(self)
				SCREENMAN:SystemMessage('Two Players Required')
				SCREENMAN:GetTopScreen():Cancel()
			end
		})
	end
end

-- create an actor
function ichi.actor(t)
	table.insert(ichi.Actors, t)
	return ichi.actor
end

-- create a gimmick
function ichi.gimmick(t)
	local newT = {}
	if type(t[2]) == 'function' then -- func
		newT = {t[1], t[2]}
		table.insert(MsgTable, newT)
	elseif type(t[3]) == 'string' then -- set
		local modstring
		if t[3]:find('mod') then
			if t[3]:find('x') then
				modstring = t[2]..t[3]:sub(1, 1)
			else
				modstring = t[3]:sub(1, 1)..t[2]
			end
		else
			modstring = t[2]..' '..t[3]
		end
		newT = {t[1], 9e9, '*9e9 '..modstring, 'len', t.plr or nil}
		table.insert(ModTable, newT)
	elseif type(t[3]) == 'function' then -- ease / func_ease / perframe
		if #t < 4 then -- perframe
			newT = {t[1], t[2], t[1], t[2], t[3], 'len', Tweens.easeLinear, t.plr or nil}
			table.insert(EaseTable, newT)
		else -- func_ease / ease
			newT = {t[1], t[2], t[4], t[5], t[6], 'len', t[3], t.plr or nil}
			table.insert(EaseTable, newT)
			if type(t[6]) == 'string' then
				local modstring
				local perc = t[3](t[2], t[4], t[5] - t[4], t[2])
				if t[6]:find('mod') then
					if t[6]:find('x') then
						modstring = perc..t[6]:sub(1, 1)
					else
						modstring = t[6]:sub(1, 1)..perc
					end
				else
					modstring = perc..' '..t[6]
				end
				local newerT = {t[1] + t[2], 9e9, modstring, 'len', t.plr or nil}
				table.insert(ModTable, newerT)
			end
		end
	end
	return ichi.gimmick
end

-- create a loop
function ichi.loop(t)
	if type(t[1]) == 'number' then
		t.step = t.step or 1
		for i = t[1], t[1] + t[2] - t.step, t.step do
			t[3](i)
		end
	elseif type(t[1]) == 'table' then
		for k, v in pairs(t[1]) do
			t[2](k, v)
		end
	end
	return ichi.loop
end

return Def.PandaTemplate {
	Name = 'Bookworm',
	ClearDoneMods = true,
	ClearDoneEases = true,
	ClearAllPoptions = true,
	LoopModsAllPoptions = true,
	OnCommand = function(self)
		self:PopulateBeatMods(ModTable)
		self:PopulateBeatMessages(MsgTable)
		self:PopulateEases(EaseTable)
		self:PopulatePoptions(PopTable)
		self:SetPostCommand('Update')
	end,
	UpdateCommand = function(self, params)
		self:SetUpdateSleep(params.dt)
	end
}
