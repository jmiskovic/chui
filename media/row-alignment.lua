package.path = package.path .. ";../?.lua"

local chui = require'chui'

local panel = chui.panel{pose = mat4(0,1.5, -2):scale(0.3), palette = chui.palettes[16]}
panel:label{ text='ROW 1', text_scale=2 }
panel:button{ span= 2, thickness=0.1}
panel:row()
panel:label{ text='ROW 2', text_scale=2 }
panel:button{ span=1.5, thickness=0.1 }
panel:button{ span={1.5, 2}, thickness=0.1 }
panel:button{ span=1.5, thickness=0.1 }
panel:row()
panel:label{ text='ROW 3', text_scale=2 }
panel:button{ span= 4, thickness=0.1}
panel:layout('center', 'center')


function lovr.update(dt)
  chui.update(dt)
end


function lovr.draw(pass)
lovr.graphics.setBackgroundColor(1,1,1)
  chui.draw(pass)
  pass:setColor(0.8, 0.6, 0.6, 0.2)
  pass:transform(panel.pose)
  pass:setDepthTest('none')
  for _, widget in ipairs(panel.widgets) do
    pass:push()
    pass:transform(widget.pose)
    pass:box(0, 0, 0,  10, 0.02, 0.02)
    pass:box(0, 0, 0,  0.02, 10, 0.02)
    pass:pop()
  end

end