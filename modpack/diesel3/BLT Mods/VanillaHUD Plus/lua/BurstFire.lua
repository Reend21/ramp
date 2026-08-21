if Global.load_level == true and Global.game_settings.level_id == "modders_devmap" then
	return
end
if _G.IS_VR then
	return
end
if ChallengesManagerRes then
	return
end

if not VHUDPlus:getSetting({"EQUIPMENT", "ENABLE_BURSTMODE"}, true) then
	return
end

if RequiredScript == "lib/units/weapons/newraycastweaponbase" then

	local ids_single = Idstring("single")
	local ids_auto = Idstring("auto")
	local ids_burst = Idstring("burst")
	local ids_volley = Idstring("volley")

	local init_original = NewRaycastWeaponBase.init

	-- From Burst Fire Standalone by Offyerrocker
	function NewRaycastWeaponBase:init(unit)
		init_original(self, unit)

		local td = self:weapon_tweak_data()

		local fire_mode_data = td.fire_mode_data or {}
		local toggable_fire_modes = fire_mode_data.toggable
		if self._toggable_fire_modes and toggable_fire_modes then
			if not table.contains(self._toggable_fire_modes,ids_burst) then
				table.insert(self._toggable_fire_modes,ids_burst)
			end
		end
	end

	local orig_toggle_firemode = Hooks:GetFunction(NewRaycastWeaponBase,"toggle_firemode")
	Hooks:OverrideFunction(NewRaycastWeaponBase, "toggle_firemode", function(self, skip_post_event, ...)
		local can_toggle = not self._locked_fire_mode and self:can_toggle_firemode()

		if can_toggle then
			if self._toggable_fire_modes then
				local cur_fire_mode = table.index_of(self._toggable_fire_modes, self._fire_mode)

				if cur_fire_mode > 0 then
					cur_fire_mode = cur_fire_mode % #self._toggable_fire_modes + 1
					self._fire_mode = self._toggable_fire_modes[cur_fire_mode]

					if not skip_post_event then
						self._sound_fire:post_event(cur_fire_mode % 2 == 0 and "wp_auto_switch_on" or "wp_auto_switch_off")
					end

					local fire_mode_data = self._fire_mode_data[self._fire_mode:key()]
					local fire_effect = fire_mode_data and (self._silencer and fire_mode_data.muzzleflash_silenced or fire_mode_data.muzzleflash)

					self:change_fire_effect(fire_effect)

					local trail_effect = fire_mode_data and fire_mode_data.trail_effect

					self:change_trail_effect(trail_effect)
					self:call_on_digital_gui("set_firemode", self:fire_mode())
					self:update_firemode_gui_ammo()

					return true
				end

				return false
			end

			if self._fire_mode == ids_single then
				self._fire_mode = ids_burst

				if not skip_post_event then
					self._sound_fire:post_event("wp_auto_switch_on")
				end
			elseif self._fire_mode == ids_burst then
				self._fire_mode = ids_auto
				if not skip_post_event then
					self._sound_fire:post_event("wp_auto_switch_on")
				end
			else
				self._fire_mode = ids_single

				if not skip_post_event then
					self._sound_fire:post_event("wp_auto_switch_off")
				end
			end

			return true
		elseif self._alt_fire_data then
				self._alt_fire_active = not self._alt_fire_active

				if self._alt_fire_data.shell_ejection then
					self._shell_ejection_effect = Idstring(self._alt_fire_active and self._alt_fire_data.shell_ejection or self:weapon_tweak_data().shell_ejection or "effects/payday2/particles/weapons/shells/shell_556")
					self._shell_ejection_effect_table = {
						effect = self._shell_ejection_effect,
						parent = self._obj_shell_ejection
					}
				end

				if not skip_post_event then
					self._sound_fire:post_event(self._alt_fire_active and "wp_auto_switch_on" or "wp_auto_switch_off")
				end

				self:update_damage()

				return true
			end

		return orig_toggle_firemode(self,skip_post_event,...)
	end)

