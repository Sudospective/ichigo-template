if ProductFamily() ~= "OutFox" then
  error("This template is only compatible with Project OutFox.")
  return Def.Actor {}
end

local ichi = setmetatable({}, {
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
ichi.SRC_ROOT = ichi.SONG_ROOT.."src"
ichi.__version = "1.3"

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
ichi.NoteData = {}

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
local funcs = {
  init = {},
  ready = {},
  update = {},
  input = {},
  draw = {},
}
function ichi.run(path)
  local data = assert(loadfile(ichi.SONG_ROOT.."src/"..path))
  ichi(data)()
  local i = {}
  for name in pairs(funcs) do
    i[name] = ichi[name]
    if i[name] then
      table.insert(funcs[name], i[name])
      ichi[name] = nil
    end
  end
end
-- include a file from /include
function ichi.include(name)
  local data = assert(loadfile(ichi.SONG_ROOT.."include/"..name..".lua"))
  ichi(data)()
end

local function config(key, file, cat)
  if not FILEMAN:DoesFileExist(file) then return end
  local container = {}
  local configfile = RageFileUtil.CreateRageFile()
  configfile:Open(file, 1)
  local configcontent = configfile:Read()
  configfile:Close()
  configfile:destroy()
  configcontent = configcontent:gsub("\r\n", "\n")
  local caty = true
  for line in string.gmatch(configcontent.."\n", "(.-)\n") do
    for con in string.gmatch(line, "%[(.-)%]") do
      if con == cat or cat == nil then caty = true else caty = false end
    end
    for keyval, val in string.gmatch(line, "(.-)=(.+)") do
      if key == keyval and caty then
        if val == "true" then return true end
        if val == "false" then return false end
        return val
      end
    end
  end
end

local settings = {}
function ichi.setting(name)
  if not settings[name] then
    local value = config(name, ichi.SONG_ROOT.."settings.ini")
    if value == nil then
      error("No value for setting \""..name.."\".")
      return
    end
    value = tonumber(value) or tobool(value) or value
    settings[name] = value
  end
  return settings[name]
end

-- grab from settings
ichi.IH = ichi.setting "IntendedHeight"

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
    ichi.run("plugins/"..v)
  end
end

ichi.run("main.lua")
for _, func in ipairs(funcs.init) do func() end

return Def.ActorFrame {
  FOV = 120, -- the fov of one human eye
  InitCommand = function(self)
    ichi.Actors.Frame = self
    self:Center()
  end,
  OnCommand = function(self)
    ichi.Actors.Screen = SCREENMAN:GetTopScreen()
    for _, pn in ipairs(ichi.Players) do
      ichi.Actors[pn] = ichi.Actors.Screen:GetChild("Player"..pn)
      ichi.Columns[pn] = ichi.Actors[pn]:GetChild("NoteField"):GetColumnActors()
      ichi.NoteData[pn] = ichi.Actors[pn]:GetNoteData()
    end
    for _, func in ipairs(funcs.ready) do func() end
    for _, func in ipairs(funcs.input) do
      SCREENMAN:GetTopScreen():AddInputCallback(func)
    end
    if SCREENMAN:GetTopScreen().GetEditState then
      SCREENMAN:GetTopScreen():GetChild("Overlay"):AddChild(function()
        return Def.Actor {
          Name = "InputCleaner",
          EditCommand = function(self)
            for _, func in ipairs(funcs.input) do
              SCREENMAN:GetTopScreen():RemoveInputCallback(func)
            end
            SCREENMAN:GetTopScreen():GetChild("Overlay"):RemoveChild(self:GetName())
          end,
        }
      end)
    end
  end,
  OffCommand = function(self)
    for _, func in ipairs(funcs.input) do
      SCREENMAN:GetTopScreen():RemoveInputCallback(func)
    end
  end,
  Def.Actor {
    Name = "Sleepyhead",
    InitCommand = function(self) self:sleep(9e9) end,
  },
  Def.Actor {
    Name = "Newsboy",
    OnCommand = function(self)
      self:sleep(self:GetEffectDelta()):queuecommand("Update")
    end,
    UpdateCommand = function(self, params)
      params = params or {}
      params.dt = params.dt or self:GetEffectDelta()
      params.beat = params.beat or ichi.SONG_POS:GetSongBeat()
      params.time = params.time or ichi.SONG_POS:GetMusicSeconds()
      for _, func in ipairs(funcs.update) do func(params) end
      self:sleep(params.dt):queuecommand("Update")
    end,
  },
  LibActors,
  Def.ActorFrame {
    Name = "CenterWrapper",
    InitCommand = function(self)
      self:xy(-ichi.SCX, -ichi.SCY)
    end,
    ichi.Actors,
  },
  Def.ActorFrame {
    Name = "Picasso",
    OnCommand = function(self)
      if #funcs.draw > 0 then
        self:SetDrawFunction(function()
          for _, func in ipairs(funcs.draw) do func() end
        end)
      end
    end,
  },
}
