local buzzkill = true

Hooks:PostHook(TweakData, "_init_pd2", "LegendaryArmourSkins_WeaponSkinsTweakData", function(self)
	local immortal_pythons = {}

	for skin_id, skin_data in pairs(self.blackmarket.weapon_skins) do
		if string.match(skin_data.name_id, "_tam") then
			skin_data.tweak_id = skin_id
			table.insert(immortal_pythons, skin_data)
		else
			self.economy.armor_skins["las_" .. skin_id] = {
				name_id = skin_data.name_id,
				desc_id = "",
				rarity = skin_data.rarity,

				steam_economy = false,
				free = true,
				reserve_quality = false,
				texture_bundle_folder = skin_data.texture_bundle_folder,

				override_icon_folder = "weapon_skins/",
				override_icon_id = skin_id,
				category = "weapon_skins",

				base_gradient = skin_data.base_gradient,
				pattern_gradient = skin_data.pattern_gradient,
				pattern = skin_data.pattern,
				sticker = skin_data.sticker,
				pattern_tweak = skin_data.pattern_tweak,
				pattern_pos = skin_data.pattern_pos,
				uv_scale = skin_data.uv_scale,
				uv_offset_rot = skin_data.uv_offset_rot,
				cubemap_pattern_control = skin_data.cubemap_pattern_control
			}

			if skin_data.custom or not buzzkill then
				self.economy.armor_skins["las_" .. skin_id].unlocked = true
			end


			for part_id, part_skin_data in pairs(skin_data.parts or {}) do
				for material_id, material_skin_data in pairs(part_skin_data) do
					for key, value in pairs(material_skin_data) do
						self.economy.armor_skins["las_" .. skin_id][key] = self.economy.armor_skins["las_" .. skin_id][key] or value
					end
				end
			end
		end
	end

	if ( #immortal_pythons == 0 ) then return end

	local tam_data = immortal_pythons[ math.random( #immortal_pythons ) ]
	self.economy.armor_skins["las_immortal_python_fuck_off"] = {
		name_id = tam_data.name_id,
		desc_id = tam_data.desc_id,
		rarity = tam_data.rarity,

		reserve_quality = false,
		steam_economy = false,
		free = true,
		unlocked = true,
		texture_bundle_folder = tam_data.texture_bundle_folder,

		override_icon_folder = "weapon_skins/",
		override_icon_id = tam_data.tweak_id,
		category = "weapon_skins",

		base_gradient = tam_data.base_gradient,
		pattern_gradient = tam_data.pattern_gradient,
		pattern = tam_data.pattern,
		sticker = tam_data.sticker,
		pattern_tweak = tam_data.pattern_tweak,
		pattern_pos = tam_data.pattern_pos,
		uv_scale = tam_data.uv_scale,
		uv_offset_rot = tam_data.uv_offset_rot,
		cubemap_pattern_control = tam_data.cubemap_pattern_control
	}

	for part_id, part_skin_data in pairs(tam_data.parts or {}) do
		for material_id, material_skin_data in pairs(part_skin_data) do
			for key, value in pairs(material_skin_data) do
				self.economy.armor_skins["las_immortal_python_fuck_off"][key] = self.economy.armor_skins["las_immortal_python_fuck_off"][key] or value
			end
		end
	end
end)