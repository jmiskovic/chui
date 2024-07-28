-- color manipulation functions
local m = {}

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
  return string.format('0x%06x', num)
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


-- get the HSL string representation of a given color, or the edited color
function m.toStringHSL(color)
  if color then
    return string.format('fromHSL(%1.2f, %1.2f, %1.2f)', unpack(m.toHSL(color)))
  else
    return string.format('fromHSL(%1.2f, %1.2f, %1.2f) -- %s', m.hsla[1], m.hsla[2], m.hsla[3], tostring(m.edited))
  end
end


function m.chuiPaletteString(palette)
  local out = {}
  for _, name in ipairs({'cap', 'inactive', 'active', 'hover', 'text', 'panel'}) do
    color = palette[name]
    color = type(color) == 'table' and color or m.fromHexcode(color)
    table.insert(out, string.format('%s = %s', name, m.toHexcode(color)))
  end
  return '{ ' .. table.concat(out, ', ') .. ' },'
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


return m
