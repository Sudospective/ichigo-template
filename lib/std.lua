local ichi = ...


local SRC_ROOT = GAMESTATE:GetCurrentSong():GetSongDir()..'src'

ichi.ichi = ichi
ichi.ActorTable = {}
ichi.ModTable = {}
ichi.Players = {}
ichi.Options = {}
for _, pn in ipairs(GAMESTATE:GetEnabledPlayers()) do
	ichi.Players[#ichi.Players + 1] = ToEnumShortString(pn)
	ichi.Options[ToEnumShortString(pn)] = GAMESTATE:GetPlayerState(pn):GetPlayerOptions('ModsLevel_Song')
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
		newT = {t[1], 0.05, 0, 1, t[2], 'len', Tweens.easeLinear}
	elseif type(t[3]) == 'string' then -- set
		newT = {t[1], 0.05, t[2], t[2], t[3], 'len', Tweens.easeLinear}
	elseif type(t[3]) == 'function' then -- ease / func_ease / perframe
		if #t < 4 then -- perframe
			newT = {t[1], t[2], 0, 1, t[3], 'len', Tweens.easeLinear}
		else -- func_ease / ease
			newT = {t[1], t[2], t[4], t[5], t[6], 'len', t[3]}
		end
	end
	table.insert(ichi.ModTable, newT)
	return ichi.ease
end
