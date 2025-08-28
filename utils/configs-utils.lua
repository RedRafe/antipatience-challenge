local function timestring_to_ticks(text)
    local ticks = 0
    local times = string.split(text, '([^:]+)')
    for i = #times, 1, -1 do
        ticks = ticks + (times[i] * 60 ^ (#times - i + 1))
    end
    return ticks
end

local function parse_config_table(config)
    for _, preset in pairs(config) do
        if preset.splits and #preset.splits > 0 then
            --- AUTOGENERATE time
            if preset.time == nil then
                preset.time = preset.splits[#preset.splits].time
            end

            for _, split in pairs(preset.splits) do
                --- AUTOGENERATE ticks
                if split.ticks == nil then
                    split.ticks = timestring_to_ticks(split.time)
                end
                --- AUTOGENERATE icon
                if split.icon == nil then
                    split.icon = split.type .. '/' .. split.name
                end
            end
        end
        if preset.time then
            preset.ticks = timestring_to_ticks(preset.time)
        end
    end
    return config
end

return {
    parse_config_table = parse_config_table,
}