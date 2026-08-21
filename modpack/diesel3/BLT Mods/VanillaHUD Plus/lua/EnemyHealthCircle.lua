if string.lower(RequiredScript) == "lib/managers/hudmanager" then

	local _setup_player_info_hud_pd2_original = HUDManager._setup_player_info_hud_pd2
	
	function HUDManager:_setup_player_info_hud_pd2()
		_setup_player_info_hud_pd2_original(self)
		self.enemyhealth = EnemyHealthCircle:new((managers.hud:script(PlayerBase.PLAYER_INFO_HUD_PD2)))
	end
	
	function HUDManager:set_enemy_health(data)
		if self.enemyhealth then
			self.enemyhealth:set_health(data)
		end
	end
	
	function HUDManager:set_enemy_health_visible(visible)
		if self.enemyhealth then
			self.enemyhealth:set_visible(visible and not VHUDPlus:getSetting({"EnemyHealthbar", "ENABLED_ALT"}, true))
		end
	end
	
	function HUDManager:change_enemyhealthbar_setting(setting, value)
		if self.enemyhealth then
			self.enemyhealth:update_setting(setting, value)
		end
	end
	
	EnemyHealthCircle = EnemyHealthCircle or class()
	
	Color.orange = Color("FF8800")
	local enemy_hurt_color = Color.orange
	local enemy_kill_color = Color.red
	
	function EnemyHealthCircle:init(hud)
		-- self._hud_panel = hud.panel
		self._no_target = true
	
		if alive(self._circle_health_panel) then
			hud.panel:remove(self._circle_health_panel)
		end
	
		self._enemyhealthbar_settings = {
			enemy_health_size = VHUDPlus:getSetting({"EnemyHealthbar", "SCALE"}, 75) or 75,
			enemy_health_vertical_offset = VHUDPlus:getSetting({"EnemyHealthbar", "ENEMY_HEALTH_VERTICAL_OFFSET"}, 110) or 110,
			enemy_health_horizontal_offset = VHUDPlus:getSetting({"EnemyHealthbar", "ENEMY_HEALTH_HORIZONTAL_OFFSET"}, 0) or 0,
			enemy_text_size = VHUDPlus:getSetting({"EnemyHealthbar", "ENEMY_TEXT_SIZE"}, 30) or 30
		}
		
		self._circle_health_panel = hud.panel:panel({ 
			visible = true, 
			name = "circle_health_panel", 
			h = self._enemyhealthbar_settings.enemy_health_size + 20, 
			y = self._enemyhealthbar_settings.enemy_health_vertical_offset,
			valign = "top", 
			layer = 0 
		})
	
		if self._enemyhealthbar_settings.enemy_health_horizontal_offset then
			self._circle_health_panel:set_x(self._circle_health_panel:x() + self._enemyhealthbar_settings.enemy_health_horizontal_offset)
		end
	
		local enemy_health_circle_panel = self._circle_health_panel:panel({ 
			name = "enemy_health_circle_panel", 
			visible = false, 
			layer = 1, 
			w = self._enemyhealthbar_settings.enemy_health_size, 
			h = self._enemyhealthbar_settings.enemy_health_size, 
			x = self._circle_health_panel:center() - (self._enemyhealthbar_settings.enemy_health_size / 2)
		})
		enemy_health_circle_panel:set_bottom( self._circle_health_panel:h() )
		self.circle_health_panel = enemy_health_circle_panel
		
		self.circle_health = enemy_health_circle_panel:bitmap({ 
			name = "enemy_circle", 
			texture = "guis/textures/pd2/hud_health", 
			texture_rect = { 128, 0, -128, 128 }, 
			render_template = "VertexColorTexturedRadial", 
			align = "center", 
			blend_mode = "normal", 
			alpha = 1, 
			w = enemy_health_circle_panel:w(), 
			h = enemy_health_circle_panel:h(), 
			layer = 2 
		})
		self.circle_health:set_color( Color( 1, 1, 1, 1 ) )
		
		self._damage_indicator = enemy_health_circle_panel:bitmap({ 
			name = "damage_indicator", 
			texture = "guis/textures/pd2/hud_radial_rim", 
			blend_mode = "add", 
			alpha = 0, 
			w = enemy_health_circle_panel:w(), 
			h = enemy_health_circle_panel:h(), 
			layer = 1, 
			align = "center" 
		})
		self._damage_indicator:set_color( Color( 1, 1, 1, 1 ) )
	
		self._health_num = enemy_health_circle_panel:text({ 
			name = "health_num", 
			text ="", 
			layer = 5, 
			alpha = 0.9, 
			color = Color.white, 
			w = enemy_health_circle_panel:w(), 
			x = 0, 
			y = 0, 
			h = enemy_health_circle_panel:h(), 
			vertical = "center", 
			align = "center", 
			--font_size = self._adjust_text_size, 
			font = tweak_data.menu.pd2_large_font 
		})
	
		self._health_num_bg1 = enemy_health_circle_panel:text({ 
			name = "health_num_bg1",
			text ="", 
			layer = 4, 
			alpha = 0.9, 
			color = Color.black, 
			w = enemy_health_circle_panel:w(), 
			x = 0, 
			y = 0, 
			h = enemy_health_circle_panel:h(), 
			vertical = "center", 
			align = "center", 
			--font_size = self._adjust_text_size, 
			font = tweak_data.menu.pd2_large_font 
		})
		
		self._health_num_bg2 = enemy_health_circle_panel:text({ 
			name = "health_num_bg2", 
			text ="", 
			layer = 1, 
			alpha = 0.9, 
			color = Color.black, 
			w = enemy_health_circle_panel:w(), 
			x = 0, 
			y = 0, 
			h = enemy_health_circle_panel:h(), 
			vertical = "center", 
			align = "center", 
			--font_size = self._adjust_text_size, 
			font = tweak_data.menu.pd2_large_font 
		})
	
		self._health_num_bg3 = enemy_health_circle_panel:text({ 
			name = "health_num_bg3", 
			text ="", 
			layer = 1, 
			alpha = 0.9, 
			color = Color.black, 
			w = enemy_health_circle_panel:w(), 
			x = 0, 
			y = 0, 
			h = enemy_health_circle_panel:h(), 
			vertical = "center", 
			align = "center", 
			--font_size = self._adjust_text_size, 
			font = tweak_data.menu.pd2_large_font 
		})
	
		self._health_num_bg4 = enemy_health_circle_panel:text({ 
			name = "health_num_bg4", 
			text ="", 
			layer = 1, 
			alpha = 0.9, 
			color = Color.black, 
			w = enemy_health_circle_panel:w(), 
			x = 0, 
			y = 0, 
			h = enemy_health_circle_panel:h(), 
			vertical = "center", 
			align = "center", 
			--font_size = self._adjust_text_size, 
			font = tweak_data.menu.pd2_large_font 
		})
		self._health_num_bg1:set_y(self._health_num_bg1:y() - 1)
		self._health_num_bg1:set_x(self._health_num_bg1:x() - 1)
		self._health_num_bg2:set_y(self._health_num_bg2:y() + 1)
		self._health_num_bg2:set_x(self._health_num_bg2:x() + 1)
		self._health_num_bg3:set_y(self._health_num_bg3:y() + 1)
		self._health_num_bg3:set_x(self._health_num_bg3:x() - 1)
		self._health_num_bg4:set_y(self._health_num_bg4:y() - 1)
		self._health_num_bg4:set_x(self._health_num_bg4:x() + 1)
	end
	
	function EnemyHealthCircle:set_health(data)
	
		if not data or not data.current or not data.total then
			return
		end
	
		local current_health = math.max(data.current, 0)
		local current, data_number
	
		local setting = true
		if setting and current_health >= 10^6 then
			current = current_health / 1000000 / 1
			string.sub(current,0,string.sub(current,-1) == "0" and -3 or -1)
			self._health_num:set_font_size(24)
			for i = 1, 4 do
				self["_health_num_bg" .. i]:set_font_size(2.5)
			end
			K = "M"
		elseif setting and current_health > 999 then
			current = current_health / 1000
			self._health_num:set_font_size(27.5)
			for i = 1, 4 do
				self["_health_num_bg" .. i]:set_font_size(27)
			end
			K = "K"
		else
			current = current_health
			self._health_num:set_font_size(30)
			for i = 1, 4 do
				self["_health_num_bg" .. i]:set_font_size(30)
			end
			K = ""
		end
	
		if setting and current_health >= 10^6 then
			data_number = "%.1f"
		elseif setting and current_health > 999 and current_health < 10000 then 
			data_number = "%.1f"
		else
			data_number = "%.0f"
		end
	
		if current_health / data.total < self.circle_health:color().red then
			self._damage_was_fatal = current_health / data.total <= 0 and true or false
			self:_damage_taken()
		end
	
		self.circle_health:set_color(Color(1, current_health / data.total, 1, 1))
		if not (current_health <= 0) or not "" then
		end
	
		self._health_num:set_text((string.format(setting and data_number, current) .. K ))
		for i = 1, 4 do
			self["_health_num_bg" .. i]:set_text((string.format(setting and data_number, current) .. K ))
		end
	end
	
	function EnemyHealthCircle:set_visible(visible)
		if self._no_target then
			if visible and VHUDPlus:getSetting({"EnemyHealthbar", "ENABLED"}, true) then
				self._no_target = false
				self.circle_health_panel:set_visible(true)
			end
		else
			if not visible then
				self._no_target = true
				self.circle_health_panel:animate(callback(self, self, "_animate_hide_decay"))
			end
		end
	end
	
	function EnemyHealthCircle:_animate_hide_decay(enemy_circle)
		local fadeout = 1.5
		local t = fadeout
		while t > 0  and self._no_target do
			local dt = coroutine.yield()
			t = t - dt
			enemy_circle:set_alpha( t/fadeout )
		end
		if self._no_target then
			enemy_circle:set_visible(false)
		end
		enemy_circle:set_alpha( 1 )
	end
	
	function EnemyHealthCircle:_damage_taken()
		self._damage_indicator:stop()
		self._damage_indicator:animate( callback( self, self, "_animate_damage_taken" ) )
	end
	
	function EnemyHealthCircle:_animate_damage_taken(damage_indicator)
		self:__animate_damage_taken(self._damage_was_fatal, damage_indicator)
	end
	
	function EnemyHealthCircle:__animate_damage_taken(killershot, damage_indicator)
		damage_indicator:set_alpha( 1 )
		local st = 1.5
		local t = st
		local st_red_t = 0.5
		local red_t = st_red_t
		local killcolor = VHUDPlus:getColorSetting({"EnemyHealthbar", "ENEMY_KILL_COLOR"}, "red")
		local hurtcolor = VHUDPlus:getColorSetting({"EnemyHealthbar", "ENEMY_HURT_COLOR"}, "orange")
		while t > 0 do
			local dt = coroutine.yield()
			t = t - dt
			red_t = math.clamp( red_t - dt, 0, 1 )
			local c = red_t/st_red_t
			local setcolor = killershot and Color(c + killcolor.r, c + killcolor.g, c + killcolor.b) or Color(c + hurtcolor.r, c + hurtcolor.g, c + hurtcolor.b)
			damage_indicator:set_color( setcolor )
			damage_indicator:set_alpha( t/st )
		end
		damage_indicator:set_alpha( 0 )
	end
	
	function EnemyHealthCircle:update_setting(setting, value)
		if self._enemyhealthbar_settings[setting] ~= value then
			self._enemyhealthbar_settings[setting] = value
		end
		if self._circle_health_panel then
		--	self._stats_panel:clear()
		--	self:_create_stat_list(self._stats_panel)
		end
	end
	
	elseif string.lower(RequiredScript) == "lib/units/beings/player/states/playerstandard" then
		-- local show_multiplied_enemy_health = VHUDPlus:getSetting({"EnemyHealthbar", "SHOW_MULTIPLIED_ENEMY_HEALTH"}, true)
		local _update_fwd_ray_ori = PlayerStandard._update_fwd_ray
	
		Hooks:PostHook( PlayerStandard , "_update_fwd_ray" , "WolfHUDCirclePostPlayerStandardUpdate" , function( self , t , dt )
			if self._fwd_ray and self._fwd_ray.unit and type(self._fwd_ray.unit) == "userdata" then
					local unit = self._fwd_ray.unit
					if unit:in_slot( 8 ) and alive(unit:parent()) then -- Fix when aiming at shields shield.
						unit = unit:parent()
					end
					
					if VHUDPlus:getSetting({"EnemyHealthbar", "IGNORE_CIVILIAN_HEALTH"}, true) and managers.enemy:is_civilian(unit) then
						return
					end
					if VHUDPlus:getSetting({"EnemyHealthbar", "IGNORE_TEAM_AI_HEALTH"}, true) and unit:in_slot(16) then
						return
					end
					
					local visible, name, name_id, health, max_health, shield
					if alive( unit ) then
						if alive( unit ) and unit:in_slot( 25 ) and unit:character_damage() and not unit:character_damage():dead() then
							self._last_unit = nil
							visible = true
							local repair_check = unit:character_damage():needs_repair()
							if not repair_check then
								shield = true
								managers.hud:set_enemy_health({
									current = (unit:character_damage()._shield_health or 0) * 10,
									total = (unit:character_damage()._SHIELD_HEALTH_INIT or 0) * 10
								})
							else
								managers.hud:set_enemy_health({
									current = (unit:character_damage()._health or 0) * 10,
									total = (unit:character_damage()._HEALTH_INIT or 0) * 10
								})
							end
						elseif alive( unit ) and ( unit:in_slot( 12 ) or ( unit:in_slot( 21 ) or unit:in_slot( 22 ) ) or unit:in_slot( 16 )) and not unit:character_damage():dead() then
							self._last_unit = unit
							visible = true
							managers.hud:set_enemy_health({
									current = (unit:character_damage()._health or 0) * 10,
									total = (unit:character_damage()._HEALTH_INIT or 0) * 10
							})
	
						elseif alive( unit ) and unit:in_slot( 39 ) and VHUDPlus:getSetting({"EnemyHealthbar", "SHOW_VEHICLE"}, true) and unit:vehicle_driving() and not self._seat then
							self._last_unit = nil
							visible = true
							managers.hud:set_enemy_health({
									current = (unit:character_damage()._health or 0) * 1,
									total = (unit:character_damage()._HEALTH_INIT or 0) * 1
							})
						else
							visible = false
						end
					end
	
					if not visible and self._last_unit and alive( self._last_unit ) and self._last_unit:character_damage() then
						managers.hud:set_enemy_health({
							current = (self._last_unit:character_damage()._health or 0) * 10,
							total = (self._last_unit:character_damage()._HEALTH_INIT or 0) * 10
						})
	
						local angle = (self:getUnitRotation(self._last_unit) + 360) % 360
						if self._last_unit:character_damage():dead() or (angle < 350 and angle > 10) then
							visible = false
							self._last_unit = nil
						else
							visible = true
						end
					end
	
					managers.hud:set_enemy_health_visible( visible, shield )
				else
					managers.hud:set_enemy_health_visible( false )
				end
		end)
	
		function PlayerStandard:getUnitRotation( unit )
	
			if not unit or not alive( unit ) then return 360 end
	
			local unit_position = unit:position()
			local vector = unit_position - self._camera_unit:position()
			local forward = self._camera_unit:rotation():y()
			local rotation = math.floor( vector:to_polar_with_reference( forward , math.UP ).spin )
	
			return rotation
	
		end
	elseif string.lower(RequiredScript) == "lib/states/ingamearrested" then
		Hooks:PostHook( IngameArrestedState , "at_enter" , "WolfHUDPostIngameArrestedAtEnter" , function( self )
			if managers.hud then
				managers.hud:set_enemy_health_visible( false, false )
			end
		end )
	elseif string.lower(RequiredScript) == "lib/managers/statisticsmanager" then	
		local in_custody_orig = StatisticsManager.in_custody
		function StatisticsManager:in_custody(...)
			managers.hud:set_unit_health_visible(false)
			managers.hud:set_enemy_health_visible(false)
			return in_custody_orig(self, ...)
		end	
	end	