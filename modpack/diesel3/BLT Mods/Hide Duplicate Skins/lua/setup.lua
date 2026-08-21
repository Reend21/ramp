if _G.HideDupeSkins then return end

_G.HideDupeSkins = {}
HideDupeSkins.meta = {
	mod_path = ModPath,
	save_path = SavePath,
	menu_id = "hds_options_menu",
	menu_file = ModPath.."menu/options.json",
	save_file = SavePath.."hds_settings.json",
}

function HideDupeSkins:save_json(path, data)
	local file = io.open(path, "w+")
	file:write(json.encode(data))
	file:close()
end

function HideDupeSkins:load_json(path)
	local file = io.open(path, "r")
	local data = json.decode(file:read("*all")) or {}
	file:close()
	return data
end

function HideDupeSkins:save_settings()
	self:save_json(self.meta.save_file, self.settings)
end

function HideDupeSkins:load_settings()
	local file = io.open(self.meta.save_file, "r")
	if file then
		local data = json.decode(file:read("*all")) or {}
		file:close()
		for k, _ in pairs(self.settings) do
			if data[k] ~= nil then
				self.settings[k] = data[k]
			end
		end
	end
end

--Load settings
HideDupeSkins.settings = {
	hds_auto_mode = 1,
	hds_min_quality = 1,
}
HideDupeSkins:load_settings()

--DB of all unqiue skins db[skin_id][<quality>_<variant>]=instance_id
HideDupeSkins.db = {}
--List of visible skins show[skin_id]=instance_id
HideDupeSkins.show = {}
--stat[skin_id]=instance_id if visible instance is not stat-boosted and a stat-boosted version exists
HideDupeSkins.stat = {}

--Menu hooks
Hooks:Add("LocalizationManagerPostInit", "HideDupeSkins-Hooks-LocalizationManagerPostInit", function(loc)
	loc:load_localization_file(HideDupeSkins.meta.mod_path.."localizations/english.json")
end)

Hooks:Add("MenuManagerInitialize", "HideDupeSkins-Hooks-MenuManagerInitialize", function(menu_manager)
	local Mod = HideDupeSkins

	MenuCallbackHandler.hds_callback_multi = function(self, item)
		Mod.settings[item:name()] = item:value()
	end

	MenuCallbackHandler.hds_callback_save = function(self, item)
		Mod:save_settings()
		--Set visible skins when leaving options menu
		HideDupeSkins:set_visible_items()
	end

	MenuHelper:LoadFromJsonFile(Mod.meta.menu_file, Mod, Mod.settings)
end)

function HideDupeSkins:get_menu_item(setting_id)
	local menu = MenuHelper:GetMenu(self.meta.menu_id)
	for _, item in pairs(menu._items) do
		local name = item._parameters and item._parameters.name
		if name == setting_id then
			return item
		end
	end
end

--Multiple choice options must be named as "<setting_id>_name" for this to work
function HideDupeSkins:get_choice_name(setting_id)
	local value = self.settings[setting_id]
	if not value then
		return
	end

	local item = self:get_menu_item(setting_id)
	local options = item._options or item._all_options
	local text_id = options[value]._parameters.text_id
	return string.sub(text_id, string.len(setting_id)+2)
end

function HideDupeSkins:dialog_ask(data)
	local menu_title = managers.localization:text("hds_dialog_title")
	local menu_message = managers.localization:text("hds_dialog_body")

	local skin_id = data.cosmetic_id
	local min_quality = self:get_choice_name("hds_min_quality")
	local menu_options = {}
	for _, quality in ipairs({"mint", "fine", "good", "fair", "poor"}) do
		for _, variant in ipairs({"stat", "norm"}) do
			local k = quality.."_"..variant
			local instance_id = self.db[skin_id][k]
			if instance_id then
				local text = managers.localization:text("bm_menu_quality_"..quality)
				if variant == "stat" then
					text = text..", "..managers.localization:text("menu_bm_inventory_bonus")
				end
				table.insert(menu_options, {
					text = text,
					callback = function()
						data.name = instance_id
						data._hds_done = true
						local bmg = managers.menu_component._blackmarket_gui
						bmg:equip_weapon_cosmetics_callback(data)
					end,
					is_focused_button = (#menu_options == 0),
				})
			end
		end
		if quality == min_quality then
			break
		end
	end
	table.insert(menu_options, {
		text = managers.localization:text("dialog_cancel"),
		is_cancel_button = true,
	})
	QuickMenu:new(menu_title, menu_message, menu_options):Show()
end

--Call after DB is made to build visible list
function HideDupeSkins:set_visible_items()
	self.show = {}
	self.stat = {}
	local min_quality = self:get_choice_name("hds_min_quality")
	for skin_id, instances in pairs(self.db) do
		local count = 0
		local stat_found = false
		for _, quality in ipairs({"mint", "fine", "good", "fair", "poor"}) do
			for _, variant in ipairs({"stat", "norm"}) do
				local k = quality.."_"..variant
				if instances[k] then
					count = count + 1
					--Best quality one, may not be stat boosted
					if not self.show[skin_id] then
						self.show[skin_id] = instances[k]
					end
					--Stat-boosted list
					if not self.stat[skin_id] and variant == "stat" then
						self.stat[skin_id] = instances[k]
					end
				end
			end
			if quality == min_quality then
				break
			end
		end
		self.db[skin_id].count = count
	end

	--Stat boost mode, we don't care if it's not the best quality.
	if self:get_choice_name("hds_auto_mode") == "bonus" then
		for skin_id, instance_id in pairs(self.stat) do
			self.show[skin_id] = instance_id
		end
	end
end
