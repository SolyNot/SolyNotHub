local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/x2zu/OPEN-SOURCE-UI-ROBLOX/refs/heads/main/X2ZU%20UI%20ROBLOX%20OPEN%20SOURCE/DummyUi-leak-by-x2zu/fetching-main/Tools/Framework.luau"))()
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local lplr = Players.LocalPlayer
local char = lplr.Character or lplr.CharacterAdded:Wait()
local hum = char and char:FindFirstChildWhichIsA("Humanoid")

local SWAT = lplr.Playerdata.SWAT
local FBI = lplr.Playerdata.FBI

local Network = ReplicatedStorage.Network
local CalloutAdded = Network.CalloutAdded
local SceneArrived = Network.SceneArrived
local JoinCallout = Network.JoinCallout

local connection
local iswalking
local speed: number = 0

local function getcurrentcar()
    return hum.SeatPart.Parent
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
end

Window:Line()
local plrtab = Window:Tab({Title = "Players", Icon = "eye"}) do
    plrtab:Slider({
        Title = "Set WalkSpeed",
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
            local setting = getcurrentcar()["A-Chassis Tune"]
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
