local ids_unit = Idstring("unit")

Hooks:PostHook(NetworkPeer, "_unload_outfit", "LegendaryArmour_PreLoadGameAssets", function(self)
	self._just_unloaded_from_reload = self._loading_outfit_assets
end)

Hooks:PreHook(NetworkPeer, "_chk_outfit_loading_complete", "LegendaryArmour_LoadGameAssets", function(self)
	-- Really sketchy check to stick some stuff in the middle of the reload function.
	if self._just_unloaded_from_reload then

		self._just_unloaded_from_reload = false

		local is_local_peer = self == managers.network:session():local_peer()
		local new_outfit_units = {}
		local asset_load_result_clbk = callback(self, self, "clbk_outfit_asset_loaded", self._outfit_assets)
		local complete_outfit = self:blackmarket_outfit()

		local function get_value_string(value)
			return is_local_peer and tostring(value) or "third_" .. tostring(value)
		end

		local function get_value(value, fallback)
			local value_string = get_value_string(value)
			local output = tweak_data.blackmarket:get_suit_variation_value(player_style, suit_variation, character_name, value_string)
			if not output then
				output = tweak_data.blackmarket:get_player_style_value(player_style, character_name, value_string) or fallback
			end

			return output
		end

		local extra_units = get_value("extra_units")

		if not extra_units then return end

		for index_1, unit_stuff in pairs(extra_units) do
			if tostring(index_1):sub(1, 1) ~= "_" then
				if type(unit_stuff) == "string" then
					new_outfit_units["player_style_w_" .. tostring(index_1)] = {
						name = Idstring(unit_stuff),
						is_streaming = true
					}
				elseif type(unit_stuff) == "table" then
					for index_2, unit_string in pairs(unit_stuff) do
						if tostring(index_2):sub(1, 1) ~= "_" then
							new_outfit_units["player_style_w_" .. tostring(index_1) .. "_" .. tostring(index_2)] = {
								name = Idstring(unit_string),
								is_streaming = true
							}
						end
					end

				end
			end
		end

		for asset_id, asset_data in pairs(new_outfit_units) do
			log(asset_id)
			self._outfit_assets.unit[asset_id] = asset_data
		end

		for asset_id, asset_data in pairs(new_outfit_units) do
			managers.dyn_resource:load(ids_unit, asset_data.name, DynamicResourceManager.DYN_RESOURCES_PACKAGE, asset_load_result_clbk)
		end
	end
end)