-- vqwerty: a panel with virtual keyboard; injects keys into lovr event queue
local chui = require'chui'

local panel = chui.panel()

-- keyboard layout definition
-- single-press special keys are in <>, long-hold special keys are in []
local layout_text_str = [[
<escape> <f1> <f2> <f3> <f4> <f5> <f6> <f7> <f8> <f9> <f10> <f11> <f12>
` 1 2 3 4 5 6 7 8 9 0 - = <backspace>
<tab> q w e r t y u i o p [ ] \
[capslock] a s d f g h j k l ; ' <enter>
[lshift] z x c v b n m , . / [rshift]
[lctrl] [lalt] space [ralt] [rctrl]
]]
local layout_shift_str = [[
<escape> <f1> <f2> <f3> <f4> <f5> <f6> <f7> <f8> <f9> <f10> <f11> <f12>
~ ! @ # $ % ^ & * ( ) _ + <backspace>
<tab> Q W E R T Y U I O P < } |
[capslock] A S D F G H J K L : " <enter>
[lshift] Z X C V B N M < > ? [rshift]
[lctrl] [lalt] space [ralt] [rctrl]
]]


local function splitLayout(str)
  local tbl = {}
  local row = 1
  local col
  for row_str in str:gmatch('[^\r\n]+') do
    col = 1
    for key in row_str:gmatch('%S+') do
      tbl[row] = tbl[row] or {}
      tbl[row][col] = key
      col = col + 1
    end
    row = row + 1
  end
  return tbl
end


local layout_text = splitLayout(layout_text_str)
local layout_shift = splitLayout(layout_shift_str)

local modifiers = {
  ctrl = false, shift = false, alt = false, capslock = false
}

local function textinputCB(self)
  local text = self.data.text
  if modifiers.shift then
    text = self.data.shift
  elseif modifiers.capslock then
    text = text:upper()
  end
  lovr.event.push('textinput', text)
  lovr.event.push('keypressed', self.text)
  lovr.event.push('keyreleased', self.text)
end


local function keypressCB(self)
  lovr.event.push('keypressed', self.text)
  lovr.event.push('keyreleased', self.text)
end


local function toggleCB(self, state)
  -- remove l/r prefix of alt, shift, ctrl
  local modifier = self.text == 'capslock' and 'capslock' or self.text:sub(2, #self.text)
  modifiers[modifier] = state
  if state then
    lovr.event.push('keypressed', self.text)
  else
    lovr.event.push('keyreleased', self.text)
  end
  if modifier == 'shift' then -- update keyboard to alternative caps
    for _, widget in ipairs(panel.widgets) do
      widget.text = state and widget.data.shift or widget.data.text
    end
  end
end


-- roll out the keyboard keys from the layout definition
for row = 1, #layout_text do
  for col = 1, #layout_text[row] do
    local text = layout_text[row][col]
    local shift = layout_shift[row][col]
    local btn
    if text:find('<%S+>') then -- special key like <esc>, send short press
      btn = panel:button{ text=text:sub(2, #text - 1), span=1.2, callback=keypressCB }
      shift = shift:sub(2, #text - 1)
    elseif text:find('%[%S+%]') then -- modifier keys like <lctrl>, toggle status
      btn = panel:toggle{ text=text:sub(2, #text - 1), span=2, callback=toggleCB }
      shift = shift:sub(2, #text - 1)
    elseif text == 'space' then -- space is a placeholder for ' '
      btn = panel:button{ text=' ', span=9, callback=textinputCB, thickness=0.2 }
      shift = ' '
    else -- normal letter-inserting button
      btn = panel:button{ text=text, span=1, callback=textinputCB }
    end
    -- the btn.data is unused in chui lib, we're free to use it for virutal keyboard
    btn.data = {text = btn.text, shift = shift}
  end
  if row < #layout_text then
    panel:row()
  end
end

panel:asGrid()

return panel
