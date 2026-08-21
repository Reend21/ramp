Hooks:OverrideFunction(ModifierLessPagers, "init", function (self, data)
	ModifierLessPagers.super.init(self, data)
	local time = 6 - self:value()
	tweak_data.player.alarm_pager.call_duration = {{time,time},{time,time}}

	--i am forever thankful for this
	if EHIPagerTracker then
		EHIPagerTracker._forced_time = time*2
	end
	if EHIPagerWaypoint then
		EHIPagerWaypoint._forced_time = time*2
	end
end)
