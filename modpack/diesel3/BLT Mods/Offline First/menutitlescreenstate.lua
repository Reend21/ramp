Hooks:PostHook(MenuTitlescreenState, "update", "MenuTitlescreenState_RemoveConnectingScreen", function(self)
	self._waiting_on_connection = false
	managers.perpetual_event:fetch_event()
end)