local this = {
    enabled = tac.module_enabled('permanent-factory')
}

tac.subscribe(this, function(tbl) this = tbl end)

tac.add(defines.events.on_runtime_mod_setting_changed, function(event)
        this.enabled = tac.module_enabled('permanent-factory')
    end
)