local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/x2zu/OPEN-SOURCE-UI-ROBLOX/refs/heads/main/X2ZU%20UI%20ROBLOX%20OPEN%20SOURCE/DummyUi-leak-by-x2zu/fetching-main/Tools/Framework.luau"))()
local me = Players.LocalPlayer

local savedCollide = {}
local spinConn, seatConn, charConn

local function ensurePrimary(m)
	if not m or not m.Parent then return nil end
	if not m.PrimaryPart then
		for _,p in ipairs(m:GetDescendants()) do
			if p:IsA("BasePart") then m.PrimaryPart = p break end
		end
	end
	return m.PrimaryPart
end

local function noclip(m)
	for _,p in ipairs(m:GetDescendants()) do
		if p:IsA("BasePart") and savedCollide[p] == nil then
			savedCollide[p] = p.CanCollide
			p.CanCollide = false
		end
	end
end

local function restoreAll()
	for p,v in pairs(savedCollide) do
		if p and p.Parent then p.CanCollide = v end
	end
	savedCollide = {}
end

local function stopSpin()
	if spinConn then spinConn:Disconnect() spinConn = nil end
end

local function startSpin(model)
	stopSpin()
	local pp = ensurePrimary(model)
	if not pp then return end
	local base = pp.CFrame.p
	local ang = 0
	spinConn = RunService.Heartbeat:Connect(function(dt)
		if not pp or not pp.Parent then stopSpin() restoreAll() return end
		ang = ang + 50 * dt
		pcall(function() model:SetPrimaryPartCFrame(CFrame.new(base) * CFrame.Angles(0, ang, 0)) end)
	end)
end

local function moveCartUnderMe(model)
	local hrp = (me.Character and me.Character:FindFirstChild("HumanoidRootPart"))
	if not hrp then return end
	local pp = ensurePrimary(model)
	if not pp then return end
	pcall(function()
		local target = hrp.CFrame.p + Vector3.new(25, 0, 0)
		model:SetPrimaryPartCFrame(CFrame.new(target) * CFrame.Angles(pp.CFrame:ToEulerAnglesXYZ()))
	end)
end

local function onSeatChanged(hum)
	local seat = hum and hum.SeatPart
	if seat and seat:IsA("BasePart") then
		local cart = seat:FindFirstAncestorOfClass("Model") or seat.Parent
		if cart then
			moveCartUnderMe(cart)
			noclip(cart)
			startSpin(cart)
		end
	else
		stopSpin()
		restoreAll()
	end
end

local function watchCharacter(ch)
	if seatConn then seatConn:Disconnect() seatConn = nil end
	if not ch then return end
	local hum = ch:FindFirstChildOfClass("Humanoid")
	if not hum then return end
	seatConn = hum:GetPropertyChangedSignal("SeatPart"):Connect(function() onSeatChanged(hum) end)
	onSeatChanged(hum)
end

charConn = me.CharacterAdded:Connect(watchCharacter)
if me.Character then watchCharacter(me.Character) end

local win = Library:Window{
	Title = "Ride A Cart Down A Slide",
	Desc = "SolyNot on top",
	Icon = 96112338375785,
	Theme = "Dark",
	Config = {Keybind = Enum.KeyCode.LeftControl, Size = UDim2.new(0,500,0,400)},
	CloseUIButton = {Enabled = true, Text = "SolyNot"}
}

do
	local tab = win:Tab{Title="Main", Icon="star"}
	tab:Section{Title="Auto Farm"}
	tab:Code{Title="Discord", Code="https://discord.gg/PKbEwkAuj8"}
	tab:Toggle{
		Title="Auto Farm",
		Value=false,
		Callback=function(on)
			if on then
		        ReplicatedStorage.GetEquipped:InvokeServer("VIP")
			else
				stopSpin()
				restoreAll()
			end
		end
	}
end

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
