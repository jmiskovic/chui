-- chui: a set of VR UI push-to-operate components (no laser pointers)

local m = {}

function vibrate(device, strength, duration, frequency)
  if device ~= 'mouse' and lovr.headset then
    lovr.headset.vibrate(device, strength, duration, frequency)
  end
end

local Q = 0.025 -- quant; all paddings and margins are its multiples
local S = 0.05  -- size of widget actuators
local text_scale = 0.3
local button_roundness = 0.3
local slider_roundness = 0.1

m.palettes = {
  active = 1,
  -- some UI palettes collected here
  --widget body     color for OFF        color for ON       highlight color   them letters     back-panel color
  { cap = 0x46425e, inactive = 0xb28e7c, active = 0xdd9e43, hover = 0x72677b, text = 0xddc2bd, panel = 0x81828e },
  { cap = 0x291d22, inactive = 0x4e313a, active = 0xf9b18e, hover = 0x9d5550, text = 0xfae8bc, panel = 0x374549 },
  { cap = 0x3b3149, inactive = 0x5c6181, active = 0xd47563, hover = 0xecc197, text = 0xecece0, panel = 0x191822 },
  { cap = 0x2a2a2b, inactive = 0x454a4d, active = 0x5a9470, hover = 0x2f7571, text = 0x81b071, panel = 0x202020 },
  { cap = 0xffeecc, inactive = 0x00b9be, active = 0xff6973, hover = 0xffb0a3, text = 0x15788c, panel = 0x264452 },
  { cap = 0x413a42, inactive = 0x1f1f29, active = 0xe68056, hover = 0x596070, text = 0xeaf0d8, panel = 0x16181b },
  { cap = 0x392b35, inactive = 0x7a9c96, active = 0xffab53, hover = 0x486b7f, text = 0xbb474f, panel = 0x5e747e },
  { cap = 0x100f13, inactive = 0x3a213a, active = 0x914e3c, hover = 0x693540, text = 0xc7955c, panel = 0x1a0d1e },
  { cap = 0x212124, inactive = 0x464c54, active = 0x76add8, hover = 0x5b8087, text = 0xa3e7f0, panel = 0x2b3a49 },
  { cap = 0x2e3b43, inactive = 0x619094, active = 0xdcfdcb, hover = 0x5a9e89, text = 0x5fa6ac, panel = 0x9ac0ba },
}

m.mouse_available = (not lovr.headset) or (lovr.headset.getName() == 'Simulator')
m.segments = 7  -- amount of geometry for roundrects and cylinders

m.panels = {}
m.widget_types = {}

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
m.label.defaults = { text = '', text_scale = 1 }
table.insert(m.widget_types, 'label')

function m.label:init(options)
  self.text = options.text
  self.text_scale = options.text_scale
end


function m.label:draw(pass, pose)
  -- text
  pass:setColor(self.panel.palette.text)
  pass:text(self.text, 0, 0, Q,  0.2 * self.text_scale)
end


function m.label:update(dt, pointer, handness)
end


-- BUTTON ---------------------------------------------------------------------
m.button = {}
m.button.defaults = { text = '', thickness = 0.3, callback = nil }
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
  -- body
  pass:setColor(
    (self.depth < self.thickness / 2 and self.panel.palette.active) or
    (self.hovered and self.panel.palette.hover) or
    self.panel.palette.cap)
  pass:roundrect(0, 0, self.depth / 2,
    self.span - 2 * Q, 1 - 2 * Q, self.depth - Q,
    0, 0,1,0,
    button_roundness, m.segments)
  -- frame
  pass:setColor(self.panel.palette.inactive)
  pass:roundrect(0, 0, Q / 2,
    self.span, 1, Q,
    0, 0,1,0,
    button_roundness, m.segments)
  -- text
  pass:setColor(self.panel.palette.text)
  pass:text(self.text, 0, 0, self.depth + Q,  text_scale)
end


function m.button:update(dt, pointer, handness)
  local depth_next = self.depth
  if handness then -- pressing the button inward
    depth_next = math.min(self.thickness, math.max(2 * Q, pointer.z))
  end
  if handness and self.hovered and -- button passed the threshold
      depth_next < self.thickness / 2 and
      self.depth > self.thickness / 2 then
    vibrate(handness, 0.2, 0.1)
    if self.callback then
      self.callback(self)
    end
  end
  self.depth = depth_next
  self.hovered = handness and true or false
  if not handness then -- slowly rebound to above-hover depth when pointer leaves the widget
    self.depth = math.min(self.thickness, self.depth + 4 * dt)
  end
end


function m.button:get()
  return self.depth < self.thickness / 2
