Hooks:PostHook( TweakData, "_init_pd2", "LegendaryArmourSkins_MaterialTweakData", function(self)
	for material_id, material_data in pairs(self.blackmarket.materials) do
		self.economy.armor_skins["las_" .. material_id] = {
			name_id = material_data.name_id,
			desc_id = "",
			rarity = "common",
			reserve_quality = false,
			steam_economy = false,
			free = true,
			unlocked = true,
			texture_bundle_folder = material_data.texture_bundle_folder,

			override_icon_folder = "textures/pd2/blackmarket/icons/materials/",
			override_icon_id = material_id,
			category = "materials",

			base_gradient = Idstring("units/payday2_cash/safes/cvc/base_gradient/base_cvc_001_df"),
			cubemap_pattern_control = Vector3(0, 0.001, 0)
		}


		local not_gradient = ( material_data.material_amount and material_data.material_amount == 0 )
		if not_gradient then
			self.economy.armor_skins["las_" .. material_id].sticker = Idstring(material_data.texture)
			self.economy.armor_skins["las_" .. material_id].uv_scale = Vector3(1, 1, 1)
			self.economy.armor_skins["las_" .. material_id].uv_offset_rot = Vector3(-0.001, 0.994791, 0)
		else
			self.economy.armor_skins["las_" .. material_id].base_gradient = Idstring(material_data.texture)
		end
	end
end)