local m = {}

m.font = lovr.graphics.newFont('ubuntu-mono.ttf', 50)
m.segments = 7
m.panels = {}


m.palettes = {
  index = 1,
  { -- https://lospec.com/palette-list/poison
    background = 0x2a2a2b,
    inactive = 0x454a4d,
    hover_background = 0x2f7571,
    active = 0x5a9470,
    text = 0x81b071,
  },
}

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


function m.spacer:update(dt, pointer, handness)
end


-- LABEL ----------------------------------------------------------------------
m.label = {}
m.label.defaults = {text = ''}
table.insert(m.widget_types, 'label')

function m.label:init(options)
  self.text = options.text
end


function m.label:draw(pass, pose)
  pass:setColor(self.panel.palette.text)
  pass:text(self.text, 0, 0, 0.2,  0.2)
end


function m.label:update(dt, pointer, handness)
end


-- BUTTON ---------------------------------------------------------------------
m.button = {}
m.button.defaults = {text = '', thickness = 0.2, callback = nil}
table.insert(m.widget_types, 'button')

function m.button:init(options)
  self.interactive = true
  self.hovered = false
  self.text = options.text
  self.callback = options.callback
  self.thickness = options.thickness
  self.depth = self.thickness
end


function m.button:draw(pass)
  pass:setColor(self.panel.palette.inactive)
  pass:roundrect(0, 0, -0.03,   self.span + 0.1, 1.1, 0.05,  0, 0,1,0, 0.4, m.segments)
  pass:setColor(
    (self.depth < self.thickness / 2 and self.panel.palette.active) or
    (self.hovered and self.panel.palette.hover_background) or
    self.panel.palette.background)
  pass:roundrect(0, 0, self.depth / 2,  self.span, 1, self.depth,  0, 0,1,0, 0.4, m.segments)
  pass:setColor(self.panel.palette.text)
  pass:text(self.text, 0, 0, self.depth + 0.02,  0.2)
end


function m.button:update(dt, pointer, handness)
  local depth_next = self.depth
  if handness then -- pressing the button inward
    depth_next = math.min(self.thickness, math.max(0, pointer.z))
  end
  if handness and self.hovered and -- button passed the threshold
      depth_next < self.thickness / 2 and
      self.depth > self.thickness / 2 then
    lovr.headset.vibrate(handness, 0.2, 0.1)
    if self.callback then
      self.callback(self)
    end
  end
  self.depth = depth_next
  self.hovered = handness and true or false
  if not handness then -- rebound
    self.depth = math.min(self.thickness, self.depth + 4 * dt)
  end
end


-- TOGGLE ---------------------------------------------------------------------
m.toggle = {}
m.toggle.defaults = {text = '', thickness = 0.2, state = false, callback = nil}
table.insert(m.widget_types, 'toggle')

function m.toggle:init(options)
  self.interactive = true
  self.state = options.state
  self.hovered = false
  self.text = options.text
  self.callback = options.callback
  self.thickness = options.thickness
  self.depth = self.thickness
end


function m.toggle:draw(pass)
  pass:setColor(self.panel.palette.inactive)
  pass:roundrect(0, 0, -0.03,   self.span + 0.1, 1.1, 0.05,  0, 0,1,0, 0.4, m.segments)
  pass:setColor(
    (self.hovered and self.panel.palette.hover_background) or
    (self.state and self.panel.palette.active) or
    self.panel.palette.background)
  pass:roundrect(0, 0, self.depth / 2,  self.span, 1, self.depth,  0, 0,1,0, 0.4, m.segments)
  pass:setColor(self.panel.palette.text)
  pass:text(self.text, 0, 0, self.depth + 0.02,  0.2)
end


function m.toggle:update(dt, pointer, handness)
  local depth_next = self.depth
  if handness then -- pressing the toggle inward
    depth_next = math.min(self.thickness, math.max(0, pointer.z))
  end
  if handness and self.hovered and -- toggle button passed the threshold
      depth_next < self.thickness / 2 and
      self.depth > self.thickness / 2 then
    lovr.headset.vibrate(handness, 0.2, 0.1)
    self.state = not self.state
    if self.callback then
      self.callback(self, self.state)
    end
  end
  self.depth = depth_next
  self.hovered = handness and true or false
  if not handness then -- rebound
    self.depth = math.min(self.thickness, self.depth + 4 * dt)
  end
end


function m.toggle:get()
  return self.state
end


function m.toggle:set(state)
  self.state = state and true or false
end


-- GLOW -------------------------------------------------------------------------
m.glow = {}
m.glow.defaults = {text = '', thickness = 0.1, state = false}
table.insert(m.widget_types, 'glow')

function m.glow:init(options)
  self.state = options.state
  self.text = options.text
  self.thickness = options.thickness
end


function m.glow:draw(pass)
  pass:setColor(self.panel.palette.hover_background)
  pass:cylinder(0, 0, -0.03,  0.6, 0.05,  0, 0,1,0, true, nil, nil, m.segments * 6)
  pass:setColor(
    (self.state and self.panel.palette.active) or
    self.panel.palette.inactive)
  pass:cylinder(0, 0, self.thickness / 2,  0.5, self.thickness,  0, 0,1,0, true, nil, nil, m.segments * 6)
  pass:setColor(self.panel.palette.text)
  pass:text(self.text, 0, 0, self.thickness + 0.02,  0.2)
end


function m.glow:update(dt, pointer, handness)
end


function m.glow:get()
  return self.state
end


