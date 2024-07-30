-- widgets test app and palette editor
package.path = package.path .. ";../?.lua" -- needed only if chui.lua is in parent directory

local chui = require'chui'

local pose = mat4()
  :translate(0, 1.6, -0.4)
  :rotate(-0.2, 1,0,0)
  :scale(0.06)

local panel = chui.panel{ pose = pose }

panel:label{ text='chui', span=1.4, text_scale=4 }
panel:label{ text='testing app', span=1 }
panel:spacer{ span=1.5 }
panel:slider{ text = 'palette', step=1, min=1, max=#chui.palettes, span=3, format = '%s %d',
  callback = function(_, value)
    panel.palette = chui.palettes[value]
  end }
panel:row()


-- a zoo of built-in widgets
local glow, progress
panel:label{ text = 'spacer >', span = .5 }
panel:spacer{ span = .2 }
panel:label{ text = '<', span = .2 }
panel:label{ text='|', span=0.2, text_scale=3 }
panel:label{ text = 'label' }
panel:label{ text='|', span=0.2, text_scale=3 }
panel:button{ text='button', span=2, thickness=0.1,  callback=
  function(self)
    glow:set(not glow:get())
  end }
panel:label{ text='|', span=0.2, text_scale=3 }
glow = panel:glow{ text='glow', state=true }
panel:row()
panel:toggle{ text='toggle', span={1.5, 1.5} }
panel:label{ text='|', span=0.2, text_scale=3 }
progress = panel:progress{ text='progress', span = 2 }
panel:label{ text='|', span=0.2, text_scale=3 }
panel:slider{ text='slider', span=3, step = 0.25, min=1, max = 5, callback=
  function(self, value)
    local normalized = (value - self.min) / (self.max - self.min)
    progress:set(normalized)
  end }
panel:layout()

lovr.graphics.setBackgroundColor(1,1,1)

function lovr.update(dt)
  panel:update(dt)
end


function lovr.draw(pass)
  pass:setWireframe(lovr.system.isKeyDown('tab')) -- x-vision
  chui.draw(pass)
  pass:setColor(0.8, 0.9, 0.5)
end
