Hooks:PostHook(LocalizationManager, "text", "text_less_pagers", function(self, string_id, arg)
	if string_id == "menu_cs_modifier_pagers" then
		return string.format("Decrease pager response time by %d seconds",arg.count*2)
	end
	return Hooks:GetReturn()
end)
