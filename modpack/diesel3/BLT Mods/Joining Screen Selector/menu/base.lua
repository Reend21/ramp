_G.JoiningScreenSelector = _G.JoiningScreenSelector or {}
JoiningScreenSelector.path = ModPath
JoiningScreenSelector.data_path = SavePath .. "joining_screen_selector.txt"
JoiningScreenSelector.settings = {
	operate_type = 1,
	level_and_platform = 1,
	show_modlist = false,
	show_skillpoints = true
}

function JoiningScreenSelector:Save()
	local file = io.open(self.data_path, "w+")
	if file then
		file:write(json.encode(self.settings))
		file:close()
	end
end

function JoiningScreenSelector:Load()
	local file = io.open(self.data_path, "r")
	if file then
		local options = json.decode(file:read("*all"))
		for num, option in pairs(options) do
			self.settings[num] = option
		end
		file:close()
	end
end

Hooks:Add("MenuManagerInitialize", "MenuManagerInitialize_JoiningScreenSelector", function(menu_manager)
	MenuCallbackHandler.JoiningScreenSelectorToggle = function(this, item)
		JoiningScreenSelector.settings[item:name()] = item:value() == "on"
	end
	
	MenuCallbackHandler.JoiningScreenSelectorOperateType = function(this, item)
		JoiningScreenSelector.settings[item:name()] = item:value()
	end
	
	MenuCallbackHandler.JoiningScreenSelectorLevelAndPlatform = function(this, item)
		JoiningScreenSelector.settings[item:name()] = item:value()
	end
	
	MenuCallbackHandler.JoiningScreenSelector_Save = function(this, item)
		JoiningScreenSelector:Save()
	end
	
	MenuHelper:LoadFromJsonFile(JoiningScreenSelector.path .. "menu/options.txt", JoiningScreenSelector, JoiningScreenSelector.settings)
	
	JoiningScreenSelector:Load()
end)