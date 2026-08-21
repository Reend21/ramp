local orig_BlackMarketGui_equip_weapon_cosmetics_callback = BlackMarketGui.equip_weapon_cosmetics_callback
function BlackMarketGui:equip_weapon_cosmetics_callback(data)
	if self._item_bought then
		return
	end

	--Hijack and show our menu if more than one skin owned
	local skin_id = data.cosmetic_id
	if not data._hds_done and HideDupeSkins:get_choice_name("hds_auto_mode") == "prompt" then
		if skin_id and HideDupeSkins.db[skin_id] and HideDupeSkins.db[skin_id].count then
			if HideDupeSkins.db[skin_id].count > 1 then
				HideDupeSkins:dialog_ask(data)
				return
			end
		end
	end

	--When we remove a non-autochoice skin, the GUI doesn't update
	--So switch to the autochoice one if we re-equip it before reloading
	if HideDupeSkins:get_choice_name("hds_auto_mode") ~= "prompt" then
		if skin_id and HideDupeSkins.show[skin_id] then
			data.name = HideDupeSkins.show[skin_id]
		end
	end

	orig_BlackMarketGui_equip_weapon_cosmetics_callback(self, data)
	data._hds_done = nil
end

--Note: populate_weapon_cosmetics is called when equipping skins but not when removing
Hooks:PreHook(BlackMarketGui, "populate_weapon_cosmetics", "HideDupeSkins-PreHook-BlackMarketGui:populate_weapon_cosmetics", function(self, data, ...)
	local instances = data.on_create_data and data.on_create_data.instances or {}
	if #instances == 0 then
		return
	end

	local crafted = managers.blackmarket:get_crafted_category(data.category)[data.prev_node_data and data.prev_node_data.slot]
	local crafted_instance_id = crafted and crafted.cosmetics and crafted.cosmetics.instance_id
	if not crafted_instance_id then
		return
	end

	local equipped_skin_id = crafted.cosmetics.id
	for k, v in ipairs(instances) do
		local instance_skin_id = managers.blackmarket:get_inventory_tradable()[v].entry
		if equipped_skin_id == instance_skin_id then
			--Switch instance to whatever is equipped
			instances[k] = crafted_instance_id
			break
		end
	end
end)

local function head_match(check, head)
	return head == string.sub(check, 1, string.len(head))
end

local function tail_match(check, tail)
	return tail == string.sub(check, string.len(check) - string.len(tail) + 1)
end

--Add icons after weapon cosmetics have been populated
Hooks:PostHook(BlackMarketGui, "populate_weapon_cosmetics", "HideDupeSkins-PostHook-BlackMarketGui:populate_weapon_cosmetics", function(self, data, ...)
	--Don't show icons if not using prompt mode
	if HideDupeSkins:get_choice_name("hds_auto_mode") ~= "prompt" then
		return
	end

	for _, v in ipairs(data) do
		local skin_id = v.cosmetic_id
		if skin_id and HideDupeSkins.db[skin_id] and HideDupeSkins.db[skin_id].count then
			local count = HideDupeSkins.db[skin_id].count
			if count > 1 then
				v.mini_icons = v.mini_icons or {}
				--No bonus, and we own a stat boosted version
				if not v.cosmetic_bonus and HideDupeSkins.stat[skin_id] then
					local skin_bonus = tweak_data.blackmarket.weapon_skins[skin_id].bonus
					local stat_boost = skin_bonus ~= "team_exp_money_p3"
					local team_boost = (skin_bonus == "team_exp_money_p3") or (tail_match(skin_bonus, "_tem_p1"))

					if stat_boost then
						table.insert(v.mini_icons, {
							layer = 1,
							bottom = 0,
							right = #v.mini_icons * 17,
							w = 16,
							h = 16,
							texture= "guis/textures/pd2/blackmarket/inv_mod_bonus_stats",
							alpha = 0.35,
							name = "hef_bonus",
							stream = false,
						})
					end
					if team_boost then
						table.insert(v.mini_icons, {
							layer = 1,
							bottom = 0,
							right = #v.mini_icons * 17,
							w = 16,
							h = 16,
							texture= "guis/textures/pd2/blackmarket/inv_mod_bonus_team",
							alpha = 0.35,
							name = "hef_bonus",
							stream = false,
						})
					end
				end

				--Display number owned
				table.insert(v.mini_icons, {
					layer = 1,
					top = 0,
					right = (count > 9 and -1) or -7,
					w = 18,
					h = 18,
					text = tostring(count),
					color = Color.white,
					blend_mode = "add",
				})
			end
		end
	end
end)
