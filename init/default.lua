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

local funcs = {
  init = {},
  ready = {},
  update = {},
  input = {},
  draw = {},
}

-- run a file from /src
function ichi.run(path)
  if path:find("%.%.") then
    lua.ReportScriptError("Cannot run file outside of src")
    return
  end
  local data = assert(loadfile(ichi.SONG_ROOT.."src/"..path))
  ichi(data)()
  local i = {}
  -- This for loop checks for global functions in the ichi
  -- environment labeled as either "init", "ready", "update",
  -- "input", or "draw". If it finds any, it puts them into
  -- the above `funcs` table and erases them from the
  -- ichi environment. This allows for scripts to implement
  -- user-defined hooks of the same names without clashing
  -- with existing hooks.
  for name in pairs(funcs) do
    i[name] = ichi[name]
    if i[name] then
      if type(i[name]) == "function" then
        table.insert(funcs[name], i[name])
      end
      ichi[name] = nil
    end
  end
end
-- include a file from /include
function ichi.include(name)
  local data = assert(loadfile(ichi.SONG_ROOT.."include/"..name..".lua"))
  ichi(data)()
end

local function read_config(key, file, cat)
  if cat == nil then
    error("Category must be defined.")
    return
  end
  if not FILEMAN:DoesFileExist(file) then
    local createfile = RageFileUtil.CreateRageFile()
    createfile:Open(file, 2)
    createfile:Write("")
    createfile:Close()
    createfile:destroy()
  end
  local configfile = RageFileUtil.CreateRageFile()
  configfile:Open(file, 1)
  local configcontent = configfile:Read()
  configfile:Close()
  configfile:destroy()
  configcontent = configcontent:gsub("\r\n", "\n")
  local caty = true
  for line in string.gmatch(configcontent.."\n", "(.-)\n") do
    for con in string.gmatch(line, "%[(.-)%]") do
      caty = con == cat
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
local function write_config(key, value, file, cat)
  if cat == nil then
    error("Category must be defined.")
    return
  end
  if not FILEMAN:DoesFileExist(file) then
    local createfile = RageFileUtil.CreateRageFile()
    createfile:Open(file, 2)
    createfile:Write("")
    createfile:Close()
    createfile:destroy()
  end
  local container = {}
  local configcontent
  local configfile = RageFileUtil.CreateRageFile()
  if configfile:Open(file, 1) then
    configcontent = configfile:Read()
  end
  configfile:Close()
  local found = false
  local caty = true
  local current_cat = ""
  for line in string.gmatch(configcontent.."\n", "(.-)\n") do
    for con in string.gmatch(line, "%[(.-)%]") do
      print(con)
      caty = con == cat
      container[con] = {}
      current_cat = con
    end
    for keyval, val in string.gmatch(line, "(.-)=(.+)") do
      if key == keyval then
        if caty then
          val = value
          found = true
        end
      end
      if container[current_cat] then
        container[current_cat][keyval] = val
      end
      break
    end
  end
  if found == false then
    container[cat] = container[cat] or {}
    container[cat][key] = value
  end
  local output = ""
  for category in pairs(container) do
    if output ~= "" then
      output = output.."\n"
    end
    output = output.."["..category.."]".."\n"
    for k, v in pairs(container[category]) do
      output = output..k.."="..tostring(v).."\n"
    end
  end
  configfile:Open(file, 2)
  configfile:Write(output)
  configfile:Close()
  configfile:destroy()
end

-- We don't want to read from file every time, so save our settings in a table.
local settings = {}
function ichi.setting(category, name, default)
  if not settings[category] or not settings[category][name] then
    local val = read_config(name, ichi.SONG_ROOT.."settings.ini", category)
    if val == nil then
      if default ~= nil then
        val = default
        write_config(name, val, ichi.SONG_ROOT.."settings.ini", category)
      else
        error("No value for setting \""..name.."\" in category \""..category.."\".")
        return
      end
    end
    val = tonumber(val) or tobool(val) or val
    settings[category] = settings[category] or {}
    settings[category][name] = val
  end
  return settings[category][name]
end

-- grab from settings
ichi.IH = ichi.setting("Ichigo", "IntendedHeight", ichi.SH)

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
  FOV = 120,
  InitCommand = function(self)
    ichi.Actors.Pivot = self
    self:Center()
    for i = 1, self:GetNumWrapperStates() do
      self:RemoveWrapperState(i)
    end
    ichi.Actors.Frame = self:AddWrapperState()
  end,
  OnCommand = function(self)
    ichi.Actors.Screen = SCREENMAN:GetTopScreen()
    ichi.Actors.Overlay = ichi.Actors.Screen:GetChild("Overlay")
    ichi.Actors.Underlay = ichi.Actors.Screen:GetChild("Underlay")
    for _, pn in ipairs(ichi.Players) do
      ichi.Actors[pn] = ichi.Actors.Screen:GetChild("Player"..pn)
      ichi.Actors[pn].Life = ichi.Actors.Screen:GetChild("Life"..pn)
      ichi.Actors[pn].Score = ichi.Actors.Screen:GetChild("Score"..pn)

      ichi.Actors[pn].Columns = ichi.Actors[pn]:GetChild("NoteField"):GetColumnActors()
      ichi.Actors[pn].NoteData = ichi.Actors[pn]:GetNoteData()
    end
    for _, func in ipairs(funcs.ready) do func() end
    for _, func in ipairs(funcs.input) do
      ichi.Actors.Screen:AddInputCallback(func)
    end
    if ichi.Actors.Screen.GetEditState and not ichi.Actors.Overlay:GetChild("InputCleaner") then
      ichi.Actors.Overlay:AddChild(function()
        return Def.Actor {
          Name = "InputCleaner",
          EditCommand = function(self)
            for _, func in ipairs(funcs.input) do
              ichi.Actors.Screen:RemoveInputCallback(func)
            end
            ichi.Actors.Overlay:RemoveChild(self:GetName())
          end,
        }
      end)
    end
  end,
  OffCommand = function(self)
    for _, func in ipairs(funcs.input) do
      ichi.Actors.Screen:RemoveInputCallback(func)
    end
  end,
  Def.Actor {
    Name = "Sleepyhead",
    InitCommand = function(self) self:sleep(9e9) end,
  },
  Def.Actor {
    Name = "Newsboy",
    OnCommand = function(self)
      if #funcs.update > 0 then
        self:sleep(self:GetEffectDelta()):queuecommand("Update")
      end
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
