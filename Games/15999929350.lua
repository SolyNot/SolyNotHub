local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()
local players = game:GetService("Players")
local player = players.LocalPlayer

local plr = {}

for _,v in pairs(players:GetPlayers()) do
    table.insert(plr,v.Name)
end

local Window = Fluent:CreateWindow({
    Title = "SolyNot Hub V1 (not optimized because lazy)",
    SubTitle = "by SolyNot",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = true,
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.LeftControl
})

local Tabs = {
    Troll = Window:AddTab({ Title = "Troll", Icon = "skull" }),
    Win = Window:AddTab({ Title = "Win", Icon = "crown" }),
    Settings = Window:AddTab({ Title = "Settings", Icon = "settings" })
}

function equiptool()
    if not player.Character:FindFirstChild("Slap") then
        player.Backpack:FindFirstChild("Slap").Parent = player.Character
    end
end

Tabs.Troll:AddParagraph({
    Title = "Important",
    Content = "join discord for more infomation https://discord.gg/zqwbk8NHHN"
})

Tabs.Troll:AddButton({
    Title = "Click to copy discord link",
    Callback = function()
        setclipboard("https://discord.gg/zqwbk8NHHN")
    end
})

local playerdropdown = Tabs.Troll:AddDropdown("Dropdown", {Title = "Players",Values = plr,Multi = false,Default = 1,})
players.PlayerAdded:Connect(function(player)
    table.insert(plr, player.Name)
    playerdropdown:SetValue(player)
end)
players.PlayerRemoving:Connect(function(player)
    for i, name in ipairs(plr) do
        if name == player.Name then
            table.remove(plr, i)
            break
        end
    end
    playerdropdown:SetValue(plr[1] or "")
end)
local X = Tabs.Troll:AddInput("Input", {Title = "X",Default = "1",Placeholder = "1",Numeric = true,Finished = false,})
local Y = Tabs.Troll:AddInput("Input", {Title = "Y",Default = "1",Placeholder = "1",Numeric = true,Finished = false,})
local Z = Tabs.Troll:AddInput("Input", {Title = "Z",Default = "1",Placeholder = "1",Numeric = true,Finished = false,})

Tabs.Troll:AddButton({
    Title = "Get tool",
    Callback = function()
        if not player.Backpack:FindFirstChild("Slap") or player.Character:FindFirstChild("Slap") then
            player.Character.HumanoidRootPart.CFrame = CFrame.new(-465, 4, -1840)
            fireproximityprompt(workspace.MainGame.GroupDoor["Slaps V1"].Default.ProximityPrompPart.Slap)
        end
    end
})

Tabs.Troll:AddButton({
    Title = "Fling Player with XYZ",
    Callback = function()
        equiptool()
        local args = {
        	"slash",
        	players[playerdropdown.Value].Character,
        	Vector3.new(X.Value, Y.Value, Z.Value)
        }
        player.Character:WaitForChild("Slap"):WaitForChild("Event"):FireServer(unpack(args))
    end
})

Tabs.Troll:AddButton({
    Title = "Fling All Players with XYZ",
    Callback = function()
        equiptool()
        for _,v in pairs(players:GetPlayers()) do
            local args = {
            	"slash",
            	players[v.Name].Character,
            	Vector3.new(X, Y, Z)
            }
            player.Character:WaitForChild("Slap"):WaitForChild("Event"):FireServer(unpack(args))
        end
    end
})

Tabs.Troll:AddButton({
    Title = "instantly kill all",
    Callback = function()
        equiptool()
        for _,v in pairs(players:GetPlayers()) do
            local args = {
            	"slash",
            	players[v.Name].Character,
            	Vector3.new(0,-999999999,0)
            }
            player.Character:WaitForChild("Slap"):WaitForChild("Event"):FireServer(unpack(args))
        end
    end
})

Tabs.Troll:AddButton({
    Title = "make all player gameplay paused",
    Callback = function()
        equiptool()
        for _,v in pairs(players:GetPlayers()) do
            local args = {
            	"slash",
            	players[v.Name].Character,
            	Vector3.new(0,999999999,0)
            }
            player.Character:WaitForChild("Slap"):WaitForChild("Event"):FireServer(unpack(args))
        end
    end
})

Tabs.Win:AddParagraph({
    Title = "Important",
    Content = "if we hit 25 member on discord I will release"
})

Window:SelectTab(1)
SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)
InterfaceManager:BuildInterfaceSection(Tabs.Settings)
SaveManager:BuildConfigSection(Tabs.Settings)
