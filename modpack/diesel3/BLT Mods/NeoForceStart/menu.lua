local ModPath = ModPath
local SavePath = SavePath

local modDataPath = SavePath .. "/betterforcestart.json"

--Set up button callbacks
local function wrapper(load_mode, leaveHostBehind)
	local better_force_start = _G.better_force_start
	if better_force_start then
		return better_force_start(load_mode, leaveHostBehind)
	end
end

function MenuCallbackHandler.better_force_start_host()
	return wrapper(0)
end

function MenuCallbackHandler.better_force_start_ready()
	return wrapper(1)
end

function MenuCallbackHandler.better_force_start_everyone()
	return wrapper(2)
end

--Set up save callback
function MenuCallbackHandler.better_force_start_save(self, button)
	local menu = MenuHelper:GetMenu("better_force_start_settings")

	local data = {
		menu_load_mode = menu:item("better_force_start_settings_enter_mode_selector"):value(),
		client_menu_load_mode = menu:item("better_force_start_settings_client"):value(),
		waiting_room = menu:item("better_force_start_settings_prompt"):value() == "on"
	}

	io.save_as_json(data, modDataPath)
end

--Set up localization even though I only made this mod available in English.
Hooks:Add("LocalizationManagerPostInit", "better_force_start_localization", function(self)
	local languageId = SystemInfo:language():key()
	local filename = "english.json"
	for _, v in pairs(file.GetFiles(ModPath .. "/loc/")) do
		local lang = v:gsub(".json", "")
		if Idstring(lang):key() == languageId then
			filename = v
			break
		end
	end
	LocalizationManager:load_localization_file(ModPath .. "/loc/" .. filename)
end)


--Set up menus
Hooks:Add("MenuManagerSetupCustomMenus", "better_force_start_menu_setup", function(self, nodes)
	local class = {} --This value is unused in LoadFromJsonFile but the example still includes it.
	local data = io.load_as_json(modDataPath) or {}

	class._data = data
	MenuHelper:LoadFromJsonFile(ModPath .. "/menu.json", class, data)
end)
