local jss = JoiningScreenSelector.settings

Hooks:PostHook(HUDManager, "init", "JSS_HUDManager", function(self)
	self._jss_id = nil
	
	if Network:is_server() and jss.operate_type == 2 then
		self._controller:add_trigger("drop_in_accept", callback(MenuManager, MenuManager, "jss_on_joining_screen_kick", "2"))
		self._controller:add_trigger("drop_in_return", callback(MenuManager, MenuManager, "jss_on_joining_screen_kick", "0"))
		self._controller:add_trigger("drop_in_kick", callback(MenuManager, MenuManager, "jss_on_joining_screen_kick", "6"))
	elseif not Network:is_server() and jss.operate_type == 2 then
	    self._controller:add_trigger("drop_in_accept", callback(MenuManager, MenuManager, "jss_end_game_instant", "-999"))
	end
end)

function HUDManager:updater_jss_peer_id(peer_id)
	self._jss_id = peer_id
end

function HUDManager:jss_peer_id(peer_id)
	return self._jss_id
end