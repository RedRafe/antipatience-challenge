-- Machines have a chance of getting their recipe locked when placed by player or bots
local Q = require 'lib.queue'
local pop  = Q.pop
local push = Q.push
local size = Q.size

local BASE_PERCENT = 0.15
local MAX_RAND = 100

local function track_entity(event)
  local entity = event.entity or event.created_entity
  if not (entity and entity.valid) then
    -- Invalid entity
    return
  end

  if not (entity.prototype and entity.prototype.type == 'assembling-machine') then
    -- Wrong entity type
    return
  end

  push(global.permanent_recipes_data, { entity = entity })
end

local function lock_recipe()
  if not global.permanent_recipes then
    -- Module not enabled
    return
  end

  if size(global.permanent_recipes_data) == 0 then
    return
  end

  local data = pop(global.permanent_recipes_data)
  local entity = data.entity
  if entity and entity.valid then
    local recipe = entity.get_recipe()
    if recipe then
      local permanent_percent = BASE_PERCENT
      local rand = math.random(0, MAX_RAND)

      if rand <= MAX_RAND * (1 - permanent_percent) then
        -- No action
        return
      else
        entity.recipe_locked = true
      end
    else
      if entity.operable then
        push(global.permanent_recipes_data, data)
      end
    end
  end
end

-- ============================================================================

local Public = {}

Public.name = 'Permanent recipes'

Public.on_init = function()
  global.permanent_recipes = true
  global.permanent_recipes_data = Q.new()
end

Public.events = {
  [defines.events.on_robot_built_entity] = track_entity,
  [defines.events.on_built_entity] = track_entity,
  [defines.events.on_tick] = lock_recipe,
}

return Public
