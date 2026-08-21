PlayerInventory.las_force_hide_mask = false
Hooks:PostHook(PlayerInventory, "set_mask_visibility", "LegendaryArmour_SetMaskVisibility", function(self, state)
	if self.las_force_hide_mask and self._mask_unit and alive(self._mask_unit) then
		self._mask_unit:set_visible(false)
	end
end)