function m.glow:set(state)
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
  pass:setColor(self.panel.palette.text)
  pass:text(self.text, 0, 0, 0.1,  0.2)
  local aw = self.span - 2 * self.margin -- available width
  local w = self.value * aw
  pass:box(0, -0.3, 0.02,  aw * 0.95, 0.08, 0.04)
  pass:setColor(self.panel.palette.active)
  pass:roundrect(-aw / 2 + w / 2, -0.3, 0.03,  w, 0.16, 0.06,  0, 0,1,0, 0.05, m.segments)
end


function m.progress:set(value)
  self.value = math.max(0, math.min(1, value))
end


function m.progress:update(dt, pointer, handness)
end


-- SLIDER ---------------------------------------------------------------------
m.slider = {}
m.slider.__index = m.slider
m.slider.defaults = {text = '', min = 0, max = 1, value = 0, step = nil, thickness = 0.2, callback = nil}
table.insert(m.widget_types, 'slider')

local function roundBy(value, step)
    local quant, frac = math.modf(value / step)
    return step * (quant + (frac > 0.5 and 1 or 0))
end


function m.slider:init(options)
  self.interactive = true
  self.text = options.text
  self.min = options.min
  self.max = options.max
  self.thickness = options.thickness
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
    (self.altered and self.panel.palette.hover_background) or
    self.panel.palette.background)
  pass:roundrect(0, 0, -0.2,  self.span, 1, 0.2,  0, 0,1,0, 0.1, m.segments)
  pass:setColor(self.panel.palette.text)
  pass:text(string.format(self.format, self.text, self.value), 0, 0.2, 0.1,  0.2)
  local aw = self.span - 2 * self.margin -- available width
  local w = (self.value - self.min) / (self.max - self.min) * aw
  pass:box(0, -0.15, 0.02,   aw * 0.95, 0.08, 0.04)
  pass:setColor(self.panel.palette.active)
  --pass:roundrect((w - aw) / 2, -0.3, self.thickness / 2,  w, 0.16, self.thickness,  0, 0,1,0, 0.05, m.segments)
  pass:roundrect(-aw/2 + w, -0.15, self.thickness / 2,  0.1, 0.3, self.thickness,  0, 0,1,0, 0.05, m.segments)
end


function m.slider:update(dt, pointer, handness)
  local hovered = handness and true or false
  local altered_next = pointer.z < self.thickness
  if hovered and altered_next then
    local aw = self.span - 2 * self.margin -- available width
    local value = self.min + (aw / 2 + pointer.x) / aw * (self.max - self.min)
    self:set(value)
    lovr.headset.vibrate(handness, 0.2, dt)
  end
  if not altered_next and self.altered and self.callback then
    self.callback(self, self.value)
  end
  self.altered = altered_next
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
  self.palette = m.palettes[m.palettes.index]
  self.visible = true
  table.insert(m.panels, self)
  return self
end


function panel:row()
  table.insert(self.rows, {})
end


function panel:asGrid()
  self.width = 0
  self.height = 0
  local spreading = 1.2
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


function panel:update(dt)
  if not self.visible then return end
  local pointers = {}
  for _, hand in ipairs(lovr.headset.getHands()) do
    local skeleton = lovr.headset.getSkeleton(hand)
    if skeleton then
      table.insert(pointers, {hand, vec3(unpack(skeleton[11]))})
    else
      table.insert(pointers, {hand, vec3(lovr.headset.getPosition(hand .. '/point'))})
    end
  end
  -- TODO: aabb check
  local panel_pose_inv = mat4(self.pose):invert()
  for _, widget in ipairs(self.widgets) do
    local closest_pos
    local closest_hand
    if widget.interactive then
      closest_pos = vec3(math.huge)
      for _, pointer in ipairs(pointers) do -- process each pointer
        local pos_panel = panel_pose_inv:mul(vec3(pointer[2]))
        local pos = mat4(widget.pose):invert():mul(pos_panel)
        local is_hovered = pos.z < 1 and pos.z > -4 and
                           pos.y > -0.5 and pos.y < 0.5 and
                           pos.x > -widget.span / 2 and pos.x < widget.span / 2
        if is_hovered and math.abs(pos.z) < math.abs(closest_pos.z) then
          closest_pos:set(pos)
          closest_hand = pointer[1]
        end
      end
    end
    widget:update(dt, closest_pos, closest_hand)
  end
end


function panel:draw(pass)
  if not self.visible then return end
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


function panel:setVisible(is_visible)
  if self.visible and not is_visible then
    -- complete any ongoing interactions (hovered pointers)
    local dt = lovr.timer.getDelta()
    for _, widget in ipairs(self.widgets) do
      widget:update(dt, vec3(math.huge), nil)
    end
  end
  self.visible = is_visible
end


-- constructors
for i, widget_name in ipairs(m.widget_types) do
  local widget_table = m[widget_name]
  widget_table.__index = widget_table
  panel[widget_name] = function(self, options)
    options = options or {}
    local widget_table = m[widget_name]
    setmetatable(options, widget_table.defaults)
    widget_table.defaults.__index = widget_table.defaults
    local widget = setmetatable({}, widget_table)
    widget:init(options)
    widget.span = options.span or 1
    widget.panel = self
    table.insert(self.widgets, widget)
    table.insert(self.rows[#self.rows], widget)
    return widget
  end
end


function m.drawPointers(pass)
  for i, hand in ipairs(lovr.headset.getHands()) do
    local skeleton = lovr.headset.getSkeleton(hand)
    if skeleton then
      pass:sphere(vec3(unpack(skeleton[11])), 0.02)
    else
      pass:sphere(vec3(lovr.headset.getPosition(hand..'/point')), 0.02)
    end
  end
end


function m.update(dt)
  for i, panel in ipairs(m.panels) do
      panel:update(dt)
  end
end


function m.draw(pass)
  for i, panel in ipairs(m.panels) do
      panel:draw(pass)
  end
end

return m
