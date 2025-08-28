local mod_gui = require 'mod-gui'
local main_button_name = 'tac-main-button'

-- ============================================================================

local function create_top_gui(player)
  local button_flow = mod_gui.get_button_flow(player)
  local button = button_flow[main_button_name]
  if not button then
    button = button_flow.add {
      type = 'sprite-button',
      name = main_button_name,
      sprite = 'taco-socks',
      style = mod_gui.button_style,
      auto_toggle = true,
      toggled = true,
    }
  end
  return button
end

local function on_gui_click(event)
  local player = game.players[event.player_index]
  local element = event.element

  if element.name == main_button_name then
    global.technology_locker_gui[player.index] = element.toggled
  end
end

local function on_player_created(event)
  local player = game.players[event.player_index]
  global.technology_locker_gui[player.index] = true
  create_top_gui(player)
end

-- ============================================================================

local Public = {}

Public.on_init = function()
  for _, p in pairs(game.players) do
    on_player_created({ player_index = player.index })
  end
end

Public.events = { [defines.events.on_player_created] = on_player_created, [defines.events.on_gui_click] = on_gui_click }

return Public
