-- Locks away technologies after a certain amount of time X

local floor = math.floor
local f = string.format
local main_frame_name = 'tac-tl-main_frame'

-- ============================================================================

local function any_splits(time, adjust)
  return {
    { name = 'automation',              cap = 07 / 83 * time * adjust },
    { name = 'logistic-science-pack',   cap = 19 / 83 * time * adjust },
    { name = 'chemical-science-pack',   cap = 35 / 83 * time * adjust },
    { name = 'production-science-pack', cap = 60 / 83 * time * adjust },
    { name = 'utility-science-pack',    cap = 60 / 83 * time * adjust },
    { name = 'rocket-silo',             cap = 81 / 83 * time * adjust },
  }
end

local function display_time(ticks)
  local s = floor((ticks / 60) % 60)
  local m = floor((ticks / 3600) % 60)
  local h = floor(ticks / 216000)
  if h > 0 then
    return f('%02u:%02u:%02u', h, m, s)
  elseif m > 0 then
    return f('%02u:%02u', m, s)
  else
    return f('%02u', s)
  end
end

local function format_time(data)
  local color = { r = 0.88, g = 0.88, b = 0.88 }
  local time = data.cap
  if data.success and data.time then
    color = { r = 0, g = 1, b = 0 }
    time = data.time
  elseif data.success == false then
    color = { r = 1, g = 0, b = 0 }
    time = data.cap
  end
  return display_time(time), color
end


local function update_gui(player)
  local left = player.gui.left

  if left[main_frame_name] then
    left[main_frame_name].destroy()
  end

  if not global.technology_locker then
    return
  end

  if not global.technology_locker_gui[player.index] then
    return
  end

  local main_frame = left.add {
    type = 'frame',
    name = main_frame_name,
    direction = 'vertical',
  }
  main_frame.style.padding = 2
  main_frame.style.minimal_width = 250

  local main_flow = main_frame.add { type = 'frame', direction = 'vertical', style = 'window_content_frame_packed' }

  -- Header
  local frame = main_flow.add { type = 'frame', direction = 'horizontal', style = 'subheader_frame' }
  frame.style.padding = {2, 4}
  frame.style.use_header_filler = false
  frame.style.horizontally_stretchable = true

  local label = frame.add { type = 'label', caption = 'Research', style = 'heading_1_label' }
  label.style.font = 'default-bold'
  label.style.vertical_align = 'center'
  label.style.minimal_height, label.style.maximal_height = 24, 24
  label.style.maximal_width = 230

  local flow = frame.add { type = 'flow', direction = 'horizontal' }
  flow.style.padding = {1, 2}
  flow.style.vertical_align = 'center'
  flow.style.horizontal_align = 'right'
  flow.style.vertically_stretchable  = false
  flow.style.horizontally_stretchable = true

  local label = flow.add { type = 'label', caption = display_time(game.tick), style = 'heading_1_label' }
  label.style.font = 'default-bold'
  label.style.vertical_align = 'center'
  label.style.horizontal_align = 'right'
  label.style.minimal_height, label.style.maximal_height = 24, 24

  -- Table
  for _, data in pairs(global.technology_locker_splits) do
    local frame = main_flow.add { type = 'frame', direction = 'horizontal', style = 'subheader_frame' }
    frame.style.padding = {2, 2}
    frame.style.use_header_filler = false
    frame.style.horizontally_stretchable = true

    local label = frame.add {type = 'sprite', sprite = 'technology/'..data.name, resize_to_sprite = false }
    label.style.minimal_height, label.style.maximal_height = 20, 20
    label.style.minimal_width, label.style.maximal_width = 20, 20

    local label = frame.add { type = 'label', caption = {'technology-name.'..data.name} }
    label.style.font_color = { r = 0.88, g = 0.88, b = 0.88 }
    label.style.vertical_align = 'center'
    label.style.minimal_height, label.style.maximal_height = 20, 20
    label.style.minimal_width, label.style.maximal_width = 200 - 20, 200 - 20

    local flow = frame.add { type = 'flow', direction = 'horizontal' }
    flow.style.padding = {1, 2}
    flow.style.vertical_align = 'center'
    flow.style.horizontal_align = 'right'
    flow.style.vertically_stretchable  = false
    flow.style.horizontally_stretchable = true

    local time, color = format_time(data)

    local label = flow.add { type = 'label', caption = time }
    label.style.font_color = color
    label.style.vertical_align = 'center'
    label.style.horizontal_align = 'right'
    label.style.minimal_height, label.style.maximal_height = 20, 20
  end
end

local function on_tick(event)
  if not global.technology_locker then
    -- Module not enabled
    return
  end

  if game.tick == 0 then
    any_splits(4 * 60 * 60 * 60, 1.4)
  end

  -- Update player GUI (~1s)
  if event.tick % 60 == 0 then
    for _, p in pairs(game.connected_players) do
      update_gui(p)
    end
  end

  -- Lock technologies (~1min)
  if event.tick % 3600 ~= 0 then
    local player = game.forces.player
    local technologies = player.technologies
    local current_time = math.floor(game.tick / 3600)
    for _, data in pairs(global.technology_locker_splits) do
      local tech = technologies[data.name]
      if not tech.researched and current_time > data.cap then
        data.time = event.tick
        data.success = false
        tech.enabled = false
        tech.visible_when_disabled = true
        local current_tech = player.current_research
        if current_research and current_research.name == data.name then
          player.cancel_current_research()
        end
      end
    end
  end
end

local function on_research_finished(event)
  local tech = event.researched
  if global.technology_locker_splits[tech.name] then
    global.technology_locker_splits[tech.name].time = event.tick
    global.technology_locker_splits[tech.name].success = true
  end
end

local function on_settings_changed(event)
  local pb = settings.global['tac:personal_best'].value
  local leeway = settings.global['tac:leeway'].value
  local new_splits = any_splits(pb * 3600, leeway)
  for i, data in pairs(global.technology_locker_splits) do
    data.cap = new_splits[i].cap
  end
end

-- ============================================================================

local Public = {}

Public.name = 'Technology locker'

Public.on_init = function()
  global.technology_locker = true
  global.technology_locker_gui = {}

  local pb = settings.global['tac:personal_best'].value
  local leeway = settings.global['tac:leeway'].value
  global.technology_locker_splits = any_splits(pb * 3600, leeway)
end

Public.events = {
  [defines.events.on_tick] = on_tick,
  [defines.events.on_gui_click] = on_gui_click,
  [defines.events.on_runtime_mod_setting_changed] = on_settings_changed,
}

return Public
