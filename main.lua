local ui = require'vr-ui'
local palette = require'palette-akc12'

local mousearm = require'mousearm'


function lovr.load()
  local pose = mat4():target(vec3(0, -0.2, -0.8), vec3(lovr.headset.getPosition()))
  pose:scale(0.2)
  panel = ui.panel(pose)
  panel:label{text='|'}
  led = panel:glow{text='GLOW', span=2}
  panel:label{text='|'}
  panel:button{text='PRESS', span=2, callback=function(_, state) led:set(not led:get()) end}
  panel:toggle{text='TGG', span=1}
  panel:row()
  panel:slider{text='slide', span=2}
  prog = panel:slider{text='progress', span=3}
  panel:asGrid()
end


function lovr.update(dt)
  panel:update(dt)
  prog:set(0.5 + 0.5 * math.sin(lovr.timer.getTime()))
end


function lovr.draw(pass)
  local vs = math.pi / 8
  panel:draw(pass)
  pass:setColor(palette[12])
  ui.drawPointers(pass)
end


