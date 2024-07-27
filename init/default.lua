if ProductFamily() ~= "OutFox" then
  lua.ReportScriptError("This template is only compatible with Project OutFox.")
  return Def.Actor {}
end

local ichi = {}
setmetatable(ichi, {
  __index = _ENV,
  __call = function(self, f)
    setfenv(f or 2, self)
    return f
  end,
})
ichi.ichi = ichi

-- constants
ichi.SCX = SCREEN_CENTER_X
ichi.SCY = SCREEN_CENTER_Y
ichi.SW = SCREEN_WIDTH
ichi.SH = SCREEN_HEIGHT
ichi.SL = SCREEN_LEFT
ichi.SR = SCREEN_RIGHT
ichi.ST = SCREEN_TOP
ichi.SB = SCREEN_BOTTOM
ichi.DW = DISPLAY:GetDisplayWidth()
ichi.DH = DISPLAY:GetDisplayHeight()
ichi.SONG = GAMESTATE:GetCurrentSong()
ichi.SONG_POS = GAMESTATE:GetSongPosition()
ichi.SONG_ROOT = ichi.SONG:GetSongDir()
ichi.SRC_ROOT = ichi.SONG:GetSongDir().."src"
ichi.__version = "1.1"

-- variables
ichi.Style = GAMESTATE:GetCurrentStyle()
ichi.Actors = Def.ActorFrame {}
ichi.Players = {}
ichi.Options = {}
ichi.Charts = {}
ichi.Profiles = {
  Machine = PROFILEMAN:GetMachineProfile()
}
ichi.States = {}
ichi.Columns = {}

-- easier chart access
for _, v in ipairs(ichi.SONG:GetAllSteps()) do
  ichi.Charts[ToEnumShortString(v:GetDifficulty())] = v
end

for i, pn in ipairs(GAMESTATE:GetEnabledPlayers()) do
  ichi.Players[i] = ToEnumShortString(pn)
  ichi.Options[ichi.Players[i]] = GAMESTATE:GetPlayerState(pn):GetPlayerOptions("ModsLevel_Song")
  ichi.Profiles[ichi.Players[i]] = PROFILEMAN:GetProfile(pn)
  ichi.States[ichi.Players[i]] = GAMESTATE:GetPlayerState(pn)
  
  -- if we use GetCurrentSteps, we could end up with userdata
  -- that differs from the chart listed in ichi.Charts.
  for k, v in pairs(ichi.Charts) do
    if GAMESTATE:GetCurrentSteps(pn):GetDifficulty():find(k) then
      ichi.Charts[ichi.Players[i]] = v
      break
    end
  end
end

-- run a file from /src
function ichi.run(path)
  local data = assert(loadfile(ichi.SONG_ROOT.."src/"..path))
  return ichi(data)()
end
-- include a file from /include
function ichi.include(name)
  local data = assert(loadfile(ichi.SONG_ROOT.."include/"..name..".lua"))
  return ichi(data)()
end

function ichi.setting(name, value)
  if value then
    LoadModule("Config.Save.lua")(name, value, ichi.SONG_ROOT.."settings.ini")
  else
    return LoadModule("Config.Load.lua")(name, ichi.SONG_ROOT.."settings.ini")
  end
end

-- grab from settings
ichi.IH = tonumber(ichi.setting("IntendedHeight"))

local LIBS = FILEMAN:GetDirListing(ichi.SONG_ROOT.."lib/", false, true)
local LibActors = Def.ActorFrame {}
for k, v in pairs(LIBS) do
  if v:find("%.lua") and not v:find("%.disabled") then
    table.insert(LibActors, assert(loadfile(v))(ichi) or nil)
  end
end

local PLUGINS = FILEMAN:GetDirListing(ichi.SONG_ROOT.."src/plugins/", false, false)
for k, v in pairs(PLUGINS) do
  if v:find("%.lua") and not v:find("%.disabled") then
    ichi.run("/plugins/"..v)
  end
end

ichi.run "/main.lua"
if ichi.init then ichi.init() end

return Def.ActorFrame {
  FOV = 120, -- the fov of one human eye
  OnCommand = function(self)
    for _, pn in ipairs(ichi.Players) do
      ichi.Actors[pn] = SCREENMAN:GetTopScreen():GetChild("Player"..pn)
      ichi.Columns[pn] = ichi.Actors[pn]:GetChild("NoteField"):GetColumnActors()
    end
    if ichi.ready then ichi.ready() end
    if ichi.input then
      SCREENMAN:GetTopScreen():AddInputCallback(ichi.input)
    end
    if SCREENMAN:GetTopScreen().GetEditState then
      SCREENMAN:GetTopScreen():GetChild("Overlay"):AddChild(function()
        return Def.Actor {
          Name = "InputCleaner",
          EditCommand = function(self)
            if ichi.input then
              SCREENMAN:GetTopScreen():RemoveInputCallback(ichi.input)
            end
            SCREENMAN:GetTopScreen():GetChild("Overlay"):RemoveChild(self:GetName())
          end,
        }
      end)
    end
  end,
  OffCommand = function(self)
    if ichi.input then
      SCREENMAN:GetTopScreen():RemoveInputCallback(ichi.input)
    end
  end,
  Def.Actor {
    Name = "Sleepyhead",
    InitCommand = function(self) self:sleep(9e9) end
  },
  Def.Actor {
    Name = "Newsboy",
    OnCommand = function(self)
      self:sleep(self:GetEffectDelta()):queuecommand("Update")
    end,
    UpdateCommand = function(self, params)
      if ichi.update then
        params = params or {}
        params.dt = params.dt or self:GetEffectDelta()
        params.beat = params.beat or ichi.SONG_POS:GetSongBeat()
        params.time = params.time or ichi.SONG_POS:GetMusicSeconds()
        ichi.update(params)
        self:sleep(params.dt):queuecommand("Update")
      end
    end,
  },
  LibActors,
  ichi.Actors,
  Def.ActorFrame {
    Name = "Picasso",
    OnCommand = function(self)
      if ichi.draw then
        self:SetDrawFunction(ichi.draw)
      end
    end
  }
}
