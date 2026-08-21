local bags_to_hide = {
	Idstring("g_toolbag"),
	Idstring("g_ammobag"),
	Idstring("g_medicbag"),
	Idstring("g_sentrybag"),
	Idstring("g_toolbag"),
	Idstring("g_armorbag"),
	Idstring("g_firstaidbag"),
	Idstring("g_bodybagsbag")
}

Hooks:PostHook(CriminalsManager, "set_beardlib_character_visual_state", "LegendaryArmour_CharacterVisualState", function(unit, character_name, visual_state)
	local is_local_peer = visual_state.is_local_peer
	local visual_seed = visual_state.visual_seed
	local player_style = visual_state.player_style
	local suit_variation = visual_state.suit_variation
	local glove_id = visual_state.glove_id
	local mask_id = visual_state.mask_id
	local armor_id = visual_state.armor_id
	local armor_skin = visual_state.armor_skin

	if not alive(unit) then
		return
	end

	if _G.IS_VR and unit:camera() then
		return
	end

	-- Gotta catch it before we move to the camera unit.
	local unit_inventory = unit:inventory()

	if unit:camera() and alive(unit:camera():camera_unit()) and unit:camera():camera_unit():damage() then
		unit = unit:camera():camera_unit()
	end

	local unit_damage = unit:damage()

	if not unit_damage then
		return
	end

	local function run_sequence_safe(sequence, sequence_unit)
		if not sequence then
			return
		end

		local sequence_unit_damage = (sequence_unit or unit):damage()

		if sequence_unit_damage and sequence_unit_damage:has_sequence(sequence) then
			sequence_unit_damage:run_sequence_simple(sequence)
		end
	end

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

	local body_replacement = get_value("body_replacement", {})
	local replace_deployable = body_replacement.deployable
	local replace_mask = body_replacement.mask

	if replace_mask then
		local mask_on_sequence = managers.blackmarket:character_mask_on_sequence_by_character_name(character_name)
		run_sequence_safe(mask_on_sequence)

		if unit_inventory then
			unit_inventory.las_force_hide_mask = true
		end
	else
		local mask_data = tweak_data.blackmarket.masks[mask_id]

		if not is_local_peer and mask_data then
			if mask_data.skip_mask_on_sequence then
				local mask_off_sequence = managers.blackmarket:character_mask_off_sequence_by_character_name(character_name)

				run_sequence_safe(mask_off_sequence)
			else
				local mask_on_sequence = managers.blackmarket:character_mask_on_sequence_by_character_name(character_name)

				run_sequence_safe(mask_on_sequence)
			end
		end
	end

	if managers.menu_scene then
		local owner_key = unit:key()
		local mask = managers.menu_scene._mask_units[owner_key]
		managers.menu_scene.go_away_masks[owner_key] = replace_mask

		if mask and alive(mask.mask_unit) then
			if replace_mask then
				mask.mask_unit:set_visible(false)
				for _, linked_unit in ipairs(mask.mask_unit:children()) do
					linked_unit:set_visible(false)
				end
			else
				mask.mask_unit:set_visible(true)
				for _, linked_unit in ipairs(mask.mask_unit:children()) do
					linked_unit:set_visible(true)
				end
			end
		end
	end

	if replace_deployable then
		for _, object_ids in pairs(bags_to_hide) do
			local object = unit:get_object(object_ids)
			if object then
				object:set_visibility(false)
			end
		end

		if unit:movement() then
			unit:movement().las_force_hide_deployable = true
		end
	end

	if unit:spawn_manager() then
		local spawn_man = unit:spawn_manager()

		for unit_id, unit_data in pairs(spawn_man:spawned_units()) do
			if unit_id:sub(1, 10) == "char_mesh_" then
				spawn_man:remove_unit(unit_id)
			end
		end

		local extra_units = get_value("extra_units")
		if extra_units then
			local unit_enabled = unit:enabled()

			for index_1, unit_stuff in pairs(extra_units) do
				if type(index_1) == "number" then
					local unit_id = "char_mesh_" .. tostring(index_1)
					spawn_man:spawn_and_link_unit("_char_joint_names", unit_id, tostring(unit_stuff))
					spawn_man:get_unit(unit_id):set_enabled(unit_enabled)
				elseif type(index_1) == "string" and index_1:sub(1, 1) ~= "_" then
					if type(unit_stuff) == "string" then
						local unit_id = "char_mesh_" .. tostring(index_1)
						spawn_man:spawn_unit(unit_id, tostring(index_1), tostring(unit_stuff))
						spawn_man:get_unit(unit_id):set_enabled(unit_enabled)
					elseif type(unit_stuff) == "table" then
						for index_2, unit_string in pairs(unit_stuff) do
							if index_2:sub(1, 1) ~= "_" then
								local unit_id = "char_mesh_" .. tostring(index_1) .. "_" .. tostring(index_2)
								spawn_man:spawn_unit(unit_id, tostring(index_1), tostring(unit_string))
								spawn_man:get_unit(unit_id):set_enabled(unit_enabled)
							end
						end
					end
				end
			end
		end
	end
end)