local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()
local players = game:GetService("Players")
local player = players.LocalPlayer

local plr = {}
local tools = {}
for _,v in pairs(players:GetPlayers()) do
    table.insert(plr,v.Name)
end
for _,v in pairs(game:GetService("ReplicatedStorage").SlapTools:GetChildren()) do
	table.insert(tools,v.Name)
end
local Window = Fluent:CreateWindow({
    Title = "SolyNot Hub V1.1",
    SubTitle = "by SolyNot",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = true,
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.LeftControl
})

local Tabs = {
    Troll = Window:AddTab({ Title = "Troll", Icon = "skull" }),
    Settings = Window:AddTab({ Title = "Settings", Icon = "settings" })
}

function equiptool()
    if not player.Character:FindFirstChildWhichIsA("Tool") then
        player.Backpack:FindFirstChildWhichIsA("Tool").Parent = player.Character
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
    if not Fluent.Unloaded then
        table.insert(plr, player.Name)
        playerdropdown:SetValue(player)
    end
end)
players.PlayerRemoving:Connect(function(player)
    if not Fluent.Unloaded then
        for i, name in ipairs(plr) do
            if name == player.Name then
                table.remove(plr, i)
                break
            end
        end
        playerdropdown:SetValue(plr[1] or "")
    end
end)

local tool = Tabs.Troll:AddDropdown("Dropdown", {Title = "Tools",Values = tools,Multi = false,Default = 1,})

Tabs.Troll:AddButton({
    Title = "Equip Select tool",
    Callback = function()
        game:GetService("ReplicatedStorage"):WaitForChild("EquipSlapEvent"):FireServer(tool.Value)
    end
})

local X = Tabs.Troll:AddInput("Input", {Title = "X",Default = "1",Placeholder = "1",Numeric = true,Finished = false,})
local Y = Tabs.Troll:AddInput("Input", {Title = "Y",Default = "1",Placeholder = "1",Numeric = true,Finished = false,})
local Z = Tabs.Troll:AddInput("Input", {Title = "Z",Default = "1",Placeholder = "1",Numeric = true,Finished = false,})

Tabs.Troll:AddButton({
    Title = "Fling Player with XYZ",
    Callback = function()
        equiptool()
        local args = {
        	"slash",
        	players[playerdropdown.Value].Character,
        	Vector3.new(X.Value, Y.Value, Z.Value)
        }
        player.Character:FindFirstChildWhichIsA("Tool"):WaitForChild("Event"):FireServer(unpack(args))
    end
})
Tabs.Troll:AddButton({
    Title = "bring selected player",
    Callback = function()
		if not player.Character:FindFirstChild("SwapperSlap") or player.Backpack:FindFirstChild("SwapperSlap") then
        	game:GetService("ReplicatedStorage"):WaitForChild("EquipSlapEvent"):FireServer("SwapperSlap")
		end
        equiptool()
        local args = {
        	"swap",
	        game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame.Position,
	        game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame.Position,
	        players[playerdropdown.Value]
        }
        player.Character:FindFirstChildWhichIsA("Tool"):WaitForChild("Event"):FireServer(unpack(args))
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
            player.Character:FindFirstChildWhichIsA("Tool"):WaitForChild("Event"):FireServer(unpack(args))
        end
    end
})
Tabs.Troll:AddButton({
    Title = "bring all players",
    Callback = function()
		if not player.Character:FindFirstChild("SwapperSlap") or player.Backpack:FindFirstChild("SwapperSlap") then
        	game:GetService("ReplicatedStorage"):WaitForChild("EquipSlapEvent"):FireServer("SwapperSlap")
		end
        equiptool()
		for _,v in pairs(players:GetPlayers()) do
        	local args = {
        		"swap",
	    	    game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame.Position,
	    	    game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame.Position,
	    	    v
        	}
        	player.Character:FindFirstChildWhichIsA("Tool"):WaitForChild("Event"):FireServer(unpack(args))
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
            player.Character:FindFirstChildWhichIsA("Tool"):WaitForChild("Event"):FireServer(unpack(args))
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
            player.Character:FindFirstChildWhichIsA("Tool"):WaitForChild("Event"):FireServer(unpack(args))
        end
    end
})
Window:SelectTab(1)
SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)
InterfaceManager:BuildInterfaceSection(Tabs.Settings)
SaveManager:BuildConfigSection(Tabs.Settings)
