local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local localPlayer = Players.LocalPlayer
local highlights = {}
local managedConnections = {}

local settings = {
    enabled = false,
    teamCheck = true,
    showTeammates = false,
    useTeamColor = true,
    defaultColor = Color3.fromRGB(255, 0, 0)
}

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

Tabs.ESP:AddToggle("ESPEnabled", { Title = "Enable ESP", Default = settings.enabled, Callback = function(value) settings.enabled = value end })
Tabs.ESP:AddToggle("TeamCheck", { Title = "Team Check (Ignore Same Team)", Default = settings.teamCheck, Callback = function(value) settings.teamCheck = value end })
Tabs.ESP:AddToggle("ShowTeammates", { Title = "Show Teammates (If Team Check On)", Default = settings.showTeammates, Callback = function(value) settings.showTeammates = value end })
Tabs.ESP:AddToggle("UseTeamColor", { Title = "Use Team Color", Default = settings.useTeamColor, Callback = function(value) settings.useTeamColor = value end })
Tabs.ESP:AddColorpicker("DefaultColor", { Title = "Default ESP Color (If Not Team Color)", Default = settings.defaultColor, Callback = function(value) settings.defaultColor = value end })
Window:SelectTab(1)

local function cleanupHighlight(player)
    local data = highlights[player]
    if data then
        if data.connections then
            for _, conn in ipairs(data.connections) do
                conn:Disconnect()
            end
        end
        if data.highlight then
            data.highlight:Destroy()
        end
        highlights[player] = nil
    end
end

local function updateHighlight(player)
    if player == localPlayer then return end
    local character = player.Character
    local data = highlights[player]

    if not character then
        if data then
            cleanupHighlight(player)
        end
        return
    end

    if data and data.character ~= character then
        cleanupHighlight(player)
        data = nil
    end

    if not data then
        local newHighlight = Instance.new("Highlight", character)
        local characterRemovingConn = character.AncestryChanged:Connect(function(_, parent)
            if not parent then
                cleanupHighlight(player)
            end
        end)

        highlights[player] = {
            highlight = newHighlight,
            character = character,
            connections = { characterRemovingConn }
        }
        data = highlights[player]
    end

    local highlight = data.highlight
    local isOnTeam = player.Team and player.Team == localPlayer.Team
    local isVisible

    if not settings.enabled then
        isVisible = false
    elseif settings.teamCheck then
        isVisible = not isOnTeam or settings.showTeammates
    else
        isVisible = true
    end

    highlight.Enabled = isVisible

    if isVisible then
        highlight.OutlineColor = (settings.useTeamColor and player.TeamColor) and player.TeamColor.Color or settings.defaultColor
        highlight.FillColor = highlight.OutlineColor
    end
end

local function setupPlayer(player)
    if player == localPlayer then return end
    local charAddedConn = player.CharacterAdded:Connect(function(character)
        task.wait(0.1)
        if player.Character == character then
             updateHighlight(player)
        end
    end)
    table.insert(managedConnections, charAddedConn)
    if player.Character then
        updateHighlight(player)
    else
        cleanupHighlight(player)
    end
end

local function cleanupPlayer(player)
    if player == localPlayer then return end
    cleanupHighlight(player)
end

table.insert(managedConnections, Players.PlayerAdded:Connect(setupPlayer))
table.insert(managedConnections, Players.PlayerRemoving:Connect(cleanupPlayer))

for _, player in ipairs(Players:GetPlayers()) do
    pcall(setupPlayer, player)
end

local function onHeartbeat()
    if Fluent.Unloaded then
        local conn = table.find(managedConnections, RunService.Heartbeat)
        if conn and managedConnections[conn] then managedConnections[conn]:Disconnect() end
        
        print("SolyNot Universal: Unloading and cleaning up resources...")

        for i = #managedConnections, 1, -1 do
            local conn = managedConnections[i]
            pcall(function() conn:Disconnect() end)
            table.remove(managedConnections, i)
        end

        for player, _ in pairs(highlights) do
            pcall(cleanupHighlight, player)
        end

        highlights = nil
        settings = nil
        managedConnections = nil
        Fluent = nil
        return
    end

    for player, data in pairs(highlights) do
        if data and data.character and data.character.Parent then
            pcall(updateHighlight, player)
        else
            pcall(cleanupHighlight, player)
        end
    end
end

table.insert(managedConnections, RunService.Heartbeat:Connect(onHeartbeat))

SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)
InterfaceManager:BuildInterfaceSection(Tabs.Settings)
SaveManager:BuildConfigSection(Tabs.Settings)
