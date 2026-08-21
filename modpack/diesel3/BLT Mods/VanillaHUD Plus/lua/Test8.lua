HoxPopUp = HoxPopUp or class()
	
function HoxPopUp:init(unit)
	self._unit = unit
	self._runtime = VHUDPlus:getSetting({"DamagePopupNew", "DURATION"}, 3.5)
	self._kill_flash_spd = VHUDPlus:getSetting({"DamagePopupNew", "DAMAGE_KILL_FLASH_SPD"}, 4)
	self._fatal_hit_chg_per_tick = Vector3(0, 0, VHUDPlus:getSetting({"DamagePopupNew", "FATAL_HIT_CHG_PER_TICK"}, 0.5))
	self._hit_chg_per_tick = Vector3(0, 0, VHUDPlus:getSetting({"DamagePopupNew", "HIT_CHG_PER_TICK"}, 0.1))
	self._vert_offset = Vector3(0, 0, VHUDPlus:getSetting({"DamagePopupNew", "DAMAGE_VERT_OFFSET"}, 60))
	self._show_damage_counter = VHUDPlus:getSetting({"DamagePopupNew", "SHOW_DAMAGE_POPUP_ALT"}, true)
	self._show_damage_per_hit = VHUDPlus:getSetting({"DamagePopupNew", "SHOW_DAMAGE_PER_HIT"}, true)
	self._text_scale = VHUDPlus:getSetting({"DamagePopupNew", "SCALE"}, 50)
	self._rainbow_popups = VHUDPlus:getSetting({"DamagePopupNew", "SHOW_RAINBOW_POPUPS"}, false)
	self._damage_hit_color = VHUDPlus:getColorSetting({"DamagePopupNew", "COLOR"}, "white")
	self._damage_kill_color = VHUDPlus:getColorSetting({"DamagePopupNew", "HEADSHOT_COLOR"}, "orange")
	self._damage_headshot_flash_color = VHUDPlus:getColorSetting({"DamagePopupNew", "GLOW_COLOR"}, "red")
	self._panel_size = {
		150,
		100
	}
	self.flash_panel_offset = {
		-100,
		-35
	}
	self.flash_panel_dimensions = {
		200,
		300
	}
	self._ws = {}
	if Utils:IsInGameState() then
		unit:base():add_destroy_listener("HoxPopUp"..tostring(unit:key()), callback(self, self, "on_unit_destroyed"))
	end
end

function HoxPopUp:on_unit_destroyed(unit)
	for _,ws in ipairs(self._ws or {}) do
		ws:panel():stop()
		World:newgui():destroy_workspace(ws)
	end
	self._ws = {}
end

