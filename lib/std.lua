local ichi = ...


local SRC_ROOT = GAMESTATE:GetCurrentSong():GetSongDir()..'src'

ichi.ichi = ichi
ichi.ActorTable = {}
ichi.ModTable = {}
ichi.PopTable = {}
ichi.Players = {}
ichi.Options = {}
for _, pn in ipairs(GAMESTATE:GetEnabledPlayers()) do
	ichi.Players[#ichi.Players + 1] = ToEnumShortString(pn)
	ichi.PopTable[#ichi.PopTable + 1] = GAMESTATE:GetPlayerState(pn):GetPlayerOptions('ModsLevel_Song')
	ichi.Options['P'..#ichi.PopTable] = GAMESTATE:GetPlayerState(pn):GetPlayerOptions('ModsLevel_Song')
end
ichi.SRC_ROOT = SRC_ROOT
ichi.__version = '1.0'


function ichi.ni(f)
	local env = {}
	setmetatable(env, {__index = ichi})
	env.ichi = ichi
	setfenv(f, env)
	return f()
end

function ichi.run(path, ...)
	return ichi(loadfile(SRC_ROOT..path))(...)
end

function ichi.include(name, ...)
	return ichi(loadfile(SRC_ROOT..'/include/'..name..'.lua'))(...)
end

function ichi.actor(t)
	table.insert(ichi.ActorTable, t)
	return ichi.actor
end

function ichi.ease(t)
	local newT = {}
	if type(t[2]) == 'function' then -- func
		newT = {t[1], 0.1, 0, 1, t[2], 'len', Tweens.easeLinear, t.plr or nil}
	elseif type(t[3]) == 'string' then -- set
		newT = {t[1], 0.1, t[2], t[2], t[3], 'len', Tweens.easeLinear, t.plr or nil}
	elseif type(t[3]) == 'function' then -- ease / func_ease / perframe
		if #t < 4 then -- perframe
			newT = {t[1], t[2], 0, 1, t[3], 'len', Tweens.easeLinear, t.plr or nil}
		else -- func_ease / ease
			newT = {t[1], t[2], t[4], t[5], t[6], 'len', t[3], t.plr or nil}
		end
	end
	table.insert(ichi.ModTable, newT)
	return ichi.ease
end

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
