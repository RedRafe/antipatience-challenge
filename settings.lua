require '__antipatience-challenge__.utils.lib.lib'

data:extend({
    {
        type = 'string-setting',
        name = 'livesplit-dropdown',
        setting_type = 'runtime-global',
        allowed_values = {
            'any',
            'invisible-factory',
            'permanent-factory',
        },
        default_value = 'any',
        order = 'a',
    },
})

tac.add_module_setting('data', 'invisible-factory')
tac.add_module_setting('scripts', 'permanent-factory')
