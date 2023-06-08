local chui = require'chui'

local pose = mat4()
  :translate(0, 1.6, -0.5)
  :rotate(math.pi, 0,1,0)
  :rotate(0.2, 1,0,0)
  :scale(0.08)
local panel = chui.panel()
panel.pose:set(pose)
panel:label{ text='chui', span=4, text_scale=4 }
panel:spacer{ span=3 }
panel:label{ text='testing app', span=1 }
panel:row()

local led
panel:button{ text='PRESS', span=2, callback=function() led:set(not led:get()) end }
led = panel:glow{text='GLOW', span=1, state=true }
panel:label{ text='|',span=0.4, text_scale=3 }
panel:button{ text='cnt', span=2,
  callback=function(btn)
    btn.cnt = (btn.cnt or 0) + 1
    btn.text = 'cnt ' .. btn.cnt
  end}
panel:label{ text='|',span=0.4, text_scale=3 }
panel:toggle{ text='TGG', span=1 }
panel:row()

local progresses = {}
local function slideChange(widget, value)
  for i = 3, 1, -1 do
    if i == 1 then
      progresses[i]:set(value)
    else
      progresses[i]:set(progresses[i - 1]:get())
    end
  end
end

panel:slider{ text='slide', span=3, callback=slideChange }
for i = 1, 3 do
  panel:label{ text='>',span=0.2 }
  table.insert(progresses,
    panel:progress{ text='hist' .. i, span=1 })
end

panel:layout()

-- colorizer can cycle through palettes and edit colors
-- when enabled with F1 the right-mouse + gesture changes the HSL of selected color in palette
-- horizontal gesture changes hue, one diagonal changes saturation while other modifies lightnes
-- F2 cycles through predefined palettes, F3 selects which color in palette is currently edited
-- when done editing, press F4 to print out your fancy new palette in the console
local colorizer = require'colorizer'
colorizer.enabled = false
colorizer.setPalette(panel.palette)
colorizer.texture = nil

function lovr.update(dt)
  panel:update(dt)
  colorizer.update(dt)
end

--lovr.graphics.setBackgroundColor(1,1,1)

function lovr.draw(pass)
  pass:setWireframe(lovr.system.isKeyDown('tab')) --  x-vision
  chui.draw(pass)
  chui.drawPointers(pass)
  if colorizer.texture then -- show a baked texture created from palette
    pass:setColor(1,1,1)
    pass:setMaterial(colorizer.texture)
    pass:setSampler('nearest')
    pass:plane(1, 2, -2, 1, 1, 0, 0, 1)
    pass:setMaterial()
  end
  if colorizer.enabled then -- visualize currently edited color
    pass:setColor(colorizer.palette[colorizer.edited])
    pass:sphere(0, 2, -2, 0.05)
  end
end


function lovr.keypressed(key)
  if key == 'f1' then -- enable/disable color editing
    colorizer.enabled = not colorizer.enabled
  elseif key == 'f2' then -- cycle to next predefined palette
    chui.palettes.active = 1 + chui.palettes.active % #chui.palettes
    colorizer.setPalette(chui.palettes[chui.palettes.active])
    panel.palette = chui.palettes[chui.palettes.active]
  elseif key == 'f3' then -- select next color in this palette
    colorizer.select()
  elseif key == 'f4' then -- print out the edited palette
    print(colorizer.info())
  elseif key == 'f5' then -- bake colors into a texture
    colorizer.texture = lovr.graphics.newTexture(colorizer.toImage())
  end
end