end


-- TOGGLE ---------------------------------------------------------------------
m.toggle = {}
m.toggle.defaults = { text = '', thickness = 0.3, state = false, callback = nil }
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
  -- body
  pass:setColor(
    (self.state and self.panel.palette.active) or
    (self.hovered and self.panel.palette.hover) or
    self.panel.palette.cap)
  pass:roundrect(0, 0, self.depth / 2,
    self.span - 2 * Q, 1 - 2 * Q, self.depth - Q,
    0, 0,1,0,
    button_roundness * 0.75, m.segments)
  -- frame
  pass:setColor(self.panel.palette.inactive)
  pass:roundrect(0, 0, Q / 2,
    self.span, 1, Q,
    0, 0,1,0,
    button_roundness * 0.75, m.segments)
  -- text
  pass:setColor(self.panel.palette.text)
  pass:text(self.text, 0, 0, self.depth + Q,  text_scale)
end


function m.toggle:update(dt, pointer, handness)
  local depth_next = self.depth
  if handness then -- pressing the toggle inward
    depth_next = math.min(self.thickness, math.max(2 * Q, pointer.z))
  end
  if handness and self.hovered and -- toggle button passed the threshold
      depth_next < self.thickness / 2 and
      self.depth > self.thickness / 2 then
    vibrate(handness, 0.2, 0.1)
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
m.glow.defaults = { text = '', thickness = 0.1, state = false }
table.insert(m.widget_types, 'glow')

function m.glow:init(options)
  self.state = options.state
  self.text = options.text
  self.thickness = options.thickness
end


function m.glow:draw(pass)
  -- body
  pass:setColor(
    (self.state and self.panel.palette.active) or
    self.panel.palette.inactive)
  pass:cylinder(0, 0, self.thickness / 2,  0.5, self.thickness,  0, 0,1,0, true, nil, nil, m.segments * 6)
  -- frame
  pass:setColor(self.panel.palette.inactive)
  pass:cylinder(0, 0, Q / 2,
    0.5, Q,
    0, 0,1,0, true, nil, nil, m.segments * 6)
  -- text
  pass:setColor(self.panel.palette.text)
  pass:text(self.text, 0, 0, self.thickness + Q,  text_scale)
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
m.progress.defaults = { text = '', value = 0 }
table.insert(m.widget_types, 'progress')

function m.progress:init(options)
  self.text = options.text
  self:set(options.value)
end


function m.progress:draw(pass)
  -- value as horizontal bar
  local y = -0.15
  local aw = self.span - S - 2 * Q -- available width
  local w = self.value * aw
  pass:setColor(self.panel.palette.text)
  pass:box(0, y, 2 * Q,  aw - 2 * Q, 2 * S, S / 2)
  pass:setColor(self.panel.palette.active)
  pass:roundrect(-aw / 2 + w / 2, y, 4 * Q,
    w, 4 * S, 2 * S,
    0, 0,1,0,
    2 * Q, m.segments)
  -- text
  local y = 0.2
  pass:setColor(self.panel.palette.text)
  pass:text(self.text, 0, y, 2 * Q,  text_scale)
end


function m.progress:get()
  return self.value
end


function m.progress:set(value)
  self.value = math.max(0, math.min(1, value))
end


function m.progress:update(dt, pointer, handness)
end


-- SLIDER ---------------------------------------------------------------------
m.slider = {}
m.slider.__index = m.slider
m.slider.defaults = { text = '',  format = '%s %.2f',
  min = 0, max = 1, value = 0, step = nil, thickness = 0.15, callback = nil }
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
  self.format = options.format
  if not options.format and self.step then
    local digits = math.max(0, math.ceil(-math.log(self.step, 10)))
    self.format = string.format('%%s %%.%df', digits)
  end
  self:set(options.value)
end


function m.slider:draw(pass)
  -- value knob
  local y = -0.15
  local aw = self.span - S - 2 * Q -- available width
  local pos = (self.value - self.min) / (self.max - self.min) * aw
  pass:setColor(self.panel.palette.text)
  pass:box(0, y, 2 * Q,  aw, 2 * S, S / 2)
  pass:setColor(self.panel.palette.active)
  pass:roundrect(-aw / 2 + pos, y, 2 * Q + self.thickness / 2,
    2 * S, 6 * S, self.thickness,
    0, 0,1,0,
    S, m.segments)
  -- frame
  pass:setColor(
    (self.altered and self.panel.palette.hover) or
    self.panel.palette.cap)
  pass:roundrect(0, 0, Q / 2,
    self.span, 1, Q,
    0, 0,1,0,
    slider_roundness, m.segments)
  -- text
  local y = 0.2
  pass:setColor(self.panel.palette.text)
  pass:text(string.format(self.format, self.text, self.value),
    0, y, 2 * Q,  text_scale)
