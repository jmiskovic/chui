package.path = package.path .. ";../?.lua"

local chui = require'chui'

local panel, child
for i = 1, 4 do
  panel = chui.panel{palette = chui.palettes[i+1]}
  if child then
    child.pose:scale(0.6)
    panel:nest(child)
    panel:row()
    panel:label{text ='within a', span={0.4, 0.8}}
  end
  panel:button{ text ='panel', span={0.8, 0.6}, thickness=0.2}
  panel:layout('center')
  child = panel
end

lovr.graphics.setBackgroundColor(1,1,1)


function lovr.update(dt)
  chui.update(dt)
end


function lovr.draw(pass)
  chui.draw(pass)
end