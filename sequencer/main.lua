-- a toy drum sequencer as demo app for chui UI framework

local chui = require'chui'

local step_count = 12
local bar_length = 4 * 60 / 120

local instruments = {
  { pitch = 1.0, volume = 1, name='snare',     sample_path='dm-snare.ogg' },
  { pitch = 1.4, volume = 1, name='hh-open',   sample_path='dm-hatopen.ogg' },
  { pitch = 1.2, volume = 1, name='hh-closed', sample_path='dm-hatclosed.ogg' },
  { pitch = 0.8, volume = 1, name='bass',      sample_path='dm-bass.ogg' },
  -- add more as desired
}

-- load in the samples; we later clone them to be able to play multiple samples at once
for _, instrument in ipairs(instruments) do
  instrument.sample = lovr.audio.newSource(instrument.sample_path, {pitchable=true, spatial=false})
end


-- best use a sparse grid for sequencer triggers
local function defaultdict(default_value_factory)
    local t = {}
    local metatable = {}
    metatable.__index = function(tbl, key)
        if not rawget(tbl, key) then
            rawset(tbl, key, default_value_factory(key))
        end
        return rawget(tbl, key)
    end
    return setmetatable(t, metatable)
end
local seq_table = defaultdict(function() return {} end)


-- start building the UI; first the instrument lanes and then general controls

local sequencer_panel = chui.panel{
  palette = chui.palettes[6],
  pose=mat4()
    :translate(0, 1.5, -1)
    :rotate(math.pi, 0,1,0)
    :rotate(0.2, 1,0,0)
    :scale(0.16)
  }
local volume_sliders = {}
local pitch_sliders = {}

for r, instrument in ipairs(instruments) do
  -- a trigger pushbutton to play the sample
  sequencer_panel:button{ span=0.3, callback=function() instrument.sample:clone():play() end }
  -- sample name
  sequencer_panel:label{ text=instrument.name }
  -- volume and pitch parameters
  volume_sliders[r] = sequencer_panel:slider{ span=1.5, text='vol', min=0, max=1, value= instrument.volume }
  pitch_sliders[r] =  sequencer_panel:slider{ span=2, text='pitch', min=0.25, max=4, value= instrument.pitch }
  -- a row of toggle buttons that activate the sequencer
  for c = 1, step_count do
    sequencer_panel:toggle{span=0.6, callback = function(_, state)
         seq_table[r][c] = state
       end}
  end
  -- finish the row after each instrument's widgets to prepare for next
  sequencer_panel:row()
end

-- tempo and bar progress spans are manually adjusted to be aligned with previous widgets
local tempo_slider = sequencer_panel:slider{ span=5.5, text='tempo', min=64, max=216, value=116, step=0.5 }
local progress_bar = sequencer_panel:progress{ span=9.5, text='bar' }
-- after adding the widgets, layout them in horizontally centered rows
sequencer_panel:layout()


local last_step = 7
local time = 0

function lovr.update(dt)
  sequencer_panel:update(dt) -- allow ui to process interactions
  bar_length = 4 * 60 / tempo_slider:get() -- use slide to scale the tempo_slider
  time = time + dt / bar_length * step_count
  local bar_time = time % step_count -- bar time, normalized to [0, step_count] range
  progress_bar:set(bar_time / step_count)
  -- play the step notes if the bar timer beyond the previous step
  if math.floor(bar_time) ~= last_step then
    -- play any active toggle bar on this step
    last_step = math.floor(bar_time)
    for row, instrument in ipairs(instruments) do
      instrument.volume = volume_sliders[row]:get()
      instrument.pitch = pitch_sliders[row]:get()
      local tgl = seq_table[row][last_step + 1]
      if tgl then
        local sample = instrument.sample:clone()
        sample:setVolume(instrument.volume)
        sample:setPitch(instrument.pitch)
        sample:play()
      end
    end
  end
end


function lovr.draw(pass)
  sequencer_panel:draw(pass)
  chui.drawPointers(pass) -- optional for desktop usage
end
