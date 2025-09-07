local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/x2zu/OPEN-SOURCE-UI-ROBLOX/refs/heads/main/X2ZU%20UI%20ROBLOX%20OPEN%20SOURCE/DummyUi-leak-by-x2zu/fetching-main/Tools/Framework.luau"))()
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")

local lplr = Players.LocalPlayer
local char = lplr.Character or lplr.CharacterAdded:Wait()
local hum = char and char:FindFirstChildWhichIsA("Humanoid")

local Network = ReplicatedStorage:WaitForChild("Network")
local CalloutAdded = Network:WaitForChild("CalloutAdded")
local SceneArrived = Network:WaitForChild("SceneArrived")
local JoinCallout = Network:WaitForChild("JoinCallout")
local InteractPedestrian = Network:WaitForChild("InteractPedestrian")
local ArrestingPed = Network:WaitForChild("ArrestingPed")

local connection, iswalking, speed = nil, false, 0

local AutoFarmV2 = {
    enabled = false,
    cache = {},
    ARREST_TIME = 7.5,
    illegalSet = nil,
    thread = nil,
}
pcall(function() game:GetService("StarterPlayer").StarterPlayerScripts.DistanceCheck:Destroy(); lplr.PlayerScripts.DistanceCheck:Destroy() end)
local part = Instance.new("Part")
part.CFrame = CFrame.new(0,5,0)
part.Size = vector.create(10000,1,10000)
part.Transparency = 1
part.Anchored = true
part.Parent = workspace

local function buildIllegalSet()
    local set = {}
    local ok, mod = pcall(require, ReplicatedStorage:WaitForChild("Library"):WaitForChild("Pedestrian"):WaitForChild("Inventory"))
    if ok and mod and type(mod.illegalItems) == "table" then
        for _, v in ipairs(mod.illegalItems) do
            if type(v) == "string" then
                set[string.lower(v:match("^%s*(.-)%s*$"))] = true
            end
        end
    end
    return set
end

local function processNpcs()
    local npcs = {}
    for _, entity in ipairs(Workspace:GetDescendants()) do
        if entity:IsA("Model") and entity:GetAttribute("PedIndex") then
            if entity.Parent == workspace.Peds then continue end
            table.insert(npcs, entity)
        end
    end

    for _, npcModel in ipairs(npcs) do
        if not AutoFarmV2.enabled then return end

        local pedIndex = npcModel:GetAttribute("PedIndex")
        if pedIndex and not AutoFarmV2.cache[pedIndex] then
            local npcRoot = npcModel:FindFirstChild("HumanoidRootPart")
            local playerRoot = lplr.Character and lplr.Character:FindFirstChild("HumanoidRootPart")

            if npcRoot and playerRoot then
                local tween = TweenService:Create(playerRoot, TweenInfo.new(.5),{CFrame = npcRoot.CFrame * CFrame.new(0,-6,0)})
                tween:Play()
                tween.Completed:Wait()
                local ok, pedData = pcall(InteractPedestrian.InvokeServer, InteractPedestrian, pedIndex)
                if ok and type(pedData) == "table" then
                    if pedData.IsArrested then
                        AutoFarmV2.cache[pedIndex] = true
                    else
                        local inv = (type(pedData.Info) == "table") and pedData.Info[1]
                        if inv then
                            local hasIllegalItem = false
                            for _, item in ipairs(inv) do
                                if AutoFarmV2.illegalSet[string.lower(tostring(item))] then
                                    hasIllegalItem = true
                                    break
                                end
                            end

                            if hasIllegalItem then
                                pcall(ArrestingPed.FireServer, ArrestingPed, pedIndex)
                                AutoFarmV2.cache[pedIndex] = true
                                task.wait(AutoFarmV2.ARREST_TIME)
                            end
                        end
                    end
                end
            end
        end
        task.wait()
    end
end

local Window = Library:Window({
    Title = "[👮] Dispatch: Police Simulator Script", Desc = "SolyNot on top", Icon = 105059922903197,
    Theme = "Dark", Config = {Keybind = Enum.KeyCode.LeftControl, Size = UDim2.new(0, 500, 0, 400)},
    CloseUIButton = {Enabled = true, Text = "SolyNot"}
})

local Tab = Window:Tab({Title = "Main", Icon = "star"}) do
    Tab:Section({Title = "Auto Farm"})
    Tab:Code({
        Title = "Click Copy To Join Our Discord",
        Code = "https://discord.gg/PKbEwkAuj8",
    })
    Tab:Code({
        Title = "Fact",
        Code = "you can enabled 2 auto farm",
    })
    Tab:Toggle({
        Title = "Auto Farm (XP Only)", Value = false,
        Callback = function(value)
            if value then
                connection = CalloutAdded.OnClientEvent:Connect(function(...)
                    local a = {...}
                    JoinCallout:InvokeServer(a[2])
                    SceneArrived:FireServer()
                end)
            elseif connection then
                connection:Disconnect()
                connection = nil
            end
        end
    })

    Tab:Toggle({
        Title = "Auto Farm V2 (Money & EXP)", Value = false,
        Callback = function(enabled)
            AutoFarmV2.enabled = enabled
            if enabled then
                if AutoFarmV2.thread then return end
                AutoFarmV2.illegalSet = buildIllegalSet()
                AutoFarmV2.thread = task.spawn(function()
                    while AutoFarmV2.enabled do
                        pcall(processNpcs)
                        task.wait(1)
                    end
                    AutoFarmV2.thread = nil
                end)
            else
                AutoFarmV2.cache = {}
                AutoFarmV2.illegalSet = nil
            end
        end
    })
end

Window:Line()
local plrtab = Window:Tab({Title = "Players", Icon = "eye"}) do
    plrtab:Slider({
        Title = "Set Speed", Min = 0, Max = 100, Bounding = 0, Value = 25,
        Callback = function(val) speed = val end
    })

    plrtab:Toggle({
        Title = "Toggle WalkSpeed",
        Callback = function(value)
            iswalking = value
            if value then
                while iswalking and char and hum and hum.Parent do
                    local delta = RunService.Heartbeat:Wait()
                    if hum.MoveDirection.Magnitude > 0 then
                        char:TranslateBy(hum.MoveDirection * tonumber(speed) * delta * 5)
                    end
                end
            end
        end
    })

    plrtab:Button({
        Title = "Super car",
        Callback = function()
            local setting = require(hum.SeatPart.Parent["A-Chassis Tune"])
            local settings = {PeakTorque=1000, PeakTorqueRPM=7000, Redline=12000, ShiftRPM=11500, RevAccel=500, Flywheel=300, Turbochargers=1, T_Boost=50, T_SpoolIncrease=0.2, T_SpoolDecrease=0.05, FinalDrive=2.8, FDiffPower=50, RDiffPower=50, BrakeForce=999999, BrakeBias=0.5}
            for k, v in pairs(settings) do rawset(setting, k, v) end
        end
    })
end
