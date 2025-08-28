-- Players have a maximum count of entities that can be built (assemblers/furnaces)

local alert_message = '[color=yellow]Cannot build anymore machines![/color]'

local function on_built_entity(event)
  local entity = event.entity or event.created_entity
  if not (entity and entity.valid) then
    return
  end

  if not (entity.prototype and (entity.prototype.type == 'assembling-machine' or entity.prototype.type == 'furnace')) then
    -- Wrong entity type
    return
  end

  local id = script.register_on_entity_destroyed(entity)
  global.limited_factory_register[id] = true
  global.limited_factory_count = global.limited_factory_count + 1

  if not (global.limited_factory) then
    -- Module not enabled
    return
  end

  if global.limited_factory_count <= global.limited_factory_max_count then
    return
  end

  local player = game.get_player(event.player_index or 'none')

  if player and player.valid then
    player.mine_entity(entity, true)
    player.print(alert_message)
  else
    local force = entity.force
    local surface = entity.surface
    local position = entity.position
    entity.destroy({ raise_destroy = true })
    surface.spill_item_stack(position, event.stack, nil, force)
  end
end

local function on_destroyed_entity(event)
  local id = event.registration_number
  if global.limited_factory_register[id] then
    global.limited_factory_count = global.limited_factory_count - 1
    global.limited_factory_register[id] = nil
  end
end

-- ============================================================================

local Public = {}

Public.name = 'Limited factory'

Public.on_init = function()
  global.limited_factory = true
  global.limited_factory_count = 0
  global.limited_factory_max_count = 1000
  global.limited_factory_register = {}
end

Public.events = {
  [defines.events.on_robot_built_entity] = on_built_entity,
  [defines.events.on_built_entity] = on_built_entity,
  [defines.events.on_entity_destroyed] = on_destroyed_entity,
}

return Public
