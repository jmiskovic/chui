local mouse = require'lovr-mouse'

local NEAR_PLANE = 0.01

local m = {}

-- the mapping between controller buttons and keyboard
m.mouse_from_button = {
  trigger    = '2', -- right click
  grip       = '3', -- middle click
}

m.pose = lovr.math.newMat4()
m.linear_velocity  = lovr.math.newVec3()
m.angular_velocity = lovr.math.newVec3()
m.world_from_screen = lovr.math.newMat4()
m.distance = 0.6 -- from screen to hand
m.button_down = {}
m.button_pressed = {}
m.button_released = {}

function lovr.wheelmoved(x, y)
  m.distance = m.distance * (1 + 0.04 * y)
end


function m.getWorldFromScreen(pass)
  local w, h = pass:getDimensions()
  local clip_from_screen = mat4(-1, -1, 0):scale(2 / w, 2 / h, 1)
  local view_pose = mat4(pass:getViewPose(1))
  local view_proj = pass:getProjection(1, mat4())
  return view_pose:mul(view_proj:invert()):mul(clip_from_screen)
end


function m.getRay(distance)
  distance = distance or 1e3
  local ray = {}
  local x, y = mouse.getPosition()
  ray.origin = vec3(m.world_from_screen:mul(x, y, NEAR_PLANE / NEAR_PLANE))
  ray.target = vec3(m.world_from_screen:mul(x, y, NEAR_PLANE / distance))
  return ray
end


-- heavy monkey-patching below, avert your eyes O_o
local originals = {
  update = lovr.headset.update,
  getPose = lovr.headset.getPose,
  getPosition = lovr.headset.getPosition,
  getOrientation = lovr.headset.getOrientation,
  getVelocity = lovr.headset.getVelocity,
  getAngularVelocity = lovr.headset.getAngularVelocity,
}


function lovr.headset.update()
  local dt = originals.update()
  -- update controller button states
  for button, mouse_button in pairs(m.mouse_from_button) do
    local is_down = mouse.isDown(mouse_button)
    m.button_pressed[button]  =     is_down and not m.button_down[button]
    m.button_released[button] = not is_down and     m.button_down[button]
    m.button_down[button] = is_down
  end

  -- make screenspace -> worldspace conversion
  local pass = lovr.headset.getPass()
  local world_from_screen = m.getWorldFromScreen(pass)
  m.world_from_screen:set(world_from_screen)

  -- calculate new hand pose
  local mx, my = mouse.getPosition()
  local x, y, z = world_from_screen:mul(mx, my, NEAR_PLANE / m.distance)
  local dir = vec3(
      world_from_screen:mul(mx, my, NEAR_PLANE / (m.distance + 1))
    ):sub(x, y, z):normalize()
  local curr_pose = mat4(x, y, z, quat(dir))

  -- calculate velocities
  local dt = lovr.timer.getDelta()
  m.linear_velocity:set(curr_pose):sub(vec3(m.pose)):mul(1 / dt)
  local angular_diff = quat(curr_pose):mul(quat(m.pose):conjugate())
  local angle, ax, ay, az = angular_diff:unpack()
  m.angular_velocity:set(
    ax * angle / dt,
    ay * angle / dt,
    az * angle / dt)

  m.pose:set(curr_pose) -- set the pose for current frame
  return dt
end


function lovr.headset.getHands()
  return {'hand/left'}
end


function lovr.headset.isTracked(device)
  return device == 'head' or device == 'hand/left'
end


function lovr.headset.getOrientation(device)
  if not device or device == 'head' then
    return originals.getOrientation('head')
  end
  return quat(m.pose):unpack()
end


function lovr.headset.getPose(device)
  if not device or device == 'head' then
    return originals.getPose('head')
  end
  local x, y, z, _,_,_, angle, ax, ay, az = m.pose:unpack()
  return x, y, z, angle, ax, ay, az
end


function lovr.headset.getPosition(device)
  if not device or device == 'head' then
    return originals.getPosition('head')
  end
  local x, y, z = m.pose:unpack()
  return x, y, z
end


function lovr.headset.getVelocity(device)
  if device == 'head' then
    return originals.getVelocity('head')
  end
  return m.linear_velocity:unpack()
end


function lovr.headset.getAngularVelocity(device)
  if device == 'head' then
    return originals.getAngularVelocity('head')
  end
  return m.angular_velocity:unpack()
end


function lovr.headset.isDown(device, button)
  return m.button_down[button]
end


function lovr.headset.isTouched(device, button)
  return lovr.headset.isDown(device, button)
end


function lovr.headset.wasPressed(device, button)
  return m.button_pressed[button]
end


function lovr.headset.wasReleased(device, button)
  return m.button_released[button]
end


-- expose the lovr-mouse functions
m.getScale = mouse.getScale
m.getX = mouse.getX
m.getY = mouse.getY
m.getRawPosition = mouse.getPosition        -- renamed!
m.setX = mouse.setX
m.setY = mouse.setY
m.setRawPosition = mouse.setPosition        -- renamed!
m.isDown = mouse.isDown
m.getRelativeMode = mouse.getRelativeMode
m.setRelativeMode = mouse.setRelativeMode
m.newCursor = mouse.newCursor
m.getSystemCursor = mouse.getSystemCursor
m.setCursor = mouse.setCursor

return m