elseif RequiredScript == "lib/units/weapons/akimboweaponbase" then

	local ids_single = Idstring("single")
	local ids_auto = Idstring("auto")
	local ids_burst = Idstring("burst")
	local ids_volley = Idstring("volley")

	local init_ak_original = AkimboWeaponBase.init

	-- From Burst Fire Standalone by Offyerrocker
	function AkimboWeaponBase:init(unit)
		init_ak_original(self, unit)

		local td = self:weapon_tweak_data()

		local fire_mode_data = td.fire_mode_data or {}
		local toggable_fire_modes = fire_mode_data.toggable
		if self._toggable_fire_modes and toggable_fire_modes then
			if not table.contains(self._toggable_fire_modes,ids_burst) then
				table.insert(self._toggable_fire_modes,ids_burst)
			end
		end
	end

	local orig_ak_toggle_firemode = Hooks:GetFunction(AkimboWeaponBase,"toggle_firemode")
	Hooks:OverrideFunction(AkimboWeaponBase, "toggle_firemode", function(self, skip_post_event, ...)
		local can_toggle = not self._locked_fire_mode and self:can_toggle_firemode()

		if can_toggle then
			if self._toggable_fire_modes then
				local cur_fire_mode = table.index_of(self._toggable_fire_modes, self._fire_mode)

				if cur_fire_mode > 0 then
					cur_fire_mode = cur_fire_mode % #self._toggable_fire_modes + 1
					self._fire_mode = self._toggable_fire_modes[cur_fire_mode]

					if not skip_post_event then
						self._sound_fire:post_event(cur_fire_mode % 2 == 0 and "wp_auto_switch_on" or "wp_auto_switch_off")
					end

					local fire_mode_data = self._fire_mode_data[self._fire_mode:key()]
					local fire_effect = fire_mode_data and (self._silencer and fire_mode_data.muzzleflash_silenced or fire_mode_data.muzzleflash)

					self:change_fire_effect(fire_effect)

					local trail_effect = fire_mode_data and fire_mode_data.trail_effect

					self:change_trail_effect(trail_effect)
					self:call_on_digital_gui("set_firemode", self:fire_mode())
					self:update_firemode_gui_ammo()

					return true
				end

				return false
			end

			if self._fire_mode == ids_single then
				self._fire_mode = ids_burst

				if not skip_post_event then
					self._sound_fire:post_event("wp_auto_switch_on")
				end
			elseif self._fire_mode == ids_burst then
				self._fire_mode = ids_auto
				if not skip_post_event then
					self._sound_fire:post_event("wp_auto_switch_on")
				end
			else
				self._fire_mode = ids_single

				if not skip_post_event then
					self._sound_fire:post_event("wp_auto_switch_off")
				end
			end

			return true
		elseif self._alt_fire_data then
				self._alt_fire_active = not self._alt_fire_active

				if self._alt_fire_data.shell_ejection then
					self._shell_ejection_effect = Idstring(self._alt_fire_active and self._alt_fire_data.shell_ejection or self:weapon_tweak_data().shell_ejection or "effects/payday2/particles/weapons/shells/shell_556")
					self._shell_ejection_effect_table = {
						effect = self._shell_ejection_effect,
						parent = self._obj_shell_ejection
					}
				end

				if not skip_post_event then
					self._sound_fire:post_event(self._alt_fire_active and "wp_auto_switch_on" or "wp_auto_switch_off")
				end

				self:update_damage()

				return true
			end

		return orig_ak_toggle_firemode(self,skip_post_event,...)
	end)

	-- --Override
	-- function AkimboWeaponBase:toggle_firemode()
	-- 	self._manual_fire_second_gun = not self._manual_fire_second_gun
	-- end


elseif RequiredScript == "lib/managers/hudmanagerpd2" then

	HUDManager._USE_BURST_MODE = true	--Custom HUD compatibility

	HUDManager.set_teammate_weapon_firemode_burst = HUDManager.set_teammate_weapon_firemode_burst or function(self, id)
		self._teammate_panels[HUDManager.PLAYER_PANEL]:set_weapon_firemode_burst(id)
	end

elseif RequiredScript == "lib/managers/hud/hudteammate" then

	--Default function for vanilla HUD. If using a custom HUD that alters fire mode HUD components, make sure to implement this function in it
	HUDTeammate.set_weapon_firemode_burst = HUDTeammate.set_weapon_firemode_burst or function(self, id)
		local is_secondary = id == 1
		local secondary_weapon_panel = self._player_panel:child("weapons_panel"):child("secondary_weapon_panel")
		local primary_weapon_panel = self._player_panel:child("weapons_panel"):child("primary_weapon_panel")
		local weapon_selection = is_secondary and secondary_weapon_panel:child("weapon_selection") or primary_weapon_panel:child("weapon_selection")
		if alive(weapon_selection) then
			local firemode_single = weapon_selection:child("firemode_single")
			local firemode_auto = weapon_selection:child("firemode_auto")
			if alive(firemode_single) and alive(firemode_auto) then
				firemode_single:show()
				firemode_auto:show()
			end
		end
	end

end