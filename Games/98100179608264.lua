local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/x2zu/OPEN-SOURCE-UI-ROBLOX/refs/heads/main/X2ZU%20UI%20ROBLOX%20OPEN%20SOURCE/DummyUi-leak-by-x2zu/fetching-main/Tools/Framework.luau"))()
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local lplr = Players.LocalPlayer
local char = lplr.Character or lplr.CharacterAdded:Wait()
local hum = char and char:FindFirstChildWhichIsA("Humanoid")

local SWAT = lplr.Playerdata.SWAT
local FBI = lplr.Playerdata.FBI

local Network = ReplicatedStorage:WaitForChild("Network")
local CalloutAdded = Network:WaitForChild("CalloutAdded")
local SceneArrived = Network:WaitForChild("SceneArrived")
local JoinCallout = Network:WaitForChild("JoinCallout")
local InteractPedestrian = Network:WaitForChild("InteractPedestrian")
local ArrestingPed = Network:WaitForChild("ArrestingPed")

local connection
local iswalking
local speed = 0

local AutoFarmV2 = {
    enabled = false,
    cache = {},
    ARREST_TIME = 7.5,
    SCAN_DELAY = 6,
    illegalSet = nil,
    thread = nil,
}

local function buildIllegalSet()
    local ok, mod = pcall(function()
        return require(ReplicatedStorage:WaitForChild("Library"):WaitForChild("Pedestrian"):WaitForChild("Inventory"))
    end)
    local set = {}
    if ok and mod and type(mod.illegalItems) == "table" then
        for _, v in ipairs(mod.illegalItems) do
            if type(v) == "string" then
                local s = v:match("^%s*(.-)%s*$")
                set[string.lower(s)] = true
            end
        end
    end
    return set
end

local function findAndArrestPed()
    for _, entity in ipairs(Workspace:GetDescendants()) do
        if entity:IsA("Model") and entity.GetAttribute and entity:GetAttribute("PedIndex") then
            local pedIndex = entity:GetAttribute("PedIndex")
            if pedIndex and not AutoFarmV2.cache[pedIndex] then
                local ok, pedData = pcall(function() return InteractPedestrian:InvokeServer(pedIndex) end)
                if ok and type(pedData) == "table" then
                    if pedData.IsArrested then
                        AutoFarmV2.cache[pedIndex] = true
                    else
                        local inv = (type(pedData.Info) == "table") and pedData.Info[1] or nil
                        if type(inv) == "table" then
                            for _, item in ipairs(inv) do
                                local name = tostring(item):match("^%s*(.-)%s*$")
                                name = string.lower(name)
                                if AutoFarmV2.illegalSet and AutoFarmV2.illegalSet[name] then
                                    pcall(function() ArrestingPed:FireServer(pedIndex) end)
                                    AutoFarmV2.cache[pedIndex] = true
                                    return true
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    return false
end

local Window = Library:Window({
    Title = "[👮] Dispatch: Police Simulator Script",
    Desc = "SolyNot on top",
    Icon = 105059922903197,
    Theme = "Dark",
    Config = {
        Keybind = Enum.KeyCode.LeftControl,
        Size = UDim2.new(0, 500, 0, 400)
    },
    CloseUIButton = {
        Enabled = true,
        Text = "SolyNot"
    }
})

local Tab = Window:Tab({Title = "Main", Icon = "star"}) do
    Tab:Section({Title = "Main"})

    Tab:Code({
        Title = "Click Copy To Join Our Discord",
        Code = "https://discord.gg/PKbEwkAuj8",
    })

    Tab:Button({
        Title = "Be SWAT",
        Desc = "",
        Callback = function()
            SWAT.Value = true
        end
    })

    Tab:Button({
        Title = "Be FBI",
        Desc = "",
        Callback = function()
            FBI.Value = true
        end
    })
    Tab:Section({Title = "Auto Farm"})
    Tab:Code({
        Title = "Fact",
        Code = "you can enabled 2 auto farm",
    })
    Tab:Toggle({
        Title = "Auto Farm",
        Desc = "ONLY FARM XP",
        Value = false,
        Callback = function(value)
            if value then
                connection = CalloutAdded.OnClientEvent:Connect(function(...)
                    local a = {...}
                    JoinCallout:InvokeServer(a[2])
                    SceneArrived:FireServer()
                end)
            else
                if connection then
                    connection:Disconnect()
                    connection = nil
                end
            end
        end
    })

    Tab:Toggle({
        Title = "Auto Farm V2",
        Desc = "auto farm money and exp\nif it doesnt give you money or anything that mean your server has no criminal",
        Value = false,
        Callback = function(enabled)
            if enabled then
                if AutoFarmV2.thread then return end
                AutoFarmV2.enabled = true
                AutoFarmV2.illegalSet = buildIllegalSet()
                AutoFarmV2.thread = task.spawn(function()
                    while AutoFarmV2.enabled do
                        local ok, wasArrested = pcall(findAndArrestPed)
                        if wasArrested then
                            task.wait(AutoFarmV2.ARREST_TIME)
                        else
                            task.wait(AutoFarmV2.SCAN_DELAY)
                        end
                    end
                    AutoFarmV2.thread = nil
                end)
            else
                AutoFarmV2.enabled = false
                AutoFarmV2.thread = nil
                AutoFarmV2.cache = {}
                AutoFarmV2.illegalSet = nil
            end
        end
    })
end

Window:Line()
local plrtab = Window:Tab({Title = "Players", Icon = "eye"}) do
    plrtab:Slider({
        Title = "Set Speed",
        Min = 0,
        Max = 100,
        Bounding = 0,
        Value = 25,
        Callback = function(val)
            speed = val
        end   
    })

    plrtab:Toggle({
        Title = "Toggle WalkSpeed",
        Desc = "change walkspeed",
        Callback = function(value)
            if value then
                iswalking = value
                while iswalking and char and hum and hum.Parent do
                    local delta = RunService.Heartbeat:Wait()
                    if hum.MoveDirection.Magnitude > 0 then
                        char:TranslateBy(hum.MoveDirection * tonumber(speed) * delta * 5)
                    end
                end
            else
                iswalking = false
            end
        end
    })

    plrtab:Button({
        Title = "Super car",
        Desc = "Make Your Car Faster (Way More Faster)",
        Callback = function()
            local setting = require(hum.SeatPart.Parent["A-Chassis Tune"])
            setting.PeakTorque = 1000
            setting.PeakTorqueRPM = 7000
            setting.Redline = 12000
            setting.ShiftRPM = 11500
            setting.RevAccel = 500
            setting.Flywheel = 300
            setting.Turbochargers = 1
            setting.T_Boost = 50
            setting.T_SpoolIncrease = 0.2
            setting.T_SpoolDecrease = 0.05
            setting.FinalDrive = 2.8
            setting.Ratios = {3.0, 0, 2.5, 1.9, 1.4, 1.1, 0.9, 0.7}
            setting.FDiffPower = 50
            setting.RDiffPower = 50
            setting.BrakeForce = 999999
            setting.BrakeBias = 0.5
            setting.ABSEnabled = false
            setting.EBrakeForce = 999999
            setting.PBrakeForce = 999999            
        end
    })
end
