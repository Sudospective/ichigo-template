local ichi = ...


local SRC_ROOT = GAMESTATE:GetCurrentSong():GetSongDir()..'src'

ichi.ichi = ichi
ichi.ModTable = {}
ichi.MsgTable = {}
ichi.EaseTable = {}
ichi.PopTable = {}
ichi.Actors = Def.ActorFrame {}
ichi.Players = {}
ichi.Options = {}
for _, pn in ipairs(GAMESTATE:GetEnabledPlayers()) do
	ichi.Players[#ichi.Players + 1] = ToEnumShortString(pn)
	ichi.PopTable[#ichi.PopTable + 1] = GAMESTATE:GetPlayerState(pn):GetPlayerOptions('ModsLevel_Song')
	ichi.Options['P'..#ichi.PopTable] = GAMESTATE:GetPlayerState(pn):GetPlayerOptions('ModsLevel_Song')
end
ichi.SRC_ROOT = SRC_ROOT
ichi.__version = '1.0'

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

-- run a file from src
function ichi.run(path)
	local data = assert(loadfile(SRC_ROOT..path))
	return ichi(data)()
end

-- include a file from src/include
function ichi.include(name)
	local data = assert(loadfile(SRC_ROOT..'/include/'..name..'.lua'))
	return ichi(data)()
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
		table.insert(ichi.MsgTable, newT)
	elseif type(t[3]) == 'string' then -- set
		newT = {t[1], 9e9, '*9e9 '..t[2]..' '..t[3], 'len', t.plr or nil}
		table.insert(ichi.ModTable, newT)
	elseif type(t[3]) == 'function' then -- ease / func_ease / perframe
		if #t < 4 then -- perframe
			newT = {t[1], t[2], t[1], t[2], t[3], 'len', Tweens.easeLinear, t.plr or nil}
			table.insert(ichi.EaseTable, newT)
		else -- func_ease / ease
			newT = {t[1], t[2], t[4], t[5], t[6], 'len', t[3], t.plr or nil}
			table.insert(ichi.EaseTable, newT)
			if type(t[6]) == 'string' then
				local newerT = {t[1] + t[2], 9e9, '*9e9 '..t[5]..' '..t[6], 'len', t.plr or nil}
				table.insert(ichi.ModTable, newerT)
			end
		end
	end
	return ichi.gimmick
end

-- create a loop
function ichi.loop(t)
	if type(t[1]) == 'number' then
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
