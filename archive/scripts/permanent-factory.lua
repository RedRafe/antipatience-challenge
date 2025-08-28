-- Machines have a chance of becoming permanent when placed by player or bots

local BASE_PERCENT = 0.1
local MAX_RAND = 100
local whitelist = {
  ['accumulator'] = true,
  ['ammo-turret'] = true,
  ['artillery-turret'] = true,
  ['assembling-machine'] = true,
  ['beacon'] = true,
  ['boiler'] = true,
  ['electric-turret'] = true,
  ['fluid-turret'] = true,
  ['furnace'] = true,
  ['generator'] = true,
  ['lab'] = true,
  ['radar'] = true,
  ['reactor'] = true,
  ['roboport'] = true,
  ['rocket-silo'] = true,
  ['solar-panel'] = true,
  ['storage-tank'] = true,
}

local function on_built_entity(event)
  if not global.permanent_factory then
    -- Module not enabled
    return
  end

  local entity = event.entity or event.created_entity
  if not (entity and entity.valid) then
    -- Invalid entity
    return
  end

  if not whitelist[entity.prototype.type] then
    -- Wrong entity type
    return
  end

  local permanent_percent = BASE_PERCENT
  local rand = math.random(0, MAX_RAND)

  if rand <= MAX_RAND * (1 - permanent_percent) then
    -- No action
    return
  else
    entity.minable = false
    --entity.operable = false
    --entity.rotatable = false
    entity.destructible = true
  end
end

-- ============================================================================

local Public = {}

Public.name = 'Permanent factory'

Public.on_init = function()
  global.permanent_factory = true
end

Public.events = {
  [defines.events.on_robot_built_entity] = on_built_entity,
  [defines.events.on_built_entity] = on_built_entity,
}

return Public
