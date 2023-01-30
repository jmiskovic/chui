local palette = require'palette-illustrative'
palette.background = palette[1]
palette.hover_background = palette[3]
palette.text = palette[2]
palette.active = palette[4]

local m = {}

m.font = lovr.graphics.newFont('ubuntu-mono.ttf', 50)

m.widget_types = {}

--TODO:
-- spacer, label
-- push button, toggle button
-- textbox
-- slider, progress bar
-- multiple choices

-- SPACER ---------------------------------------------------------------------
m.spacer = {}
m.spacer.__index = m.spacer
table.insert(m.widget_types, 'spacer')

function m.spacer.init()
  local w = setmetatable({}, m.spacer)
  return w
end


function m.spacer:draw(pass, pose)
end


-- LABEL ----------------------------------------------------------------------
m.label = {}
m.label.__index = m.label
table.insert(m.widget_types, 'label')

function m.label.init(text)
  local w = setmetatable({}, m.label)
  w.text = text
  return w
end


function m.label:draw(pass, pose)
  --pass:setColor(palette.background)
  --pass:roundrect(0,0,0.2, 1, 1, 0.2, 0, 0,1,0, 0.2)
  pass:setColor(palette.text)
  pass:text(self.text, 0, 0, 0.2,  0.2)
end


-- BUTTON ---------------------------------------------------------------------
m.button = {}
m.button.__index = m.button
table.insert(m.widget_types, 'button')

function m.button.init(text, callback)
  local w = setmetatable({}, m.button)
  w.text = text
  w.callback = callback
  w.hovered = false
  return w
end


function m.button:draw(pass)
  pass:setColor(
    (self.hovered and palette.hover_background) or
    palette.background)
  pass:roundrect(0, 0, -0.1,  1, 1, 0.2,  0, 0,1,0, 0.2)
  pass:setColor(palette.text)
  pass:text(self.text, 0, 0, 0.2,  0.2)
end


function m.button:handle(pointer, is_down, was_pressed, was_released)
  local is_hovered = vec3(pointer):length() < .6
  if is_hovered and not self.hovered then
    -- on hover action (play sound)
  end
  self.hovered = is_hovered
  if was_pressed and is_hovered then
    -- on click action
    if self.callback then
      self.callback(self)
    end
  end
end

-- TOGGLE ---------------------------------------------------------------------
m.toggle = {}
m.toggle.__index = m.toggle
table.insert(m.widget_types, 'toggle')

function m.toggle.init(text, callback)
  local w = setmetatable({}, m.toggle)
  w.text = text
  w.callback = callback
  m.state = false
  w.hovered = false
  return w
end


function m.toggle:draw(pass)
  pass:setColor(
    (self.hovered and palette.hover_background) or
    (self.state and palette.active) or
    palette.background)
  pass:roundrect(0, 0, -0.1,  1, 1, 0.2,  0, 0,1,0, 0.2)
  pass:setColor(palette.text)
  pass:text(self.text, 0, 0, 0.2,  0.2)
end


function m.toggle:handle(pointer, is_down, was_pressed, was_released)
  local is_hovered = vec3(pointer):length() < .6
  if is_hovered and not self.hovered then
    -- on hover action (play sound)
  end
  self.hovered = is_hovered
  if was_pressed and is_hovered then
    -- on click action
    self.state = not self.state
    if self.callback then
      self.callback(self, self.state)
    end
  end
end


-- PROGRESS ---------------------------------------------------------------------
m.progress = {}
m.progress.__index = m.progress
table.insert(m.widget_types, 'progress')

function m.progress.init(text)
  local w = setmetatable({}, m.progress)
  w.text = text
  m.value = 0
  return w
end


function m.progress:draw(pass)
  pass:setColor(palette.background)
  pass:roundrect(0, 0, -0.2,  1, 1, 0.2,  0, 0,1,0, 0.1)
  pass:setColor(palette.text)
  pass:text(self.text, 0, 0, 0.1,  0.2)
  local pw = 0.7
  local w = self.value * pw
  pass:roundrect(0, -0.3, 0.02,   pw * 0.9, 0.08, 0.04,  0, 0,1,0, 0.01)
  pass:setColor(palette.active)
  pass:roundrect(-pw / 2 + w / 2, -0.3, 0.03,  w, 0.16, 0.06,  0, 0,1,0, 0.05)
