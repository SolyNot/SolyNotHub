local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

local localPlayer = game.Players.LocalPlayer
local highlights = {}
local connections = {}
local characterConnections = {}

local Window = Fluent:CreateWindow({
    Title = "SolyNot Universal",
    SubTitle = "by SolyNot",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = true,
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.LeftControl
})

local Tabs = {
    ESP = Window:AddTab({ Title = "ESP", Icon = "eye" }),
    Settings = Window:AddTab({ Title = "Settings", Icon = "settings" })
}

local settings = {
    enabled = false,
    teamCheck = true,
    showTeammates = false,
    useTeamColor = true,
    defaultColor = Color3.new(1, 0, 0)
}
Window:SelectTab(1)
zTabs.ESP:AddToggle("ESPEnabled", { Title = "Enable ESP", Default = false, Callback = function(v) settings.enabled = v end })
Tabs.ESP:AddToggle("TeamCheck", { Title = "Team Check", Default = true, Callback = function(v) settings.teamCheck = v end })
Tabs.ESP:AddToggle("ShowTeammates", { Title = "Show Teammates", Default = false, Callback = function(v) settings.showTeammates = v end })
Tabs.ESP:AddToggle("UseTeamColor", { Title = "Use Team Color", Default = true, Callback = function(v) settings.useTeamColor = v end })
Tabs.ESP:AddColorpicker("DefaultColor", { Title = "Default ESP Color", Default = settings.defaultColor, Callback = function(v) settings.defaultColor = v end })

local function updateHighlight(player)
    if player == localPlayer then return end
    local character = player.Character
    if not character then return end
    local highlight = highlights[player] or Instance.new("Highlight", character)
    highlights[player] = highlight
    highlight.Enabled = settings.enabled and (not settings.teamCheck or player.Team ~= localPlayer.Team or settings.showTeammates)
    highlight.OutlineColor = settings.useTeamColor and player.TeamColor.Color or settings.defaultColor
end

table.insert(connections, game.Players.PlayerAdded:Connect(function(player)
    characterConnections[player] = player.CharacterAdded:Connect(function()
        updateHighlight(player)
    end)
    if player.Character then
        updateHighlight(player)
    end
end))

table.insert(connections, game.Players.PlayerRemoving:Connect(function(player)
    if characterConnections[player] then
        characterConnections[player]:Disconnect()
        characterConnections[player] = nil
    end
    if highlights[player] then
        highlights[player]:Destroy()
        highlights[player] = nil
    end
end))

for _, player in pairs(game.Players:GetPlayers()) do
    if player ~= localPlayer then
        characterConnections[player] = player.CharacterAdded:Connect(function()
            updateHighlight(player)
        end)
        if player.Character then
            updateHighlight(player)
        end
    end
end

task.spawn(function()
    while not Fluent.Unloaded do
        task.wait()
        for player in pairs(highlights) do
            updateHighlight(player)
        end
    end
    for _, connection in ipairs(connections) do
        connection:Disconnect()
    end
    for player, connection in pairs(characterConnections) do
        connection:Disconnect()
    end
    for player, highlight in pairs(highlights) do
        highlight:Destroy()
    end
end)

SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)
InterfaceManager:BuildInterfaceSection(Tabs.Settings)
SaveManager:BuildConfigSection(Tabs.Settings)
