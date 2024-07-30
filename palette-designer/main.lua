-- chui palette designer for modifying and creating new color palettes
package.path = package.path .. ";../?.lua" -- needed only if chui.lua is in parent directory

local chui = require'chui'
local coloring = require'coloring'

lovr.graphics.setBackgroundColor(1,1,1)

local palette = chui.palettes[1]
local panel = chui.panel{ pose = mat4(0, 1.7, -0.4):scale(0.05), palette=palette }

panel:slider{ text = 'edited palette', step=1, min=1, max=#chui.palettes, span=4, format = '%s %d',
  callback = function(_, value)
    panel.palette = chui.palettes[value]
    -- update existing sliders
    for _, panel in ipairs(panel.widgets) do
      if panel.color_name then
        local h,s,l = unpack(coloring.toHSL(panel.palette[panel.color_name]))
        panel.slider_h:set(h)
        panel.slider_s:set(s)
        panel.slider_l:set(l)
      end
    end
  end }
panel:button{ text = 'dump', thickness=0.2, callback =
  function()
    print(coloring.chuiPaletteString(palette))
  end }
panel:row()

local function createHSLpanel(color_name)
  local color_panel = chui.panel{ frame = 'none' }
  color_panel.palette = setmetatable({}, {
    __index = function(table, key)
      if key == 'inactive' then
        return panel.palette[color_name]
      else
        return panel.palette[key]
      end
    end,
  })

  local h,s,l = unpack(coloring.toHSL(panel.palette[color_name]))
  local slider_h, slider_s, slider_l
  local sliderChange = function()
    local color = coloring.fromHSL{
      color_panel.slider_h.value,
      color_panel.slider_s.value,
      color_panel.slider_l.value
    }
    panel.palette[color_name] = color
  end
  color_panel:label{ text = color_name:upper(), span = { 1, 0.2 }, text_scale = 1.6 }
  color_panel:glow()
  color_panel:row()

  color_panel.slider_h = color_panel:slider{ text='hue',        value=h,  span=2.5, callback=sliderChange }; color_panel:row()
  color_panel.slider_s = color_panel:slider{ text='saturation', value=s,  span=2.5, callback=sliderChange }; color_panel:row()
  color_panel.slider_l = color_panel:slider{ text='lightness',  value=l,  span=2.5, callback=sliderChange }; color_panel:row()
  color_panel.color_name = color_name
  color_panel:layout()
  return color_panel
end


panel:nest(createHSLpanel('cap'))
panel:spacer{ span= 0.2 }
panel:nest(createHSLpanel('inactive'))
panel:spacer{ span= 0.2 }
panel:nest(createHSLpanel('active'))
panel:row()
panel:nest(createHSLpanel('hover'))
panel:spacer{ span= 0.2 }
panel:nest(createHSLpanel('text'))
panel:spacer{ span= 0.2 }
panel:nest(createHSLpanel('panel'))
panel:row()

panel:label{ text = 'previews:' }
local led = panel:glow{ text = 'GLW' }
local led = panel:glow{ text = 'GLW', state=true }
panel:toggle{ text = 'TGL' }
panel:toggle{ text = 'TGL', state=true }
panel:progress{ text = 'PRG', value = 0.7 }
panel:slider{ text = 'SLD', value = 0.3 }
panel:layout()


function lovr.update(dt)
  chui.update(dt)
end

function lovr.draw(pass)
  chui.draw(pass)
end
