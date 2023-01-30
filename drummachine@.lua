local mousearm = require'mousearm'
local ui = require'vr-ui'

local instruments = {
  {name='snare',     sample=lovr.audio.newSource('dm-snare.ogg',     {pitchable=true, spatial=false})},
  {name='hh-open',   sample=lovr.audio.newSource('dm-hatopen.ogg',   {pitchable=true, spatial=false})},
  {name='hh-closed', sample=lovr.audio.newSource('dm-hatclosed.ogg', {pitchable=true, spatial=false})},
  {name='bass',      sample=lovr.audio.newSource('dm-bass.ogg',      {pitchable=true, spatial=false})},
}

local bar_length = 4 * 60 / 120
local step_count = 12

function defaultdict(default_value_factory)
    local t = {}
    local metatable = {}
    metatable.__index = function(t, key)
        if not rawget(t, key) then
            rawset(t, key, default_value_factory(key))
        end
        return rawget(t, key)
    end
    return setmetatable(t, metatable)
end


local seq_table = defaultdict(function() return {} end)
local sequencer = ui.panel(mat4():target(vec3(0, 0.1, -0.6), vec3(0, 0, 0)):scale(0.2))
local labels = {}
local volumes = {}
local pitches = {}

for r, instrument in ipairs(instruments) do
  sequencer:button{text=instrument.name, callback=function() instrument.sample:clone():play() end}

  volumes[r] = sequencer:slider{span=2, text='vol',   min=0, max=1, value=1}
  pitches[r] = sequencer:slider{span=2, text='pitch', min=0.25, max=4, value=r}
  for c = 1, step_count do
    sequencer:toggle{callback = function(_, state)
         seq_table[r][c] = state
       end}
  end
  sequencer:row()
--]]
end


local progress = sequencer:progress{span=5, text='bar'}

for c = 1, step_count do
  labels[c] = sequencer:label{text = '.'}
end
sequencer:row()
tempo = sequencer:slider{span=5, text='tempo', min=64, max=216, value=116}

sequencer:asGrid()


function lovr.load()
end


local last_step = 7

local time = 0

function lovr.update(dt)
  bar_length = 4 * 60 / tempo:get()
  sequencer:update(dt)
  time = time + dt / bar_length * step_count
  -- normalized bar time
  local bar_time = time % step_count
  progress:set(bar_time / step_count)
  for i, label in ipairs(labels) do
    label.text = math.floor(bar_time) == i - 1 and '^' or ''
  end
  if math.floor(bar_time) ~= last_step then
    last_step = math.floor(bar_time)
    -- play bar
    for row, instrument in ipairs(instruments) do
      if seq_table[row][last_step + 1] then
        local sample = instrument.sample:clone()
        sample:setVolume(volumes[row]:get())
        sample:setPitch( pitches[row]:get())
        sample:play()
      end
    end
  end
end


function lovr.draw(pass)
  sequencer:draw(pass)
  pass:sphere(vec3(lovr.headset.getPosition('hand/left')), 0.02)
end