end


function m.slider:update(dt, pointer, handness)
  local hovered = handness and true or false
  local altered_next = pointer.z < self.thickness
  if hovered and altered_next then
    local aw = self.span - 16 * Q -- available width
    local value = self.min + (aw / 2 + pointer.x) / aw * (self.max - self.min)
    self:set(value)
    vibrate(handness, 0.2, dt)
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

local panel_defaults = {
  frame = 'backpanel',
  palette  = { cap = 0x111111, inactive = 0x444444, active = 0x888888, hover = 0xaaaaaa, text = 0xdddddd, panel = 0xffffff },
}

function m.panel(options)
  options = options or {}
  local self = setmetatable({}, panel)
  self.frame = options.frame or panel_defaults.frame
  self.pose = lovr.math.newMat4(options.pose) -- ok if options.pose is nil
  self.world_from_screen = Mat4()
  self.widgets = {}
  self.rows = {{}}
  self.width = 0
  self.height = 0
  self.palette = options.palette or m.palettes[m.palettes.active] or panel_defaults.palette
  self.visible = true
  table.insert(m.panels, self)
  return self
end


function panel:reset()
  self.widgets = {}
  self.rows = {{}}
  self.width = 0
  self.height = 0
end


function panel:row()
  table.insert(self.rows, {})
end


