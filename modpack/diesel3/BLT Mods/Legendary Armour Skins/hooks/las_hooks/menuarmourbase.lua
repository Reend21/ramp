Hooks:PreHook(MenuArmourBase, "_load_cosmetic_assets", "LegendaryArmour_LoadMenuAssets", function(self, cosmetics)
	local visual_state = cosmetics.state
	local extra_units = tweak_data.blackmarket:get_player_style_value(visual_state.player_style, visual_state.character_name, "third_extra_units")

	if not extra_units then return end

	for index_1, unit_stuff in pairs(extra_units) do
		if tostring(index_1):sub(1, 1) ~= "_" then
			if type(unit_stuff) == "string" then
				self:_add_asset(cosmetics.unit, unit_stuff)
			elseif type(unit_stuff) == "table" then
				for index_2, unit_string in pairs(unit_stuff) do
					if tostring(index_2):sub(1, 1) ~= "_" then
						self:_add_asset(cosmetics.unit, unit_string)
					end
				end
			end
		end
	end
end)