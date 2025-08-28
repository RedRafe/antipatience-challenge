-- Inserters are sometimes randomly rotated when placed by player or bots

local BASE_PERCENT = 0.1
local MAX_RAND = 100 * 3

-- ============================================================================

local function on_built_inserter(event)
  if not global.dancing_inserters then
    -- Module not enabled
    return
  end

  local entity = event.entity or event.created_entity
  if not (entity and entity.valid) then
    -- Invalid entity
    return
  end

  if not (entity.prototype and entity.prototype.type == 'inserter') then
    -- Wrong entity type
    return
  end

  local rotate_percent = BASE_PERCENT
  local rand = math.random(0, MAX_RAND)

  if rand <= MAX_RAND * (1 - rotate_percent) then
    -- No Rotation
    return
  elseif rand <= MAX_RAND * (1 - rotate_percent * 2 / 3) then
    -- Single Rotation
    entity.rotate()
    return
  elseif rand <= MAX_RAND * (1 - rotate_percent * 1 / 3) then
    -- Double Rotation
    entity.rotate()
    entity.rotate()
    return
  elseif rand <= MAX_RAND then
    -- Reverse Rotation
    entity.rotate({ reverse = true })
    return
  end
end

-- ============================================================================

local Public = {}

Public.name = 'Dancing inserters'

Public.on_init = function()
  global.dancing_inserters = true
end

Public.events = {
  [defines.events.on_robot_built_entity] = on_built_inserter,
  [defines.events.on_built_entity] = on_built_inserter,
}

return Public