function panel:layout(strategy)
  strategy = strategy or 'vrows'
  assert(strategy == 'vrows')
  local margin = 8 * Q -- margin between rows and widgets in row
  self.width = -math.huge
  self.height = #self.rows + (#self.rows - 1) * margin
  for r, row in ipairs(self.rows) do
    local total_span = 0
    for _, widget in ipairs(row) do
      total_span = total_span + widget.span
    end
    local width = total_span + (#row - 1) * margin
    local x = -width / 2
    for _, widget in ipairs(row) do
      x = x + widget.span / 2
      local y = self.height / 2    -- vertical top of panel
        - (r - 1) * (1 + margin)   -- each row after first one needs 1 + margin
        - 0.5                      -- the center of row is at half its height
      widget.pose = lovr.math.newMat4(x, y, 0)
      x = x + widget.span / 2 + margin
    end
    self.width = math.max(self.width, width)
  end
end


function panel:updateWidgets(dt, pointers)
  if not self.visible then return end
  local z_front, z_back = 1.5, -0.3 -- z boundaries of widget AABB
  local panel_pose_inv = mat4(self.pose):rotate(math.pi, 0,1,0):invert()
  for _, widget in ipairs(self.widgets) do
    local closest_pos
    local closest_hand
    if widget.interactive then
      closest_pos = vec3(math.huge)
      for _, pointer in ipairs(pointers) do -- process each pointer
        local pos = vec3()
        local is_hovered = false
        -- reproject pointer onto panel coordinate system and check widget's AABB
        local pos_panel = panel_pose_inv:mul(vec3(pointer[2]))
        local pos = mat4(widget.pose):invert():mul(pos_panel) -- in panel's coordinate system
        is_hovered = pos.x > -widget.span / 2 and pos.x < widget.span / 2 and
                     pos.y > -0.5 and pos.y < 0.5 and
                     pos.z < z_front and pos.z > z_back
        if is_hovered and math.abs(pos.z) < math.abs(closest_pos.z) then
          closest_pos:set(pos)
          closest_hand = pointer[1]
        end
      end
    end
    widget:update(dt, closest_pos, closest_hand)
  end
end


function panel:getHeadsetPointers(pointers)
  for _, hand in ipairs(lovr.headset.getHands()) do
    local skeleton = lovr.headset.getSkeleton(hand)
    if skeleton then
      table.insert(pointers, {hand, vec3(unpack(skeleton[11]))})
    else
      table.insert(pointers, {hand, vec3(lovr.headset.getPosition(hand .. '/point'))})
    end
  end
end


function panel:getMousePointer(pointers, click_offset)
  local scale = select(4, self.pose:unpack())
  -- overwrite hand/left in desktop VR sim, or make a new pointer for 3d desktop
  pointers[1] = pointers[1] or {'mouse', vec3()}
  -- make a ray in 3D space extending from underneath the mouse cursor to -Z
  local x, y = lovr.system.getMousePosition()
  local ray_origin = vec3(self.world_from_screen:mul(x, y, 1))
  local ray_target = vec3(self.world_from_screen:mul(x, y, 0.001))
  local ray_direction = (ray_target - ray_origin):normalize()
  -- intersect the ray onto panel plane and see if it lands within panel
  local plane_direction = vec3(quat(self.pose):direction())
  local dot = ray_direction:dot(plane_direction)
  if math.abs(dot) > 1e-5 then
    local plane_pos = vec3(self.pose)
    local ray_length = (plane_pos - ray_origin):dot(plane_direction) / dot
    local hit_spot = ray_origin + ray_direction * ray_length
    if click_offset then
      if lovr.system.isMouseDown(2) then
        pointers[1][2]:set(hit_spot + plane_direction * -(0.2 * scale))
      else
        pointers[1][2]:set(hit_spot + plane_direction * (0.2 * scale))
      end
    else
      pointers[1][2]:set(hit_spot)
    end
  end
end


function panel:getPointers(click_offset)
  local pointers = {}
  if lovr.headset then
    self:getHeadsetPointers(pointers)
  end
  if m.mouse_available then
    self:getMousePointer(pointers, click_offset)
  end
  return pointers
end


function panel:getScreenToWorldTransform(pass)
  local w, h = pass:getDimensions()
  local clip_from_screen = mat4(-1, -1, 0):scale(2 / w, 2 / h, 1)
  local view_pose = mat4(pass:getViewPose(1))
  local view_proj = pass:getProjection(1, mat4())
  -- m.is_orthographic = view_proj[16] == 1
  local world_from_screen = view_pose:mul(view_proj:invert()):mul(clip_from_screen)
  self.world_from_screen:set(world_from_screen)
end


function panel:update(dt)
  if not self.visible then return end
  local pointers = self:getPointers(true)
  -- TODO: skip update if outside the panel's AABB
  self:updateWidgets(dt, pointers)
end


function panel:draw(pass, draw_pointers)
  if not self.visible then return end
  if m.mouse_available then
    self:getScreenToWorldTransform(pass)
  end
  pass:push()
  pass:transform(self.pose)
  pass:rotate(math.pi, 0,1,0)
  if self.frame == 'backpanel' then
    pass:setColor(self.palette.panel)
    pass:roundrect(0, 0, -Q / 2,
      self.width + 0.5, self.height + 0.5, Q ,
      0, 0,1,0, 0.4)
  end
  pass:setFont(m.font)
  for _, w in ipairs(self.widgets) do
    pass:push()
    pass:transform(w.pose)
    w:draw(pass)
    pass:pop()
  end
  pass:pop()
  if draw_pointers then
    local pointers = pointers or self:getPointers()
    pass:setColor(color or 0x404040)
    local radius = 0.005
    for _, pointer in ipairs(pointers) do
      pass:sphere(mat4(pointer[2]):scale(radius), m.segments, m.segments)
    end
  end
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


-- creates panel methods for constructing widgets with light OOP based on metatables
function m.initWidgetType(widget_name, widget_proto)
  widget_proto.__index = widget_proto
  -- panel.button{text = 'click me'} should make the button and add it to panel
  panel[widget_name] = function(self, options)
    options = options or {}
    setmetatable(options, widget_proto.defaults)
    widget_proto.defaults.__index = widget_proto.defaults
    local widget = setmetatable({}, widget_proto)
    widget:init(options)
    widget.span = options.span or 1
    widget.panel = self
    table.insert(self.widgets, widget)
    table.insert(self.rows[#self.rows], widget)
    return widget
  end
end


local function initAllWidgets()
  for _, widget_name in ipairs(m.widget_types) do
    local widget_proto = m[widget_name]
    m.initWidgetType(widget_name, widget_proto)
  end
end

initAllWidgets()


-- CHUI HELPERS ---------------------------------------------------------------

function m.setFont(font) -- accepts path to file or loaded font instance
  if type(font) == 'string' then -- path to font file
    local ok, res = pcall(lovr.graphics.newFont, font, 10)
    if ok then
      m.font = res
    else
      print('could not load \'' .. font .. '\', defaulting to built-in Varela Round')
      m.font = lovr.graphics.newFont(10)
    end
  elseif tostring(font) == 'Font' then -- a font instance used as-is
    m.font = font
  else
    m.font = lovr.graphics.newFont(10)
  end
end

-- convenience functions for multiple panels, user can also just call :update & :draw on the panel

function m.update(dt) -- neccessary for UI interactions
  for _, panel in ipairs(m.panels) do
      panel:update(dt)
  end
end


function m.draw(pass, draw_pointers)
  for _, panel in ipairs(m.panels) do
      panel:draw(pass, draw_pointers)
  end
end


function m.reset() -- forget the collected panels
  m.panels = {}
end

return m
