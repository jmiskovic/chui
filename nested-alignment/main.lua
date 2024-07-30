package.path = package.path .. ";../?.lua"

local chui = require'chui'

-- panel with 5x5 randomly sized toggle buttons
local inner_panel = chui.panel{ pose=mat4():scale(1.3), palette=chui.palettes[5] }
lovr.math.setRandomSeed(0)
for i = 1, 5 do
  for j = 1, 5 do
    inner_panel:toggle{ span = {0.1 + lovr.math.random(), 0.1 + lovr.math.random()}, thickness = 0.2 }
  end
  inner_panel:row()
end
inner_panel:layout()

-- main panel with nested panel and alignment control buttons
local main_panel = chui.panel{ pose = mat4():translate(0, 1.7, -0.4):scale(0.05), palette=chui.palettes[13] }
main_panel:spacer{ span = {0, 0.1} }
main_panel:row()
main_panel:nest(inner_panel)
main_panel:row()
main_panel:spacer{ span = {0, 0.5} }
main_panel:row()
main_panel:button{ text='top-left',      callback=function(_, state) inner_panel:layout('left',   'top')    end, span=2 }
main_panel:button{ text='top-center',    callback=function(_, state) inner_panel:layout('center', 'top')    end, span=2 }
main_panel:button{ text='top-right',     callback=function(_, state) inner_panel:layout('right',  'top')    end, span=2 }
main_panel:row()
main_panel:button{ text='center-left',   callback=function(_, state) inner_panel:layout('left',   'center') end, span=2 }
main_panel:button{ text='center-center', callback=function(_, state) inner_panel:layout('center', 'center') end, span=2 }
main_panel:button{ text='center-right',  callback=function(_, state) inner_panel:layout('right',  'center') end, span=2 }
main_panel:row()
main_panel:button{ text='bottom-left',   callback=function(_, state) inner_panel:layout('left',   'bottom') end, span=2 }
main_panel:button{ text='bottom-center', callback=function(_, state) inner_panel:layout('center', 'bottom') end, span=2 }
main_panel:button{ text='bottom-right',  callback=function(_, state) inner_panel:layout('right',  'bottom') end, span=2 }
main_panel:layout()

lovr.graphics.setBackgroundColor(1,1,1)

function lovr.draw(pass)
  chui.draw(pass)
end

function lovr.update(dt)
  chui.update(dt)
end


