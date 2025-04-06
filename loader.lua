local baseUrl = "https://raw.githubusercontent.com/BaconBABA/SolyNotHub/main/Games/"
local url = baseUrl .. tostring(game.PlaceId) .. ".lua"

local success, scriptContent = pcall(function()
    return game:HttpGet(url)
end)

if success then
    loadstring(scriptContent)()
else
    loadstring(game:HttpGet(baseUrl .. "universal.lua"))()
end
