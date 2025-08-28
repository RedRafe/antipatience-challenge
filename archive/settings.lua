data:extend({
  {
		name = 'tac:personal_best',
		type = 'int-setting',
		setting_type = 'runtime-global',
		default_value = 83, -- 1h22m59s
    minimum_value = 60,       --   1h
    maximum_value = 100 * 60, -- 100h 
		hidden = false,
		order = '0',
	},
  {
		name = 'tac:leeway',
		type = 'double-setting',
		setting_type = 'runtime-global',
		default_value = 2.4,
    minimum_value = 0.5,
    maximum_value = 10, 
		hidden = false,
		order = '2',
	},
})