end


function m.progress:set(value)
  self.value = math.max(0, math.min(1, value))
end

-- SLIDER ---------------------------------------------------------------------
m.slider = {}
m.slider.__index = m.slider
table.insert(m.widget_types, 'slider')

function m.slider.init(text, min, max, value)
  min = min or 0
  max = max or 1
  value = value or min
  local w = setmetatable({}, m.slider)
  w.text = text
  w.min = math.min(min, max)
  w.max = math.max(min, max)
  w.value = value
  return w
end


function m.slider:draw(pass)
  pass:setColor(
    (self.hovered and palette.hover_background) or
    palette.background)
  pass:roundrect(0, 0, -0.2,  1, 1, 0.2,  0, 0,1,0, 0.1)
  pass:setColor(palette.text)
  local text = string.format('%s %1.2f', self.text, self.value)
  pass:text(text, 0, 0, 0.1,  0.2)
  local pw = 0.7
  local w = (self.value - self.min) / (self.max - self.min) * pw
  pass:roundrect(0, -0.3, 0.02,   pw * 0.9, 0.08, 0.04,  0, 0,1,0, 0.01)
  pass:setColor(palette.active)
  pass:roundrect(-pw / 2 + w / 2, -0.3, 0.03,  w, 0.16, 0.06,  0, 0,1,0, 0.05)
end


function m.slider:handle(pointer, is_down, was_pressed, was_released)
  local pointer_pos = vec3(pointer)
  local is_hovered = pointer_pos:length() < .6
  if is_hovered and not self.hovered then
    -- on hover action (play sound)
  end
  self.hovered = is_hovered
  if is_down and is_hovered then
    -- on click action
    self.value = self.min + (0.7 / 2 + pointer_pos.x  / 0.7) * (self.max - self.min)
    self.value = math.max(self.min, math.min(self.max, self.value))
  end
end


function m.slider:get()
  return self.value
end

function m.slider:set(value)
  self.value = math.max(self.min, math.min(self.max, value))
end

-- PANEL ----------------------------------------------------------------------
local panel = {}
panel.__index = panel

function m.panel(pose)
  local self = setmetatable({}, panel)
  self.pose = lovr.math.newMat4(pose)
  self.pose:rotate(math.pi, 0,1,0)
  self.widgets = {}
  self.rows = {{}}
  return self
end


function panel:row()
  table.insert(self.rows, {})
end


function panel:update(dt)
  local pointers = {}
  for _, hand in ipairs(lovr.headset.getHands()) do
    table.insert(pointers, {
      mat4(lovr.headset.getPose(hand .. '/point')),
      lovr.headset.isDown(hand, 'trigger'),
      lovr.headset.wasPressed(hand, 'trigger'),
      lovr.headset.wasReleased(hand, 'trigger')
    })
  end
  -- TODO: aabb check
  for _, pointer_data in ipairs(pointers) do
    pointer = mat4(self.pose):invert():mul(pointer_data[1])
    for _, widget in ipairs(self.widgets) do
      if widget.handle then
        local wpointer = mat4(widget.pose):invert():mul(pointer)
        widget:handle(wpointer, select(2, unpack(pointer_data)))
      end
    end
  end
end


function panel:asGrid()
  local spreading = 1.1
  for r, row in ipairs(self.rows) do
    for c, widget in ipairs(row) do
      local x = spreading * ( c - #row / 2)
      local y = spreading * (-r + #self.rows / 2)
      widget.pose = lovr.math.newMat4(x, y, 0)
    end
  end
end


function panel:draw(pass)
  pass:push()
  pass:transform(self.pose)
  pass:setFont(m.font)
  for i, w in ipairs(self.widgets) do
    pass:push()
    pass:transform(w.pose)
    w:draw(pass)
    pass:pop()
  end
  pass:pop()
end


-- constructors
for i, widget_name in ipairs(m.widget_types) do
  panel[widget_name] = function(self, ...)
    local widget = m[widget_name].init(...)
    table.insert(self.widgets, widget)
    table.insert(self.rows[#self.rows], widget)
    return widget
  end
end

return m
