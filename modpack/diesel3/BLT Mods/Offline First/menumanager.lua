_G.online_panels = _G.online_panels or {}

if RequiredScript== "lib/managers/menumanager" then
	Hooks:PostHook(MenuManager, "update", "MenuManager_RemoveConnectingScreenAndTransfer", function(self)
		if game_state_machine and game_state_machine.current_state_name and game_state_machine:current_state_name() == "menu_main" then
			if managers.menu:active_menu() then
				if online_panels then
					local is_signed_in = true
					
					if SystemInfo:matchmaking() == Idstring("MM_EPIC") and not EpicMM:logged_on() then
						is_signed_in = false
					end
					
					for _, t_panel in ipairs(online_panels) do
						if t_panel and tostring(t_panel) ~= "[Text NULL]" then
							if is_signed_in and Steam:logged_on() then
								t_panel:set_text(managers.localization:to_upper_text("menu_crimenet"))
							else		
								t_panel:set_text(managers.localization:to_upper_text("menu_connect_eos"))
							end
						elseif tostring(t_panel) == "[Text NULL]" then
							online_panels = {}
						end
					end
				end
			end
		end
	end)
elseif RequiredScript== "lib/managers/menu/menunodegui" then
	local MenuNodeGui_text_item_part = MenuNodeGui._text_item_part
	function MenuNodeGui:_text_item_part(row_item, ...)
		local text_panel = MenuNodeGui_text_item_part(self, row_item, ...)

		if row_item.item:parameters().name == "crimenet" then
			online_panels[#online_panels+1] = text_panel
		end
		
		return text_panel
	end
end