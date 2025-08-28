-- luacheck: ignore data
-- luacheck: ignore script

_G.tac = {}
_DEBUG = false

---@param path string
local function require_lib(path)
    for k, v in pairs(require(path)) do
        if tac[k] ~= nil then
            error(string.format('Trying to override lib function %s from %s', k, path))
        end
        tac[k] = v
    end
end

---@param obj any
tac.print = function(obj)
    if not _DEBUG then
        return
    end

    if type(obj) == 'string' or type(obj) == 'number' or type(obj) == 'boolean' then
        log(obj)
    else
        log(serpent.block(obj))
    end
end

-- tac LIBRARY
--=============================================================================

require 'utils.lib.math'
require 'utils.lib.string'
require 'utils.lib.table'

if data and data.raw and not data.raw.item then
    tac.stage = 'settings'
elseif data and data.raw then
    tac.stage = 'data'
    require_lib 'utils.lib.data'
elseif script then
    tac.stage = 'control'
    require_lib 'utils.lib.control'
else
    error('Could not determine load order stage.')
end
