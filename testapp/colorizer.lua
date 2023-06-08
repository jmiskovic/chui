-- module has color manipulation functions and implements palette editing
local m = {}
m.enabled = true

-- compute red/green/blue table from the hue/satureation/lightness table
function m.fromHSL(hsla) -- hsla is table array
  local h, s, l, a = unpack(hsla)
  a = a or 1
  -- hsl to rgb, input and output range: 0 - 1
  if s < 0 then
    return {l,l,l,a}
  end
  h = h * 6
  local c = (1 - math.abs(2 * l - 1)) * s
  local x = (1 - math.abs(h % 2 - 1)) * c
  local md = (l - 0.5 * c)
  local r, g, b
  if     h < 1 then r, g, b = c, x, 0
  elseif h < 2 then r, g, b = x, c, 0
  elseif h < 3 then r, g, b = 0, c, x
  elseif h < 4 then r, g, b = 0, x, c
  elseif h < 5 then r, g, b = x, 0, c
  else              r, g, b = c, 0, x
  end
  return {r + md, g + md, b + md, a}
end


-- compute red/green/blue table from the hexcode
function m.fromHexcode(hexcode)
  if type(hexcode) == 'table' then return {unpack(hexcode)} end
  local r = bit.band(bit.rshift(hexcode, 16), 0xff) / 255
  local g = bit.band(bit.rshift(hexcode, 8),  0xff) / 255
  local b = bit.band(bit.rshift(hexcode, 0),  0xff) / 255
  return {r, g, b, 1}
end


function m.toHexcode(colorTable)
  local r, g, b, _ = unpack(colorTable)
  r, g, b = math.floor(r * 255 + 0.5), math.floor(g * 255 + 0.5), math.floor(b * 255 + 0.5)
  local num = bit.lshift(r, 16) + bit.lshift(g, 8) + bit.lshift(b, 0)
  return string.format('0x%6X', num)
end


-- map all colors from one palette to another
function m.mapPalette(A, B)
  -- for each color find distances to all other colors
  local distances = {}
  for _, colorA in ipairs(A) do
    for _, colorB in ipairs(B) do
      table.insert(distances, {colorA, colorB, vec3(colorA):distance(colorB)})
    end
  end
  -- make unique pairings whilst minimizing the total distance
  -- sort the palette B so that mapped colors are at the same index
end


-- compute hue/saturation/lightness table from the red/green/blue table, or hexcode
function m.toHSL(rgba) -- rgba is table array or hexcode
  local r, g, b, a
  if type(rgba) == 'table' then
    r, g, b, a = unpack(rgba)
  else
    r, g, b, a = unpack(m.fromHexcode(rgba))
  end
  a = a or 1
  local min, max = math.min(r, g, b), math.max(r, g, b)
  local h, s, l = 0, 0, (max + min) / 2
  if max ~= min then
      local d = max - min
      s = l > 0.5 and d / (2 - max - min) or d / (max + min)
      if max == r then
          local mod = 6
          if g > b then mod = 0 end
          h = (g - b) / d + mod
      elseif max == g then
          h = (b - r) / d + 2
      else
          h = (r - g) / d + 4
      end
  end
  h = h / 6
  return {h, s, l, a}
end


-- set the edited palette
function m.setPalette(palette)
  m.palette = palette
  m.edited = nil
  m.select()
end


-- select a color from palette: by index, by name or select the next one
function m.select(key)
  if not key then
    key = next(m.palette, m.edited)
    if not key then
      key = next(m.palette)
    end
  elseif type(key) == 'number' then
    key = 1 + key % #m.palette
  end
  m.edited = key
  local color = m.palette[m.edited]
  m.hsla = m.toHSL(color)
end


-- get the HSL string representation of a given color, or the edited color
function m.toStringHSL(color)
  if color then
    return string.format('fromHSL(%1.2f, %1.2f, %1.2f)', unpack(m.toHSL(color)))
  else
    return string.format('fromHSL(%1.2f, %1.2f, %1.2f) -- %s', m.hsla[1], m.hsla[2], m.hsla[3], tostring(m.edited))
  end
end


-- create a small image of all colors in the palette
function m.toImage()
  -- convert m.palette dictionary to array
  local palette
  if type(next(m.palette)) ~= 'number' then
    palette = {}
    for _, color in pairs(m.palette) do
      table.insert(palette, color)
    end
  else
    palette = m.palette
  end
  local rows = math.floor(math.sqrt(#palette))
  local cols = math.ceil(#palette / rows)
  local image = lovr.data.newImage(rows, cols)
  for i, color in ipairs(palette) do
    color = type(color) == 'table' and color or m.fromHexcode(color)
    local x, y = (i - 1) % rows, math.floor((i - 1) / rows)
    image:setPixel(x, y, unpack(color))
  end
  return image
end


function m.info()
  local out = {}
  table.insert(out, 'local palette = {')
  for name, color in pairs(m.palette) do
    color = type(color) == 'table' and color or m.fromHexcode(color)
    if type(name) == 'string' then
      table.insert(out, string.format('  %s = {%1.3f, %1.3f, %1.3f}, -- %s', name,
        color[1], color[2], color[3],
        m.toHexcode(color)))
    else
      table.insert(out, string.format('  {%1.3f, %1.3f, %1.3f}, -- %s'),
        color[1], color[2], color[3],
        m.toHexcode(color))
    end
  end
  table.insert(out, '}')
  table.insert(out, string.format('selected = %s', tostring(m.edited)))
  return table.concat(out, '\n')
end


-- color is changed dragging the HSL along one of these axes
local axes = {
  lovr.math.newVec3(   1, 0, 0):normalize(),              -- hue
  lovr.math.newVec3(-1/2, math.sqrt(3)/2, 0):normalize(), -- saturation
  lovr.math.newVec3( 1/2, math.sqrt(3)/2, 0):normalize(), -- lightness
}


-- modify the selected color while left hand trigger is pressed
function m.update(dt)
  if not m.enabled then return end
  if lovr.headset.isDown('hand/left', 'trigger') then
    local vel = vec3(lovr.headset.getVelocity('hand/left'))
    -- make movements relative to the head orientation
    quat(lovr.headset.getOrientation('head'))
      :conjugate()
      :mul(vel)
    local max_proj, max_i
  for i, axis in ipairs(axes) do
      local proj = vel:dot(axis)
      if max_proj == nil or math.abs(proj) > math.abs(max_proj) then
        max_proj = proj
        max_i = i
      end
    end
    m.hsla[max_i] = m.hsla[max_i] + max_proj * dt * 0.5
    m.hsla[1] = m.hsla[1]  % 1
    m.hsla[2] = math.min(1, math.max(0, m.hsla[2]))
    m.hsla[3] = math.min(1, math.max(0, m.hsla[3]))
    m.palette[m.edited] = m.fromHSL(m.hsla)
  end
end


return m
