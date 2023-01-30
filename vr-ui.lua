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
m.spacer.defaults = {}
table.insert(m.widget_types, 'spacer')

function m.spacer:init()
end


function m.spacer:draw(pass, pose)
end


-- LABEL ----------------------------------------------------------------------
m.label = {}
m.label.defaults = {text = ''}
table.insert(m.widget_types, 'label')

function m.label:init(options)
  self.text = options.text
end


function m.label:draw(pass, pose)
  --pass:setColor(palette.background)
  --pass:roundrect(0,0,0.2, 1, 1, 0.2, 0, 0,1,0, 0.2)
  pass:setColor(palette.text)
  pass:text(self.text, 0, 0, 0.2,  0.2)
end


-- BUTTON ---------------------------------------------------------------------
m.button = {}
m.button.defaults = {text = '', callback = nil}
table.insert(m.widget_types, 'button')

function m.button:init(options)
  self.text = options.text
  self.callback = options.callback
  self.hovered = false
end


function m.button:draw(pass)
  pass:setColor(
    (self.hovered and palette.hover_background) or
    palette.background)
  pass:roundrect(0, 0, -0.1,  self.span, 1, 0.2,  0, 0,1,0, 0.2)
  pass:setColor(palette.text)
  pass:text(self.text, 0, 0, 0.2,  0.2)
end


function m.button:handle(pointer, is_hovered, is_down, was_pressed, was_released)
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
m.toggle.defaults = {text = '', callback = nil}
table.insert(m.widget_types, 'toggle')

function m.toggle:init(options)
  self.text = options.text
  self.callback = options.callback
  self.state = false
  self.hovered = false
end


function m.toggle:draw(pass)
  pass:setColor(
    (self.hovered and palette.hover_background) or
    (self.state and palette.active) or
    palette.background)
  pass:roundrect(0, 0, -0.1,  self.span, 1, 0.2,  0, 0,1,0, 0.2)
  pass:setColor(palette.text)
  pass:text(self.text, 0, 0, 0.2,  0.2)
end


function m.toggle:handle(pointer, is_hovered, is_down, was_pressed, was_released)
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


function m.toggle:set(state)
  self.state = state and true or false
end


-- PROGRESS ---------------------------------------------------------------------
m.progress = {}
m.progress.defaults = {text = '', value = 0}
table.insert(m.widget_types, 'progress')

function m.progress:init(options)
  self.text = options.text
  self:set(options.value)
  self.margin = 0.15
end


function m.progress:draw(pass)
  pass:setColor(palette.text)
  pass:text(self.text, 0, 0, 0.1,  0.2)
  local aw = self.span - 2 * self.margin -- available width
  local w = self.value * aw
  pass:box(0, -0.3, 0.02,  aw * 0.95, 0.08, 0.04)
  pass:setColor(palette.active)
  pass:roundrect(-aw / 2 + w / 2, -0.3, 0.03,  w, 0.16, 0.06,  0, 0,1,0, 0.05)
end


function m.progress:set(value)
  self.value = math.max(0, math.min(1, value))
end


-- SLIDER ---------------------------------------------------------------------
m.slider = {}
m.slider.__index = m.slider
m.slider.defaults = {text = '', min = 0, max = 1, value = 0, step = nil, callback = nil}
table.insert(m.widget_types, 'slider')

local function roundBy(value, step)
    local quant, frac = math.modf(value / step)
    return step * (quant + (frac > 0.5 and 1 or 0))
end


function m.slider:init(options)
  self.text = options.text
  self.min = options.min
  self.max = options.max
  self.callback = options.callback
  self.step = options.step
  self.format = '%s %.2f'
  if self.step then
    local digits = math.max(0, math.ceil(-math.log(self.step, 10)))
    self.format = string.format('%%s %%.%df', digits)
  end
  self:set(options.value)
  self.margin = 0.15
end


function m.slider:draw(pass)
  pass:setColor(
    (self.hovered and palette.hover_background) or
    palette.background)
  pass:roundrect(0, 0, -0.2,  self.span, 1, 0.2,  0, 0,1,0, 0.1)
  pass:setColor(palette.text)
  pass:text(string.format(self.format, self.text, self.value), 0, 0, 0.1,  0.2)
  local aw = self.span - 2 * self.margin -- available width
  local w = (self.value - self.min) / (self.max - self.min) * aw
  pass:box(0, -0.3, 0.02,   aw * 0.95, 0.08, 0.04)
  pass:setColor(palette.active)
  pass:roundrect((w - aw) / 2, -0.3, 0.03,  w, 0.16, 0.06,  0, 0,1,0, 0.05)
end


function m.slider:handle(pointer, is_hovered, is_down, was_pressed, was_released)
  if is_hovered and not self.hovered then
    -- on hover action (play sound)
  end
  self.hovered = is_hovered
  if is_down and is_hovered then
    local pointer_pos = vec3(pointer)
    -- on click action
    local aw = self.span - 2 * self.margin -- available width
    local value = self.min + (aw / 2 + pointer_pos.x) / aw * (self.max - self.min)
    self:set(value)
  end
  if was_released and is_hovered and self.callback then
    self.callback(self, self.value)
  end
end


function m.slider:get()
  return self.value
end


function m.slider:set(value)
  if self.step then
    value = roundBy(value, self.step)
  end
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
  self.width = 0
  self.height = 0
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
    pointer_pose = mat4(self.pose):invert():mul(pointer_data[1])
    for _, widget in ipairs(self.widgets) do
      if widget.handle then
        local widget_pointer_pose = mat4(widget.pose):invert():mul(pointer_pose)
        local pos = vec3(widget_pointer_pose)
        local is_hovered = pos.z < 1 and pos.z > 0 and
                           pos.y > -0.5 and pos.y < 0.5 and
                           pos.x > -widget.span / 2 and pos.x < widget.span / 2
        widget:handle(widget_pointer_pose, is_hovered, select(2, unpack(pointer_data)))
      end
    end
  end
end


function panel:asGrid()
  self.width = 0
  self.height = 0
  local spreading = 1.1
  for r, row in ipairs(self.rows) do
    local width = 0
    for c, widget in ipairs(row) do
      width = width + widget.span
    end
    local col = 0
    for c, widget in ipairs(row) do
      local x = spreading * (- width / 2 + col + widget.span / 2)
      local y = spreading * (-r + #self.rows / 2)
      widget.pose = lovr.math.newMat4(x, y, 0)
      col = col + widget.span
      self.width = math.max(self.width, col)
    end
    if #row then
      self.height = self.height + 1
    end
  end
  self.width = self.width + (self.width - 1)    * (spreading - 1)
  self.height = self.height + (self.height - 1) * (spreading - 1)
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
  local widget_table = m[widget_name]
  widget_table.__index = widget_table
  panel[widget_name] = function(self, options)
    local widget_table = m[widget_name]
    widget_table.defaults.__index = widget_table.defaults
    setmetatable(options, widget_table.defaults)
    local widget = setmetatable({}, widget_table)
    widget:init(options)
    widget.span = options.span or 1
    table.insert(self.widgets, widget)
    table.insert(self.rows[#self.rows], widget)
    return widget
  end
end

return m
