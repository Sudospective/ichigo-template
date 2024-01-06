local ichi = ...


local ModTable = {}
local MsgTable = {}
local EaseTable = {}
local PopTable = {}


for _, pn in ipairs(GAMESTATE:GetEnabledPlayers()) do
	table.insert(PopTable, GAMESTATE:GetPlayerState(pn):GetPlayerOptions('ModsLevel_Song'))
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

-- check for alpha v
function ichi.go()
	return (ProductVersion():find('0.5') and true) or false
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

-- register playeroptions
function ichi.RegisterOptions(po)
	table.insert(PopTable, po)
	Options['P'..#PopTable] = po
end


return (ProductVersion():find('0.5')) and Def.PandaTemplate {
	Name = 'Bookworm',
	ClearDoneMods = true,
	ClearDoneEases = true,
	ClearAllPoptions = true,
	LoopModsAllPoptions = true,
	OnCommand = function(self)
		print('Using PandaTemplate Modreader')
		self:PopulateBeatMods(ModTable)
		self:PopulateBeatMessages(MsgTable)
		self:PopulateEases(EaseTable)
		self:PopulatePoptions(PopTable)
		self:SetPostCommand('Update')
	end,
	UpdateCommand = function(self, params)
		self:SetUpdateSleep(params.dt)
	end
} or Def.ActorFrame {
	Name = 'Bookworm',
	OnCommand = function(self)
		print('Using Legacy Modreader')
		self.Disable = false
		self.FirstBeat = ichi.SONG_POS:GetSongBeat()
		self.CurAction = 1
		local function mod_compare(a, b)
			return a[1] < b[1]
		end
		if #MsgTable > 1 then
			table.sort(MsgTable, mod_compare)
		end
		self:queuecommand('Update')
	end,
	UpdateCommand = function(self)
		-- help
		local beat = ichi.SONG_POS:GetSongBeat()
		if not self.Disable then
			if beat > self.FirstBeat + 0.1 then
				-- reset
				for pn = 1, #PopTable do
					PopTable[pn]:FromString('clearall')
				end
				-- mods
				for i, v in ipairs(ModTable) do
					if v and #v > 3 and v[1] and v[2] and v[3] and v[4] then
						if beat >= v[1] then
							if (v[4] == 'len' and beat <= v[1] + v[2]) or (v[4] == 'end' and beat <= v[2]) then
								if #v == 5 and v[5] then
									PopTable[v[5]]:FromString(v[3])
								else
									for pn = 1, #PopTable do
										PopTable[pn]:FromString(v[3])
									end
								end
							end
						end
					else
						v[1] = 0
						v[2] = 0
						v[3] = ''
						v[4] = 'error'
						SCREENMAN:SystemMessage('Bad mod in beat-based table (line '..i..')')
					end
				end
				-- eases
				for i, v in ipairs(EaseTable) do
					if v and #v > 6 and v[1] and v[2] and v[3] and v[4] and v[5] and v[6] and v[7] then
						if beat >= v[1] then
							if (v[6] == 'len' and beat <= v[1] + v[2]) or (v[6] == 'end' and beat <= v[2]) then
								local strength = v[7](beat - v[1], v[3], v[4] - v[3], v[6] == 'end' and v[2] - v[1] or v[2], v[10], v[11])
								if type(v[5]) == 'string' then
									local modstr = v[5] == 'xmod' and strength..'x' or (v[5] == 'cmod' and 'C'..strength or strength..' '..v[5])
									if v[8] then
										PopTable[v[8]]:FromString('*9e9 '..modstr)
									else
										for pn = 1, #PopTable do
											PopTable[pn]:FromString('*9e9 '..modstr)
										end
									end
								elseif type(v[5]) == 'function' then
									v[5](strength)
								end
							elseif (v[9] and ((v[6] == 'len' and beat <=v[1] + v[2] + v[9]) or (v[6] == 'end' and beat <= v[9]))) then
								if type(v[5]) == 'string' then
									local modstr = v[5] == 'xmod' and v[4]..'x' or (v[5] == 'cmod' and 'C'..v[4] or v[4]..' '..v[5])
									if v[8] then
										PopTable[v[8]]:FromString('*9e9 '..modstr)
									else
										for pn = 1, #PopTable do
											PopTable[pn]:FromString('*9e9 '..modstr)
										end
									end
								elseif type(v[5]) == 'function' then
									v[5](v[4])
								end
							end
						end
					else
						SCREENMAN:SystemMessage('Ease Error! (line '..i..' | beat: '..v[1]..' | mod: '..v[5]..')')
					end
				end
				-- actions
				while self.CurAction <= #MsgTable and beat >= MsgTable[self.CurAction][1] do
					local action = MsgTable[self.CurAction]
					if action[3] or beat < action[1] + 2 then
						if type(action[2]) == 'function' then
							action[2]()
						elseif type(action[2]) == 'string' then
							MESSAGEMAN:Broadcast(action[2])
						end
					end
					self.CurAction = self.CurAction + 1
				end
			end
		end
		self:sleep(self:GetEffectDelta()):queuecommand('Update')
	end
}
