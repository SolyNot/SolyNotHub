local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local localPlayer = Players.LocalPlayer
local highlights = {}
local connections = {}

local settings = {
    enabled = true,
    teamCheck = true,
    useTeamColor = true,
    rainbowMode = false,
    rainbowSpeed = 0.5,
    defaultColor = Color3.fromRGB(255, 0, 0)
}

local Window = Fluent:CreateWindow({
    Title = "SolyNot Universal",
    SubTitle = "by SolyNot",
    TabWidth = 160,
    Size = UDim2.fromOffset(500, 350),
    Acrylic = true,
    Theme = "Dark"
})

local Tab = Window:AddTab({ Title = "ESP", Icon = "eye" })
local setting = Window:AddTab({ Title = "Settings", Icon = "settings" })
Tab:AddToggle("ESPEnabled", { Title = "Enable ESP", Default = settings.enabled, 
    Callback = function(value) settings.enabled = value end 
})
Tab:AddToggle("TeamCheck", { Title = "Team Check", Default = settings.teamCheck, 
    Callback = function(value) settings.teamCheck = value end 
})
Tab:AddToggle("UseTeamColor", { Title = "Use Team Color", Default = settings.useTeamColor, 
    Callback = function(value) settings.useTeamColor = value end 
})
Tab:AddToggle("RainbowMode", { Title = "Rainbow Mode", Default = settings.rainbowMode, 
    Callback = function(value) settings.rainbowMode = value end 
})
Tab:AddSlider("RainbowSpeed", { 
    Title = "Rainbow Speed",
    Default = settings.rainbowSpeed, 
    Min = 0.1, 
    Max = 5.0, 
    Rounding = 1,
    Callback = function(value) settings.rainbowSpeed = value end 
})
Tab:AddColorpicker("DefaultColor", { 
    Title = "Default Color", 
    Default = settings.defaultColor, 
    Callback = function(value) settings.defaultColor = value end 
})

local currentHue = 0

local function cleanupHighlights()
    for player, data in pairs(highlights) do
        if data.highlight then
            data.highlight:Destroy()
        end
    end
    table.clear(highlights)
end

local function disconnectAll()
    for _, connection in pairs(connections) do
        if connection.Connected then
            connection:Disconnect()
        end
    end
    table.clear(connections)
end

local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local localPlayer = Players.LocalPlayer
local highlights = {}

local settings = {
    enabled = true,
    teamCheck = true,
    useTeamColor = true,
    rainbowMode = false,
    rainbowSpeed = 0.5,
    defaultColor = Color3.fromRGB(255, 0, 0)
}

-- Connections for cleanup
local connections = {}

local Window = Fluent:CreateWindow({
    Title = "SolyNot Universal",
    SubTitle = "by SolyNot",
    TabWidth = 160,
    Size = UDim2.fromOffset(500, 350),
    Acrylic = true,
    Theme = "Dark"
})

local Tab = Window:AddTab({ Title = "ESP", Icon = "eye" })
local setting = Window:AddTab({ Title = "Settings", Icon = "settings" })
Tab:AddToggle("ESPEnabled", { Title = "Enable ESP", Default = settings.enabled, 
    Callback = function(value) settings.enabled = value end 
})
Tab:AddToggle("TeamCheck", { Title = "Team Check", Default = settings.teamCheck, 
    Callback = function(value) settings.teamCheck = value end 
})
Tab:AddToggle("UseTeamColor", { Title = "Use Team Color", Default = settings.useTeamColor, 
    Callback = function(value) settings.useTeamColor = value end 
})
Tab:AddToggle("RainbowMode", { Title = "Rainbow Mode", Default = settings.rainbowMode, 
    Callback = function(value) settings.rainbowMode = value end 
})
Tab:AddSlider("RainbowSpeed", { 
    Title = "Rainbow Speed",
    Default = settings.rainbowSpeed, 
    Min = 0.1, 
    Max = 5.0, 
    Rounding = 1,
    Callback = function(value) settings.rainbowSpeed = value end 
})
Tab:AddColorpicker("DefaultColor", { 
    Title = "Default Color", 
    Default = settings.defaultColor, 
    Callback = function(value) settings.defaultColor = value end 
})

local currentHue = 0

-- Function to clean up all highlights
local function cleanupHighlights()
    for player, data in pairs(highlights) do
        if data.highlight then
            data.highlight:Destroy()
        end
    end
    table.clear(highlights)
end

-- Function to disconnect all connections
local function disconnectAll()
    for _, connection in pairs(connections) do
        if connection.Connected then
            connection:Disconnect()
        end
    end
    table.clear(connections)
end

local function applyESP(player)
    if Fluent.Unloaded then
        cleanupHighlights()
        disconnectAll()
        return
    end

    if player == localPlayer then return end
    
    if highlights[player] and highlights[player].character ~= player.Character then
        if highlights[player].highlight then
            highlights[player].highlight:Destroy()
        end
        highlights[player] = nil
    end
    
    if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then
        if highlights[player] and highlights[player].highlight then
            highlights[player].highlight:Destroy()
            highlights[player] = nil
        end
        return
    end
    
    if not highlights[player] then
        local highlight = Instance.new("Highlight", player.Character)
        highlights[player] = {highlight = highlight, character = player.Character}
    end
    
    local highlight = highlights[player].highlight
    highlight.Enabled = settings.enabled and (not settings.teamCheck or not (player.Team and player.Team == localPlayer.Team))
    
    if highlight.Enabled then
        local color = settings.rainbowMode and Color3.fromHSV(currentHue, 1, 1) or (settings.useTeamColor and player.TeamColor and player.TeamColor.Color or settings.defaultColor)
        highlight.OutlineColor = color
        highlight.FillColor = color
    end
end

for _, player in pairs(Players:GetPlayers()) do
    applyESP(player)
end

table.insert(connections, Players.PlayerAdded:Connect(function(player)
    if Fluent.Unloaded then return end
    local charAddedConn = player.CharacterAdded:Connect(function()
        if Fluent.Unloaded then return end
        applyESP(player)
    end)
    table.insert(connections, charAddedConn)
    if player.Character then
        applyESP(player)
    end
end))

table.insert(connections, Players.PlayerRemoving:Connect(function(player)
    if highlights[player] and highlights[player].highlight then
        highlights[player].highlight:Destroy()
    end
    highlights[player] = nil
end))

table.insert(connections, RunService.Heartbeat:Connect(function(deltaTime)
    if Fluent.Unloaded then
        cleanupHighlights()
        disconnectAll()
        return
    end
    currentHue = (currentHue + deltaTime * settings.rainbowSpeed) % 1
    for player, _ in pairs(highlights) do
        applyESP(player)
    end
end))

SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)
InterfaceManager:BuildInterfaceSection(setting)
SaveManager:BuildConfigSection(setting)
