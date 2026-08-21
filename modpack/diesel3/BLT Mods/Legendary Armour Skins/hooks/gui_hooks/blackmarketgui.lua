function BlackMarketGui:populate_armor_skins(data)
	local new_data = {}
	local sort_data = self._armor_skin_sort_data
	local inventory_tradable = managers.blackmarket:get_inventory_tradable()

	if not sort_data then
		sort_data = {}

		for skin_id, skin_data in pairs(tweak_data.economy.armor_skins) do
			if skin_data.sorted == nil or skin_data.sorted then
				table.insert(sort_data, skin_id)
			end
		end

		table.sort(sort_data, function (a, b)
			local ad = tweak_data.economy.armor_skins[a]
			local bd = tweak_data.economy.armor_skins[b]
			local ar = tweak_data.economy.rarities[ad and ad.rarity or "common"].index
			local br = tweak_data.economy.rarities[bd and bd.rarity or "common"].index

			if ar ~= br then
				return br < ar
			elseif ad.sorting_idx or bd.sorting_idx then
				local as = ad.sorting_idx or -1
				local bs = bd.sorting_idx or -1

				if as ~= bs then
					return bs < as
				end
			end

			return managers.localization:text(ad and ad.name_id or "error") < managers.localization:text(bd and bd.name_id or "error")
		end)
		table.insert(sort_data, 1, "none")


		self._armor_skin_sort_data = sort_data
	end

	local guis_catalog = "guis/"
	local index = 0

	for i, skin_id in ipairs(sort_data) do
		local td = tweak_data.economy.armor_skins[skin_id]
		local category = td.category or "vanilla"
		if category == "armor_skins" then category = "vanilla" end

		if not data.category or ( category == data.category or skin_id == "none" ) then
			local unlocked = managers.blackmarket:armor_skin_unlocked(skin_id)

			if not unlocked then
				for _, data in pairs(inventory_tradable) do
					if data.entry == skin_id or ("las_" .. data.entry) == skin_id then
						unlocked = true

						break
					end
				end
			end

			if ( unlocked or not LA_Skins.Options:GetValue("HideLockedSkins") ) then
				local name_id = td.name_id or ""

				guis_catalog = "guis/"
				local bundle_folder = td.texture_bundle_folder

				if bundle_folder then
					guis_catalog = guis_catalog .. "dlcs/" .. tostring(bundle_folder) .. "/"
				end

				index = index + 1
				local new_data = {
					name = skin_id,
					name_localized = managers.localization:text(name_id),
					category = "armor_skins",
					slot = index,
					unlocked = true,
					level = 0,
					equipped = skin_id == managers.blackmarket:equipped_armor_skin()
				}

				if i ~= 1 then
					new_data.bitmap_texture = guis_catalog .. ( td.override_icon_folder or "armor_skins/" ) .. ( td.override_icon_id or skin_id )
					new_data.bg_texture = managers.blackmarket:get_cosmetic_rarity_bg(td.rarity or "common")
				else
					new_data.button_text = managers.localization:to_upper_text("menu_casino_option_prefer_none")
				end

				new_data.comparision_data = {}
				new_data.lock_texture = self:get_lock_icon(new_data)
				new_data.cosmetic_unlocked = unlocked or false
				new_data.cosmetic_rarity = td.rarity

				if not new_data.cosmetic_unlocked then
					new_data.lock_texture = true
					new_data.bitmap_locked_blend_mode = "normal"
					new_data.bg_alpha = 0.4
				end

				if new_data.cosmetic_unlocked and not new_data.equipped then
					table.insert(new_data, "as_equip")
				end

				table.insert(new_data, "as_preview")

				if managers.user:get_setting("workshop") then
					table.insert(new_data, "as_workshop")
				end

				data[index] = new_data
			end
		end
	end

	local empty_slots_needed = data.override_slots[1] - ( index % data.override_slots[1] )

	if empty_slots_needed ~= data.override_slots[1] then
		for i = 1, empty_slots_needed, 1 do
			index = index + 1
			
			local new_data = {
				name = "empty",
				name_localized = "",
				category = "armors",
				slot = index,
				unlocked = true,
				equipped = false
			}

			data[index] = new_data
		end
	end
end

local function gatherArmorCategories( tweak_data )
	local categories = {}

	for key, armor_data in pairs(tweak_data) do
		local category = armor_data.category

		if category and not table.contains( categories, category ) and category ~= "vanilla" then
			table.insert( categories, category )
		end
	end

	return categories
end

