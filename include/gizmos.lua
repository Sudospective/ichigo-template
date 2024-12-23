if Gizmo then return end

class "Gizmo" {
  __type = "Actor";
  __init = function(self, ...)
    if not ActorUtil.IsRegisteredClass(self.__type) then
      lua.ReportScriptError("Invalid Actor class \""..self.__type.."\".")
      return
    end
    self.__actor = Def[self.__type] {}
    local t = self.__type == "Sound" and ActorSound or _G[self.__type] or {}
    for k, v in pairs(Actor) do
      t[k] = v
    end
    for k, v in pairs(t) do
      self[k] = function(s, ...)
        return v(self.__actor, ...) or self.__actor
      end
    end
    self.__actor.InitCommand = function(s)
      self.__actor = s
    end
    if self.__ready then
      self:__ready(...)
    end
    --table.insert(Actors, self.__actor)
  end;
  GetActor = function(self)
    return self.__actor
  end;
}

class "Container" : extends "Gizmo" {
  __type = "ActorFrame";
  __ready = function(self)
    self:GetActor().FOV = 45
  end;
  AddGizmo = function(self, gizmo)
    table.insert(self.__actor, gizmo.__actor)
    return self
  end;
}

class "RollingContainer" : extends "Container" {
  __type = "ActorScroller";
}

class "Rect" : extends "Gizmo" {
  __type = "Quad";
}

class "Image" : extends "Gizmo" {
  __type = "Sprite";
  __ready = function(self, path)
    if path then
      self:GetActor().Texture = SRC_ROOT..path
    end
  end;
}

class "MultiImage" : extends "Gizmo" {
  __type = "ActorMultiTexture";
}

class "Label" : extends "Gizmo" {
  __type = "BitmapText";
  __ready = function(self, text, font)
    if font and font:find("/") then
      font = SRC_ROOT..font
    end
    self:GetActor().Font = font or "Common Normal"
    self:GetActor().Text = text or "Sample text"
  end;
}

class "RenderTarget" : extends "Container" {
  __type = "ActorFrameTexture";
}

class "Viewport" : extends "Container" {
  __type = "ActorScreenTexture";
}

class "ShaderLoader" : extends "Container" {
  __ready = function(self)
    if not go() then
      SCREENMAN:SystemMessage("ShaderLoader: Alpha V not detected")
      self.LoadShader = function() end -- noop
    end
  end;
  LoadShader = function(self, path, name)
    local shader = Def.Actor {
      Frag = SRC_ROOT..path,
      InitCommand = function(s)
        self[name] = s:GetShader()
        s:visible(false)
      end
    }
    table.insert(self:GetActor(), 1, shader)
    return self
  end;
}

class "Model3D" : extends "Gizmo" {
  __type = "Model";
  __ready = function(self, path)
    if path then
      self:LoadMeshes(path)
      self:LoadMaterials(path)
    end
  end;
  LoadMeshes = function(self, path)
    self:GetActor().Meshes = SRC_ROOT..path
    return self
  end;
  LoadMaterials = function(self, path)
    self:GetActor().Materials = SRC_ROOT..path
    return self
  end;
}

class "Audio" : extends "Gizmo" {
  __type = "Sound";
  __ready = function(self, path)
    if path then
      self:GetActor().File = SRC_ROOT..path
      self:GetActor().Precache = true
    end
  end;
  SetPrecache = function(self, b)
    self:GetActor().Precache = b
  end;
}

class "Proxy" : extends "Gizmo" {
  __type = "ActorProxy";
}

class "PlayField" : extends "Gizmo" {
  __type = "NoteField";
}

