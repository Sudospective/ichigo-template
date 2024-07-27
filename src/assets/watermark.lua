include "gizmos"

-- main
function wm_ready()
  do GoodBoy
    :Center()
    :basezoom(SH / IH)
    :SetSize(96, 96)
    :diffuse(1, 0.8, 0.8, 1)
    :zoom(0)
    :rotationz(360)
    :shadowcolor(0, 0, 0, 0.5)
    :shadowlengthy(3)
  end
  do Ichigo
    :Center()
    :basezoom(SH / IH)
    :SetSize(64 * Ichigo:GetTexture():GetSourceWidth() / Ichigo:GetTexture():GetSourceHeight(), 64)
    :zoom(0)
  end
  do TemplateText
    :LoadFromFont(THEME:GetPathF("Common", "Normal"))
    :Center()
    :basezoom(SH / IH)
    :addy(96)
    :settext("Ichigo Template")
    :cropright(1)
    :shadowcolor(0, 0, 0, 0.5)
    :shadowlengthy(3)
  end
end

function wm_update(params)
  GoodBoy:addrotationz(-30 * params.dt)
end

-- layout
GoodBoy = Rect:new()
Ichigo = Image:new("/assets/ichigo.png") -- art by draco_system
TemplateText = Label:new()

-- gimmicks
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
