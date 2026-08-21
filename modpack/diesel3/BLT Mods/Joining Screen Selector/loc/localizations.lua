Hooks:Add("LocalizationManagerPostInit", "MenuManagerInitialize_JoiningScreenSelector", function(loc)
	jss_languageList = {
		"loc/english.txt"
	}
	jss_languagePath = jss_languageList[1]
	loc:load_localization_file(JoiningScreenSelector.path .. jss_languagePath)
end)
