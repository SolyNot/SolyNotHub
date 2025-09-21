local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/x2zu/OPEN-SOURCE-UI-ROBLOX/refs/heads/main/X2ZU%20UI%20ROBLOX%20OPEN%20SOURCE/DummyUi-leak-by-x2zu/fetching-main/Tools/Framework.luau"))()
local me = Players.LocalPlayer

local win = Library:Window{
	Title = "Ride A Cart Down A Slide",
	Desc = "SolyNot on top",
	Icon = 96112338375785,
	Theme = "Dark",
	Config = {Keybind = Enum.KeyCode.LeftControl, Size = UDim2.new(0,500,0,400)},
	CloseUIButton = {Enabled = true, Text = "SolyNot"}
}

do
	local tab = win:Tab{Title="Cars", Icon="car"}
	tab:Section{Title="Spawn Cars"}
	tab:Dropdown{
		Title="Choose Car",
		List=(function() local t={} for _,v in ipairs(ReplicatedStorage.NewCarts:GetChildren()) do t[#t+1]=v.Name end return t end)(),
		Callback=function(chosen) _G.chosenCar = chosen end
	}
	tab:Button{
		Title="Spawn Car",
		Callback=function() if _G.chosenCar then pcall(function() ReplicatedStorage.GetEquipped:InvokeServer(_G.chosenCar) end) end
		end
	}
end