class "FakePlayer" : extends "Container" {
  __ready = function(self)
    local function metric(str)
      return tonumber(THEME:GetMetric("Player", str))
    end
    self:GetActor().FOV = 45
    local nf = Def.NoteField {
      Name = "NoteField",
      DrawDistanceAfterTargetsPixels = metric "DrawDistanceAfterTargetsPixels",
      DrawDistanceBeforeTargetsPixels = metric "DrawDistanceBeforeTargetsPixels",
      YReverseOffsetPixels = metric "ReceptorArrowsYReverse" - metric "ReceptorArrowsYStandard",
      AutoPlay = true,
      FieldID = #Players + 1,
      Player = #Players % 2,
      NoteSkin = Options[Players[1]]:NoteSkin(),
      OnCommand = function(s)
        s.FieldID = register(s)
        s.Player = (s.FieldID - 1) % #Players
        local plr = s:GetParent()
        if not plr then return end
        local po = s:GetPlayerOptions("ModsLevel_Current")
        local vanishx = plr.vanishpointx
        local vanishy = plr.vanishpointy
        function plr:vanishpointx(n)
          local offset = scale(po:Skew(), 0, 1, plr:GetX(), SCREEN_CENTER_X)
          vanishx(plr, offset + n)
          return s
        end
        function plr:vanishpointy(n)
          local offset = SCREEN_CENTER_Y
          vanishy(plr, offset + n)
          return s
        end
        function plr:vanishpoint(x, y)
          return plr:vanishpointx(x):vanishpointy(y)
        end
        local nfmid = (metric "ReceptorArrowsYStandard" + metric "ReceptorArrowsYReverse") / 2
        plr:Center():zoom(SCREEN_HEIGHT / 480)
        s:y(nfmid)
        s:ChangeReload(Charts["P"..(s.Player + 1)])
      end,
    }
    table.insert(self:GetActor(), nf)
  end;
}

class "ProxyWall" : extends "RollingContainer" {
  __ready = function(self, length, pattern)
    local a = self:GetActor()
    local width = GAMESTATE:GetStyleFieldSize("PlayerNumber_P1") * SCREEN_HEIGHT / 480
    length = length or math.ceil(SCREEN_WIDTH * 1.5 / width)
    pattern = pattern or {1, 2}
    if type(pattern) == "number" then
      pattern = {pattern}
    end
    a.FOV = 45
    a.UseScroller = true
    a.SecondsPerItem = 0
    a.NumItemsToDraw = length
    a.ItemPaddingStart = 0
    a.ItemPaddingEnd = 0
    a.TransformFunction = function(s, offset, itemIndex, numItems)
      s:x((offset + ((length - 1) % 2) * 0.5) * width)
    end
    a.OnCommand = function(s)
      s:SetLoop(true):SetFastCatchup(true):rotafterzoom(false)
      for _, v in ipairs(pattern) do
        local p = "P"..v
        s:AddChild(function()
          return Def.ActorProxy {
            Name = p,
            OnCommand = function(s)
              s:SetTarget(Actors[p]:GetChild("NoteField"))
              s:basezoom(SCREEN_HEIGHT / 480):rotafterzoom(false)
            end,
          }
        end)
      end
      if s:GetNumWrapperStates() > 0 then
        for i = 1, s:GetNumWrapperStates() do
          s:RemoveWrapperState(i)
        end
      end
      local wrapper = s:AddWrapperState()
      wrapper
        :Center()
        :fov(45)
        :rotafterzoom(false)
      function s:rotationx(n)
        wrapper:rotationx(n)
        return s
      end
      function s:rotationy(n)
        wrapper:rotationy(n)
        return s
      end
      function s:rotationz(n)
        wrapper:rotationz(n)
        return s
      end
    end
  end;
  SetWallX = function(self, offset)
    self:GetActor():SetCurrentAndDestinationItem(offset)
    return self
  end;
}

class "Polygon" : extends "Gizmo" {
  __type = "ActorMultiVertex";
}

class "Input" : extends "Gizmo" {
  __type = "Actor";
  __enabled = true;
  __ready = function(self)
    self:GetActor().OffCommand = function(s)
      if self.__callback then
        SCREENMAN:GetTopScreen():RemoveInputCallback(self.__callback)
      end
    end
  end;
  SetEnabled = function(self, b)
    if b == nil then return end
    self.__enabled = b
    return self
  end;
  IsEnabled = function(self)
    return self.__enabled
  end;
  SetInputCallback = function(self, callback)
    if self.__callback then
      SCREENMAN:GetTopScreen():RemoveInputCallback(self.__callback)
    end
    self.__callback = function(event)
      if not self.__enabled then return end
      callback(event)
    end
    SCREENMAN:GetTopScreen():AddInputCallback(self.__callback)
    return self
  end;
}

class "AudioWaveform" : extends "Gizmo" {
  __type = "AudioVisualizer";
  __ready = function(self)
    local init = self:GetActor().InitCommand
    self:GetActor().InitCommand = function(s)
      init(s)
      s:SetSound(SCREENMAN:GetTopScreen():GetSound())
    end
    self:GetActor().UpdateRate = 1/60
  end;
}
