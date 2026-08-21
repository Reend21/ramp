Hooks:PreHook(PlayerStandard, "_enter", "LegendaryArmour_GoAwayFPSMask", function(self, enter_data)
	if not self._state_data.mask_equipped and self._unit and self._ext_inventory and self._ext_inventory.las_force_hide_mask then
		enter_data = enter_data or {}
		enter_data.skip_equip = true
	end
end)

Hooks:PostHook(PlayerStandard, "_enter", "LegendaryArmour_GoAwayFPSMaskAnim", function(self, enter_data)
	if not self._state_data.mask_equipped and enter_data and enter_data.skip_equip == true then
		self._camera_unit:base().spawn_mask = function() end

		self._camera_unit:anim_state_machine():set_global("tiara_equip", 1)
		self:_start_action_equip(self:get_animation("mask_equip"), 1.6)

		self._state_data.mask_equipped = true
	end
end)