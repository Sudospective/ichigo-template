include 'gizmos'


-- main
function wm_ready()
  do GoodBoy
    :Center()
    :SetSize(96, 96)
    :zoom(0)
    :rotationz(360)
    :shadowcolor(0, 0, 0, 0.5)
    :shadowlengthy(3)
  end
  do Strawb
    :Center()
    :Load(SRC_ROOT..'/assets/strawb.png')
    :SetSize(64, 64)
    :zoom(0)
  end
  do Ichigo
    :LoadFromFont(THEME:GetPathF('Common', 'Normal'))
    :Center()
    :diffuse(0, 0, 0, 1)
    :settext('イチゴ')
    :wag()
    :effectmagnitude(0, 0, 5)
    :zoom(0)
  end
  do Template
    :LoadFromFont(THEME:GetPathF('Common', 'Normal'))
    :Center()
    :addy(96)
    :settext('Ichigo Template')
    :cropright(1)
    :shadowcolor(0, 0, 0, 0.5)
    :shadowlengthy(3)
  end
end
function wm_update(params)
  do GoodBoy
    :addrotationz(-30 * params.dt)
  end
end


-- layout
GoodBoy = Rect:new()
Strawb = Image:new()
Ichigo = Label:new()
Template = Label:new()


-- gimmicks
gimmick
  {0, function()

    do GoodBoy
      :stoptweening()
      :easeoutquint(2)
      :zoom(1)
      :rotationz(-45)
    end
    do Strawb
      :stoptweening()
      :easeoutback(0.25)
      :zoom(1)
    end
    do Ichigo
      :stoptweening()
      :easeoutback(0.25)
      :zoom(1)
    end
    do Template
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
    do Strawb
      :stoptweening()
      :easeinback(0.25)
      :zoom(0)
    end
    do Ichigo
      :stoptweening()
      :easeinback(0.25)
      :zoom(0)
    end
    do Template
      :stoptweening()
      :linear(0.25)
      :cropright(1)
    end
    
  end}
