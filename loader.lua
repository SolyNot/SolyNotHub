local baseUrl = "https://raw.githubusercontent.com/BaconBABA/SolyNotHub/main/Games/"
local url = baseUrl .. tostring(game.PlaceId) .. ".lua"

local success, scriptContent = pcall(function()
    return game:HttpGet(url)
end)

if success then
    loadstring(scriptContent)()
else
    game.Players.LocalPlayer:Kick("This game is not supported.")
end
