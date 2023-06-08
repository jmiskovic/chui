-- virtual keyboard is both a demo app for chui and a useable keyboard module
local chui = require'chui'

local keyboard = require'vqwerty' -- pressed keys are received with lovr.textinput & lovr.keypressed
keyboard.pose:set(
  mat4()
    :target(vec3(0, 1.6, -0.35), vec3(0, 2, 0))
    :scale(0.03))

-- chui lib doesn't have a rich input field, only the label widget
-- we expand the lable with basic letter entry and backspace letter removal
-- minimal text interactions, edit cursor fixed to the end

local textbox_panel = chui.panel()
textbox_panel.pose:set(
  mat4()
    :target(vec3(0, 2, -2), vec3(0, 2, 0))
    :scale(0.6))
local textbox = textbox_panel:label{ span=4 } -- centered text

textbox.textinput = function(self, char)
  self.text = self.text .. char
end

textbox.keypressed = function(self, key)
  if key == 'backspace' then
    self.text = self.text:sub(1, math.max(0, #self.text - 1))
  end
end

textbox_panel:layout()

lovr.graphics.setBackgroundColor(1,1,1)

function lovr.textinput(char)
  textbox:textinput(char)
end


function lovr.keypressed(key)
  textbox:keypressed(key)
end


function lovr.update(dt)
  keyboard:update(dt) -- allow keyboard panel to process interactions
end


function lovr.draw(pass)
  chui.draw(pass) -- draw all collected panels
  chui.drawPointers(pass)
end
