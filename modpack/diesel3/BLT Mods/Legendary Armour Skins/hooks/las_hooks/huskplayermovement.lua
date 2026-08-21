HuskPlayerMovement.las_force_hide_deployable = false
Hooks:PostHook(HuskPlayerMovement, "set_visual_deployable_equipment", "LegendaryArmour_SetVisDepEquip", function(self, deployable, amount)
	if amount > 0 and self.las_force_hide_deployable then
		self:set_visual_deployable_equipment(deployable, 0)
	end
end)