function BlackMarketGui:open_armor_skins_menu_callback(data)
	local new_node_data = {}

	local use_skin_categories = LA_Skins.Options:GetValue("UseSkinCategories")
	local use_alt_skin_menu = LA_Skins.Options:GetValue("UseAlternativeSkinMenu")

	if use_skin_categories then
		local categories = gatherArmorCategories( tweak_data.economy.armor_skins )

		table.insert(new_node_data, {
			name = "bm_menu_vanilla_armor_skins",
			on_create_func_name = "populate_armor_skins",
			category = "vanilla",
			override_slots = {
				( use_alt_skin_menu and 5 or 3 ),
				3
			},
			identifier = self.identifiers.armor_skins
		})

		for index, category in ipairs(categories) do
			table.insert(new_node_data, {
				name = "bm_menu_" .. category .. "_armor_skins",
				on_create_func_name = "populate_armor_skins",
				category = category,
				override_slots = {
					( use_alt_skin_menu and 5 or 3 ),
					3
				},
				identifier = self.identifiers.armor_skins
			})
		end
	else
		table.insert(new_node_data, {
			name = "bm_menu_armor_skins",
			on_create_func_name = "populate_armor_skins",
			override_slots = {
				( use_alt_skin_menu and 5 or 3 ),
				3
			},
			identifier = self.identifiers.armor_skins
		})
	end

	if use_alt_skin_menu then
		new_node_data.topic_id = "bm_menu_armor_skins"
		new_node_data.panel_grid_w_mul = 1.07
		new_node_data.info_box_w_mul = 0.8
		new_node_data.skip_blur = true
		new_node_data.use_bgs = true
		new_node_data.hide_detection_panel = true
		new_node_data.can_hide_all = true
	else
		new_node_data.topic_id = "bm_menu_armor_skins"
		new_node_data.panel_grid_w_mul = 0.6
		new_node_data.skip_blur = true
		new_node_data.use_bgs = true
		new_node_data.hide_detection_panel = true
	end

	managers.menu:open_node("blackmarket_armor_node", {new_node_data})
end

local is_win32 = SystemInfo:platform() == Idstring("WIN32")
local NOT_WIN_32 = not is_win32
local WIDTH_MULTIPLIER = NOT_WIN_32 and 0.68 or 0.71
local BOX_GAP = 13.5

local function make_fine_text(text)
	local x, y, w, h = text:text_rect()

	text:set_size(w, h)
	text:set_position(math.round(text:x()), math.round(text:y()))
end

Hooks:PostHook( BlackMarketGui, "_setup", "LegendaryArmour_ExtraSetup", function( self, is_start_page, component_data )
	local info_box_w = math.floor(self._panel:w() * (1 - WIDTH_MULTIPLIER) * (self._data.info_box_w_mul or 1) - BOX_GAP)

	local panels_to_update = {
		self._panel:panel({name = "info_box_panel"}),
		self._weapon_info_panel,
		self._detection_panel,
		self._btn_panel
	}

	for _, panel in ipairs( panels_to_update ) do
		panel:set_w( info_box_w )
		panel:set_right( self._panel:w() )
	end

	self._armor_info_panel:set_w( self._weapon_info_panel:w() )
	self._info_texts_panel:set_w( self._weapon_info_panel:w() - 20 )

	self._buttons:set_w( self._weapon_info_panel:w() )
	for _, btn in pairs(self._btns) do
		btn._panel:set_w( self._buttons:w() - 20 )
		btn._btn_text:set_right( self._buttons:w() - 20 )
	end

	if self._data.can_hide_all then
		self._legends_panel = self._panel:panel({
			w = self._panel:w() * 0.75,
			h = tweak_data.menu.pd2_medium_font_size
		})
		self._legends = {}

		if managers.menu:is_pc_controller() then
			self._legends_panel:set_righttop(self._panel:w(), 0)

			local hide_all_panel = self._legends_panel:panel({
				visible = true,
				name = "hide_all"
			})
			local hide_all_text = hide_all_panel:text({
				blend_mode = "add",
				text = managers.localization:to_upper_text("menu_hide_all", {BTN_X = managers.localization:btn_macro("menu_update")}),
				font = tweak_data.menu.pd2_small_font,
				font_size = tweak_data.menu.pd2_small_font_size,
				color = tweak_data.screen_colors.text
			})

			make_fine_text( hide_all_text )
			hide_all_text:set_center_y( hide_all_panel:h() / 2 )

			hide_all_panel:set_w( hide_all_text:right() )
			hide_all_panel:set_right( self._legends_panel:w() )

			self._legends.hide_all = hide_all_panel
		end
	end

	self:update_info_text()
end)

Hooks:PostHook(BlackMarketGui, "populate_player_styles", "LegendaryArmour_PopulatePlayerStyles", function(self, data)
	for item_index, item_data in pairs(data) do
		if ( type(item_data) == "table" and item_data.name and item_data.name:sub(1, 4) == "las_" ) then
			item_data.name_localized = "[LAS] " .. item_data.name_localized

			local player_style_data = tweak_data.blackmarket.player_styles[item_data.name]
			local icon_name = item_data.name:sub(5, -1)

			local guis_catalog = "guis/"
			bundle_folder = player_style_data.texture_bundle_folder

			if bundle_folder then
				guis_catalog = guis_catalog .. "dlcs/" .. tostring(bundle_folder) .. "/"
			end

			item_data.bitmap_texture = guis_catalog .. "armor_skins/" .. icon_name
		end
	end
end)

Hooks:PostHook(BlackMarketGui, "populate_suit_variations", "eeeepopulate_suit_variations", function(self, data)
	for item_index, item_data in pairs(data) do
		if ( type(item_data) == "table" and item_data.name_localized )then
			log(tostring(item_data.name_localized) .. " - " .. tostring(item_data.bitmap_texture))
		end
	end
end)