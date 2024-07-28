local chui = require'chui'

local main_panel, options_panel
local is_wireframe = false
local rgb_filter = {true, true, true}

function lovr.load()
  local pose = mat4(-0.2, 1.7, -0.4):scale(0.1)
  -- Main Menu Buttons
  main_panel = chui.panel{ pose=pose, palette=chui.palettes[3] }
  playbutton_panel = chui.panel{ frame='none', palette=chui.palettes[1] }
  playbutton_panel:button{ text='CONTINUE', thickness=0.3, span={3, 1.4}, callback =
    function()
      main_panel.visible = false
    end }
  playbutton_panel:layout()
  main_panel:nest(playbutton_panel)
  main_panel:row()
  main_panel:button{ text='OPTIONS', thickness=0.2, span=3, callback =
    function()
      main_panel.visible = false
      options_panel.visible = true
    end }
  main_panel:row()
  main_panel:row()
  main_panel:button{ thickness=0.2, span={3, 0.8}, text='HELP' }
  main_panel:row()
  main_panel:button{ thickness=0.2, span={3, 0.8}, text='CREDITS' }
  main_panel:row()
  main_panel:row()
  main_panel:button{ thickness=0.2, span={3, 0.6}, text='EXIT »', callback=function() lovr.event.quit() end }
  main_panel:layout('left')

  -- Options Panel (initially hidden)
  options_panel = chui.panel{ pose=mat4(pose):scale(0.6), palette=chui.palettes[3] }
  options_panel:label{ text='Video', text_scale=2 }
  options_panel:row()
  options_panel:label{ text='Wireframe' }
  options_panel:toggle{ span={0.8, 0.8}, thickness=0.15, state=false, callback =
    function(_, state)
      is_wireframe = state
    end }
  options_panel:layout('left')
  options_panel:row()
  options_panel:label{ text='Color filtering' }
  options_panel:toggle{ span={0.8, 0.8}, thickness=0.15, state=true, text='R', callback=function(_,s) rgb_filter[1] = s end }
  options_panel:toggle{ span={0.8, 0.8}, thickness=0.15, state=true, text='G', callback=function(_,s) rgb_filter[2] = s end }
  options_panel:toggle{ span={0.8, 0.8}, thickness=0.15, state=true, text='B', callback=function(_,s) rgb_filter[3] = s end }
  options_panel:row()
  options_panel:label{ text='Audio', text_scale=2 }
  options_panel:row()
  options_panel:toggle{ span={0.8, 0.8}, thickness=0.15, state=true }
  options_panel:slider{ text='Sound', step=1, min=0, max=100, value=80, format='%s %d', span=4 }
  options_panel:row()
  options_panel:toggle{ span={0.8, 0.8}, thickness=0.15, state=true }
  options_panel:slider{ text='Music', step=1, min=0, max=100, value=75, format='%s %d', span=4 }
  options_panel:row()
  options_panel:row()
  options_panel:button{ text='«  BACK', thickness=0.15, span={1.4, 0.8}, callback =
    function()
      main_panel.visible = true
      options_panel.visible = false
    end }
  options_panel:layout('left')
  options_panel.visible = false
end


-- a 3D scene placeholder
lovr.graphics.setBackgroundColor(0.059, 0.165, 0.247)
local palette = {{0.031, 0.078, 0.118}, {0.125, 0.224, 0.310}, {0.965, 0.839, 0.741}, {0.765, 0.639, 0.541}, {0.600, 0.459, 0.467}, {0.506, 0.384, 0.443}, {0.306, 0.286, 0.373}}

function sceneDraw(pass)
  local t = lovr.timer.getTime()
  for x = -64, 64, 4 do
    for z = -64, 64, 4 do
      z = z + (x % 8) * 0.5
      local h = lovr.math.noise(x, z) * 3 + (x*x + z*z) * 5e-3
      pass:setColor(palette[1 + math.floor(h * 7) % #palette])
      h = h * (1 + 0.05 * math.sin(t * 0.2 + h))
      pass:cylinder(x, -3 + h / 2, z,  2.2, h,  math.pi/2, 1,0,0,  true, nil, nil, 6)
    end
  end
end


function lovr.draw(pass)
  main_panel.pose:rotate(math.sin(lovr.timer.getTime() * 4) * 0.002,  0, 1, 0)
  options_panel.pose:rotate(math.sin(lovr.timer.getTime() * 4) * 0.002,  0, 1, 0)
  pass:setColorWrite(unpack(rgb_filter))
  pass:setWireframe(is_wireframe)
  sceneDraw(pass)
  chui.draw(pass, true)
end


function lovr.update(dt)
  chui.update(dt)
end


function lovr.keypressed(key)
  if key == 'escape' then
    main_panel.visible = true
    options_panel.visible = false
  end
end
