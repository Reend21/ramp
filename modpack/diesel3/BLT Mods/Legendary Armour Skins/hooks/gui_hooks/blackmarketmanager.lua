BlackMarketManager.las_pre_player_loadout_data = BlackMarketManager.las_pre_player_loadout_data or BlackMarketManager.player_loadout_data
function BlackMarketManager:player_loadout_data(show_all_icons)
	local original_data = self:las_pre_player_loadout_data(show_all_icons)
	if ( original_data.outfit and original_data.outfit.player_style ) then
		local outfit_data = original_data.outfit.player_style

		local player_style = self:equipped_player_style()

		if ( player_style and player_style:sub(1, 4) == "las_" ) then
			outfit_data.info_text = "[LAS] " .. outfit_data.info_text

			local player_style_data = tweak_data.blackmarket.player_styles[player_style]
			local icon_name = player_style:sub(5, -1)

			local guis_catalog = "guis/"
			bundle_folder = player_style_data.texture_bundle_folder

			if bundle_folder then
				guis_catalog = guis_catalog .. "dlcs/" .. tostring(bundle_folder) .. "/"
			end

			outfit_data.item_texture = guis_catalog .. "armor_skins/" .. icon_name
		end
	end

	return original_data
end