_G.CustomFOV = _G.CustomFOV or {}
CustomFOV.ModPath = ModPath
CustomFOV.SaveFile = CustomFOV.SaveFile or SavePath .. "CustomFOV.txt"
CustomFOV.ModOptions = CustomFOV.ModPath .. "menus/modoptions.txt"
CustomFOV.Settings = {}


function CustomFOV:Reset()
    self.Settings = {
        fov_multiplier = 1.0
}
    self:Save()
end

-- Taken from Lobby Player Info (thanks for making such an awesome mod, TdlQ!)
Hooks:Add("LocalizationManagerPostInit", "LocalizationManagerPostInit_CustomFOV", function(loc)
        for __, filename in pairs(file.GetFiles(CustomFOV.ModPath .. "loc/")) do
                local str = filename:match('^(.*).txt$')
                if str and Idstring(str) and Idstring(str):key() == SystemInfo:language():key() then
                        loc:load_localization_file(CustomFOV.ModPath .. "loc/" .. filename)
                        break
                end
        end

        loc:load_localization_file(CustomFOV.ModPath .. "loc/english.txt", false)
end)


function CustomFOV:Load()
        local file = io.open(self.SaveFile, "r")
        if file then
                for key, value in pairs(json.decode(file:read("*all"))) do
                        self.Settings[key] = value
                end
                file:close()
        else
            self:Reset()
        end

end

function CustomFOV:Save()
        local file = io.open(self.SaveFile, "w+")
        if file then
            file:write(json.encode(self.Settings))
            file:close()
        end
end


CustomFOV:Load()
