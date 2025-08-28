local Public = {}

-- SETTINGS UTIL LIBRARY
--=============================================================================

---@param folder string, 'data'|'scripts'
---@param name string
Public.add_module_setting = function(folder, name)
    data:extend({
        {
            type = 'bool-setting',
            name = name,
            setting_type = (folder == 'data') and 'startup' or 'runtime-global',
            default_value = false,
            order = 'module-'..folder..'-'..name,
            localised_name = {'', {'tac.module_name'}, {'mod-setting-name.'..name} },
            localised_description = {'', {'tac.module_description'}, {'mod-setting-description.'..name} },
        }
    })
end

return Public