function HoxPopUp:show_damage(damage, killshot, headshot)
	
	if #self._ws > 0 and not self._show_damage_per_hit then
		for _,ws in ipairs(self._ws) do
			ws:panel():stop()
			World:newgui():destroy_workspace(ws)
		end
		self._ws = {}
		damage = damage + self._damage
	end

	local head_pos = self._unit:movement():m_head_pos()
	local x_rot = managers.player:player_unit():rotation():x()
	local y_rot = managers.player:player_unit():rotation():y()
	local cam_pos = managers.player:player_unit():camera():position() - head_pos

	local ws = World:newgui():create_world_workspace(
		self._panel_size[1],
		self._panel_size[2], 
		head_pos + self._vert_offset, 
		Vector3(self._text_scale, 
		math.atan2(cam_pos.y_rot, cam_pos.x_rot)/2, 0), 
		Vector3(0, 0, -self._text_scale)
	)

	local panel = ws:panel():panel({
		visible = self._show_damage_counter,
		name = "text_panel", 
		layer = 0
	})

	local damage_text = string.format("%d", damage * 10)
	damage_text = killshot and damage_text .. " " .. managers.localization:get_default_macro("BTN_SKULL") or damage_text
	
	local newpanel = {}
	local text_outline = {
		text = damage_text, 
		align = "left", 
		vertical = "bottom", 
		font = tweak_data.menu.pd2_large_font, 
		font_size = self._text_scale, 
		color = Color.black, 
		layer = 2
	}

	local headshotpanel = {}

	table.insert(newpanel, panel:text(text_outline))
	table.insert(newpanel, panel:text(text_outline))
	table.insert(newpanel, panel:text(text_outline))
	table.insert(newpanel, panel:text(text_outline))
	newpanel[1]:set_x(newpanel[1]:x() - 1)
	newpanel[1]:set_y(newpanel[1]:y() - 1)
	newpanel[2]:set_x(newpanel[2]:x() + 1)
	newpanel[2]:set_y(newpanel[2]:y() + 1)
	newpanel[3]:set_x(newpanel[3]:x() + 1)
	newpanel[3]:set_y(newpanel[3]:y() - 1)
	newpanel[4]:set_x(newpanel[4]:x() - 1)
	newpanel[4]:set_y(newpanel[4]:y() + 1)
	text_outline.color = killshot and VHUDPlus:getColorSetting({"DamagePopupNew", "HEADSHOT_COLOR"}, "orange") or VHUDPlus:getColorSetting({"DamagePopupNew", "COLOR"}, "white")
	text_outline.layer = 3

	if killshot and headshot then
		headshotpanel = ws:panel():panel({
			visible = self._show_damage_counter,
			name = "glow_panel", 
			layer = 0
		}):bitmap({ 
			name = "headshotpanel", 
			texture = "guis/textures/pd2/crimenet_marker_glow", 
			x = self.flash_panel_offset[1], 
			y = self.flash_panel_offset[2], 
			texture_rect = { 1, 1, 62, 62 }, 
			h = self.flash_panel_dimensions[1], 
			w = self.flash_panel_dimensions[2], 
			color = VHUDPlus:getColorSetting({"DamagePopupNew", "GLOW_COLOR"}, "red"), 
			blend_mode = "add", 
			layer = 1, 
			align = "left", 
			visible = self._show_damage_counter,
			rotation = 360
		})
	end
	
	table.insert(newpanel, panel:text(text_outline))
	panel:animate(callback(self, self, "_animate_dmg"), ws, newpanel, head_pos + self._vert_offset, killshot, headshot, headshotpanel)
	table.insert(self._ws, ws)
	self._damage = damage
end

function HoxPopUp:_animate_dmg(panel, ws, newpanel, head_pos, killshot, headshot, headshotpanel)
	local runtime = self._runtime
	local time = 0
	local get_pos = Vector3(0,0,0)
	while time < runtime do
		time = time + coroutine.yield()
		local gettime = (runtime - time)/runtime
		for _,newt in ipairs(newpanel) do
			newt:set_alpha(gettime)
		end
		local cam_pos = managers.player:player_unit():camera():position() - head_pos
		local getrot = math.atan2(cam_pos.y, cam_pos.x)
		getrot = getrot < 0 and getrot - 90 or getrot + 90
		local rot = 90 - (90 - (getrot)) % 180
		rot = rot < -90 and rot + 180 or rot > 90 and rot - 180 or rot
		if killshot and headshot then
			if self._rainbow_popups then
				newpanel[5]:set_color(Color((math.sin(405*time + 0)/2) + 0.5, (math.sin(420*time + 60)/2) + 0.5, (math.sin(435*time + 120)/2) + 0.5))
				headshotpanel:set_color(Color((math.sin(435*time + 120)/2) + 0.5, (math.cos(420*time + 60)/2) + 0.5, (math.sin(405*time + 0)/2) + 0.5))
			end
			headshotpanel:set_alpha(math.abs(math.sin(90*self._kill_flash_spd*time)) * gettime)
		end
		get_pos = killshot and get_pos + self._fatal_hit_chg_per_tick or get_pos + self._hit_chg_per_tick
		head_pos = alive(self._unit) and self._unit:movement():m_head_pos() + self._vert_offset or head_pos
		ws:set_world(self._panel_size[1], self._panel_size[2], head_pos + get_pos, Vector3(self._text_scale, rot, 0), Vector3(0, 0, -self._text_scale))
		if getrot > 0 then
			ws:mirror_x()
		end
	end
	for _FORV_17_, _FORV_18_ in ipairs(self._ws) do
		if _FORV_18_ == ws then
			table.remove(self._ws, _FORV_17_)
			break
		end
	end
	World:newgui():destroy_workspace(ws)
end