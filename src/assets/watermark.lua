-- Include Gizmo header
include "gizmos"


--main

-- These hooks can be written in multiple scripts,
-- each script will have its own hook associated with it
function ready()
  Watermark:Center():basezoom(SH / IH)
  do GoodBoy
    :SetSize(96, 96)
    :diffuse(1, 0.8, 0.8, 1)
    :zoom(0)
    :rotationz(360)
    :shadowcolor(0, 0, 0, 0.5)
    :shadowlengthy(3)
  end
  do Ichigo
    :SetSize(64 * Ichigo:GetTexture():GetSourceWidth() / Ichigo:GetTexture():GetSourceHeight(), 64)
    :zoom(0)
  end
  do TemplateText
    :addy(96)
    :cropright(1)
    :shadowcolor(0, 0, 0, 0.5)
    :shadowlengthy(3)
  end
end

function update(params)
  GoodBoy:addrotationz(-30 * params.dt)
end


-- layout

-- We can create Gizmos, which are like Actors, but have a simpler
-- way to create them. Keep in mind of the different names that
-- correspond to different Actors; you can find a list here:
-- https://ichigo-docs.sudospective.net/ichigo-template-docs/gizmos
Watermark = Container:new()
GoodBoy = Rect:new()
Ichigo = Image:new("/assets/ichigo.png") -- art by draco_system
TemplateText = Label:new("Ichigo Template")

Watermark:AddGizmo(GoodBoy)
Watermark:AddGizmo(Ichigo)
Watermark:AddGizmo(TemplateText)

AddGizmo(Watermark)


-- gimmicks

-- The `gimmick` command works similarly to how the `func` command
-- works in Mirin template versions under 4.0, with the added
-- functionality of `set` and `ease`. Here is an example of it being
-- used for `func`-like behavior.
gimmick
  {0, function()
    do GoodBoy
      :stoptweening()
      :easeoutquint(2)
      :zoom(1)
      :rotationz(-45)
    end
    do Ichigo
      :stoptweening()
      :easeoutback(0.25)
      :zoom(1)
    end
    do TemplateText
      :stoptweening()
      :sleep(1)
      :linear(0.25)
      :cropright(0)
    end
  end}
  {9, function()
    do GoodBoy
      :stoptweening()
      :easeinquad(0.5)
      :addrotationz(-360)
      :zoom(0)
    end
    do Ichigo
      :stoptweening()
      :easeinback(0.25)
      :zoom(0)
    end
    do TemplateText
      :stoptweening()
      :linear(0.25)
      :cropright(1)
    end
  end}
