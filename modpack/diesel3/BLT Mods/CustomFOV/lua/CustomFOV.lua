if not CustomFOV then
        log("[CustomFOV] Error: Failed to create Mod Options menu, aborting")
        return
end

if not MenuCallbackHandler then
        log("[CustomFOV] Error: MenuCallbackHandler is nil, aborting")
        return
end

local function AddModOptions(menu_manager)
        if menu_manager == nil then
                return
        end

        MenuCallbackHandler.CustomFOV_SaveSettings = function(node)
                CustomFOV:Save()
        end

        MenuCallbackHandler.set_fov_multiplier = function(self, item)
                CustomFOV.Settings.fov_multiplier = item:value()
                managers.user:set_setting("fov_multiplier", CustomFOV.Settings.fov_multiplier)
                if alive(managers.player:player_unit()) then
                        managers.player:player_unit():movement():current_state():update_fov_external()
                end
        end


        MenuHelper:LoadFromJsonFile(CustomFOV.ModOptions, CustomFOV, CustomFOV.Settings)
end

Hooks:Add("MenuManagerInitialize", "CustomFOV_AddModOptions", AddModOptions)
