Hooks:PostHook( BlackMarketTweakData, "init", "LegendaryArmourSkins_LoadOutfits", function(self)
	for name, data in pairs( LegendaryArmours ) do
		key = "las_" .. name

		local function remap_variables(data, parent)
			local output = {}

			output.unit = data.fps_unit
			output.third_unit = data.unit

			output.extra_units = data.fps_extra_units
			output.third_extra_units = data.extra_units

			if data.unit_material or data.fps_unit_material then
				output.material_variations = {}
				output.material_variations.default = {}
				output.material_variations.default.custom = true
				output.material_variations.default.third_material = data.unit_material
				output.material_variations.default.material = data.fps_unit_material
			end

			output.name_id = data.name_id or "bm_askn_" .. name
			output.desc_id = data.desc_id or "bm_askn_" .. name .. "_desc"

			output.unlocked = true
			output.auto_aquire = true
			output.custom = true
			output.texture_bundle_folder = data.category or "heist_outfits"

			output.default_glove_id = output.default_glove_id or false
			output.glove_adapter = output.glove_adapter or false

			if data.replace_all then
				output.third_body_replacement = {head=true,armor=true,body=true,hands=true,arms=true,vest=true}
			end

			if data.fps_replace_all then
				output.body_replacement = {head=true,armor=true,body=true,hands=true,arms=true,vest=true}
			end

			if data.replace_all or data.fps_replace_all or data.replace_body or data.fps_replace_body then
				table.insert(self.glove_adapter.player_style_exclude_list, key)
			end

			if data.hide_armor then
				output.third_body_replacement = output.third_body_replacement or {}

				output.third_body_replacement.armor = true
				output.third_body_replacement.vest = true
			end

			if data.replace_body then
				output.third_body_replacement = output.third_body_replacement or {}

				output.third_body_replacement.body = true
				output.third_body_replacement.hands = true
				output.third_body_replacement.arms = true
			end

			if data.fps_hide_armor then
				output.body_replacement = output.body_replacement or {}

				output.body_replacement.armor = true
				output.body_replacement.vest = true
			end

			if data.fps_replace_body then
				output.body_replacement = output.body_replacement or {}

				output.body_replacement.body = true
				output.body_replacement.hands = true
				output.body_replacement.arms = true
			end

			if data.hide_mask then
				output.third_body_replacement = output.third_body_replacement or {}
				output.body_replacement = output.body_replacement or {}

				output.third_body_replacement.mask = true
				output.body_replacement.mask = true
			end

			if data.hide_deployable then
				output.third_body_replacement = output.third_body_replacement or {}
				output.body_replacement = output.body_replacement or {}

				output.third_body_replacement.deployable = true
				output.body_replacement.deployable = true
			end

			if data.character_override then
				output.characters = {}

				for character_id, character_data in pairs(data.character_override) do
					output.characters[character_id] = remap_variables(character_data)
				end
			end

			return output
		end

		self.player_styles[key] = remap_variables(data)
	end
end)