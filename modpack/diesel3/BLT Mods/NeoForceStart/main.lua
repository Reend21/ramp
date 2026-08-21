--load_mode: 0 = host only, 1 = ready only, 2 = everyone
--2 (everyone) is the default value because the function hooks also run whenever all lobby members ready up normally.
local load_mode = 2

--Checks if a player is spamming the ready button, optionally adds a ready to the player's ready-up history
local function isForceStarting(peer, addReady)
	local peer_readies = peer._better_force_start_mod_readies or {}
	peer._better_force_start_mod_readies = peer_readies


	local now = os.time()
	for i, v in pairs(peer_readies) do
		if v < now - 5 then
			peer_readies[i] = nil
		end
	end
	if addReady then
		table.insert(peer_readies, 1, now)
	end
	if #peer_readies > 4 then
		return true
	end
end

--Custom function that returns a boolean based on whether or not a particular client should be allowed to spawn
local function shouldSuppressLoading(peer)
	if peer._id == managers.network:session():local_peer()._id then
		--TODO: this code never runs
		return true
	end
	if not peer:synched() then
		return true
	end
	local is_ready = peer:waiting_for_player_ready() or isForceStarting(peer, false)
	return (is_ready and 1 or 0) + load_mode <= 1
end

local send_to_peers_synched = assert(BaseNetworkSession.send_to_peers_synched)
BaseNetworkSession.send_to_peers_synched = function(self, ...)
	--Hijacking control flow from this line: https://github.com/steam-test1/Payday-2-LuaJIT-Complete/blob/a3180fc0139b474f67eeb4ecae7a665ab0809542/lib/states/ingamewaitingforplayers.lua#L75
	--If said line were to execute normally, all suppressed clients would receive a black loading screen forever.
	--From this point we can flag clients that should not be spawned for later, and prevent sending them the loading screen packet. We also toggle on the host's ready button.
	if debug.getinfo(2, "f").func == IngameWaitingForPlayersState._start then
		for peer_id, peer in pairs(self._peers) do
			--Flag clients that should not be spawned for later
			local suppressLoading = shouldSuppressLoading(peer)
			peer._better_force_start_mod_suppress_loading = suppressLoading
			if suppressLoading then
			else
				peer:send_queued_sync(...)
			end
		end
		return managers.menu_component._mission_briefing_gui:on_ready_pressed(true) --Effectively presses the ready button, otherwise you will appear as unready despite being in the game
	end
	return send_to_peers_synched(self, ...)
end

local spawn_unit = assert(NetworkPeer.spawn_unit)
NetworkPeer.spawn_unit = function(self, ...)
	--Check if this client has been flagged by us to not spawn and only spawn them if the flag is unset.
	if self._better_force_start_mod_suppress_loading then
		local _, waitingRoomEnabled = pcall(function() return MenuHelper:GetMenu("better_force_start_settings"):item("better_force_start_settings_prompt"):value() == "on" end)
		if self ~= managers.network:session():local_peer() then
			if waitingRoomEnabled and self:waiting_for_player_ready() then
				self:make_waiting()
			else
				--These two commands reload suppressed clients' mission briefing GUIs, forcing them to the unready status and disabling their non-functional preplanning GUI
				--This has to be done after skipping or listening to the start-of-heist contractor dialog, otherwise a client can ready up during it and not spawn in until after it's completed and they have manually unreadied and readied again.
				--It is worth noting that these are just packets and the host will not add these clients to the WaitManager.
				self:send_queued_sync("set_waiting")
				self:send_queued_sync("kick_to_briefing")
			end
		end
	else
		return spawn_unit(self, ...)
	end
	--The flag must be unset, otherwise eventually dropping in will not succeed.
	self._better_force_start_mod_suppress_loading = nil
end

--Needs to be its own function to prevent infinite loading screen
local function force_start_without_host()
	local session = managers.network:session()
	session:local_peer()._better_force_start_mod_suppress_loading = true

	--Disable the fade-out when a client force-starts the heist
	local play_effect = OverlayEffectManager.play_effect
	OverlayEffectManager.play_effect = function(self, ...)
		local effect = ...
		if effect == tweak_data.overlay_effects.fade_out_permanent then
			return
		end
		return play_effect(self, ...)
	end

	Hooks:PreHook(MissionBriefingGui, "on_ready_pressed", "better_force_start_pre_ready_pressed", function(self, ready)
		--Entering the preplanning menu for example will trigger this function, only when ready is nil will the source of the call actually be clicking the button
		if ready ~= nil then
			return
		end
		local session = managers.network:session()
		local local_peer = session:local_peer()
		local local_character = local_peer:character()
		local is_drop_in = true
		spawn_unit(local_peer, session:_get_next_spawn_point_id(), is_drop_in, local_character ~= "random" and local_character)
	end)

	local state = game_state_machine:current_state()

	for peer_id, peer in pairs(session._peers) do
		--Flag clients that should not be spawned for later. We have this functionality in the send_to_peers_synched hook, but the hook does not run because we skipped the _start function in order to keep the host in the briefing menu.
		local suppressLoading = shouldSuppressLoading(peer)
		peer._better_force_start_mod_suppress_loading = suppressLoading
	end

	--Applying assets bought in the briefing stage. Once again this was skipped with _start
	
	if managers.preplanning:has_current_level_preplanning() then
		managers.preplanning:execute_reserved_mission_elements()
	end
	managers.assets:check_triggers("asset")
	

	state:sync_start()
	local variant = managers.groupai:state():blackscreen_variant() or 0
	session:send_to_peers_synched("sync_waiting_for_player_start", variant, Global.music_manager.current_track, Global.music_manager.current_music_ext or "")

	local gui = managers.menu_component._mission_briefing_gui
	gui._items[2]._preplanning_ready = false
	gui:set_enabled(true)
	state._blackscreen_started = false
end

--The start function that gets exposed to the menu code
function _G.better_force_start(mode, leaveHostBehind)
	local state = game_state_machine:current_state()
	if LuaNetworking:IsMultiplayer() and LuaNetworking:IsHost() and game_state_machine:current_state_name() == "ingame_waiting_for_players" and not state._starting_game_intro then
		--Important to only set load_mode when the game is actually going to load, since it does not get reset until you enter a loading screen.
		load_mode = mode
		if leaveHostBehind then
			force_start_without_host()
		else
			state:start_game_intro()
		end
	end
end

--Ready-up hook to check for ready spam
Hooks:PostHook(HostNetworkSession, "on_set_member_ready", "better_force_start_client_ready_up", function(self, peer_id, is_ready, changed, from_network)
	local peer = self:peer(peer_id)
	local isHost = peer == self:local_peer()


	if changed and is_ready and isForceStarting(peer, true) then
		if peer == self:local_peer() then
			local menuValue = MenuHelper:GetMenu("better_force_start_settings"):item("better_force_start_settings_enter_mode_selector"):value()
			if menuValue ~= 4 then
				--For no particular reason, I listed the multiple choice menu options for this setting in reverse compared to the actual load_mode variable, hence the following math:
				_G.better_force_start(math.abs(menuValue - 3))
			end

		else
			local menuValue = MenuHelper:GetMenu("better_force_start_settings"):item("better_force_start_settings_client"):value()
			if menuValue ~= 3 then
				local load_mode = -(menuValue - 3)
				_G.better_force_start(load_mode, load_mode == 1 and not self:local_peer():waiting_for_player_ready())
			end
		end
	end
end)
