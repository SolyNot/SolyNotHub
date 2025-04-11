local Main = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

-- Services
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = workspace

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local RootPart = Character:WaitForChild("HumanoidRootPart")
Character:FindFirstChild("FallDamage"):Destroy()
LocalPlayer.CharacterAdded:Connect(function(newCharacter)
    newCharacter:FindFirstChild("FallDamage"):Destroy()
    Character = newCharacter
    Humanoid = newCharacter:WaitForChild("Humanoid")
    RootPart = newCharacter:WaitForChild("HumanoidRootPart")
    isSpeeding = false
    SpeedLoop = false
    if killauraConnection then
        killauraConnection:Disconnect()
        killauraConnection = nil
        killauraEnabled = false
    end
    if Humanoid then
        Humanoid.Sit = false
    end
end)

-- Configuration Variables
local windowSize = UserInputService.TouchEnabled and UDim2.fromOffset(320, 400) or UDim2.fromOffset(580, 460)
local killauraEnabled = false
local WalkSpeed = 50
local isSpeeding = false
local killauraConnection = nil
local SpeedLoop = false

local window = Main:CreateWindow({
    Title = "SolyNot Hub",
    SubTitle = "by SolyNot",
    TabWidth = 160,
    Size = windowSize,
    Acrylic = true,
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.LeftControl
})

local Tabs = {
    Main = window:AddTab({ Title = "Main", Icon = "box" }),
    Settings = window:AddTab({ Title = "Settings", Icon = "settings" })
}

-- Functions
local function checkDistance()
    if not killauraEnabled or not Character or not RootPart or not Humanoid or Humanoid.Health <= 0 then return end
    local localPosition = RootPart.Position
    local localFists = Character:FindFirstChild("Fists")
    if not localFists then return end
    local hitRemote = ReplicatedStorage:FindFirstChild("Hit")
    if not hitRemote then warn("SolyNot Hub: Could not find 'Hit' RemoteEvent!"); return end

    for _, targetPlayer in pairs(Players:GetPlayers()) do
        if targetPlayer ~= LocalPlayer and targetPlayer.Character then
            local targetRoot = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
            local targetHead = targetPlayer.Character:FindFirstChild("Head")
            local targetHumanoid = targetPlayer.Character:FindFirstChild("Humanoid")
            if targetRoot and targetHead and targetHumanoid and targetHumanoid.Health > 0 then
                if (localPosition - targetRoot.Position).Magnitude <= 10 then
                    local args = {[1]=targetHead,[2]=targetPlayer.Character,[3]=100,[4]=100,[5]=100,[6]=100,[7]=localFists}
                    pcall(function() hitRemote:FireServer(unpack(args)) end) 
                end
            end
        end
    end
end

local function setupFlightState()
    if not Humanoid then return false end
    return true
end

local function stopFlightState()
    if Humanoid then
        Humanoid.Sit = false
        Humanoid.PlatformStand = false
    end
end

window:SelectTab(1)

Tabs.Main:AddParagraph({
    Title = "Important",
    Content = "Equip the 'Fists' tool to use Killaura."
})

Tabs.Main:AddToggle("KillauraToggle", {
    Title = "Killaura",
    Default = false,
    Callback = function(value)
        killauraEnabled = value
        if killauraEnabled then
            if not Character or not Humanoid or Humanoid.Health <= 0 then
                warn("SolyNot Hub: Cannot enable Killaura, invalid character state.")
                killauraEnabled = false
                return
            end
            if killauraConnection then killauraConnection:Disconnect() end
            killauraConnection = RunService.Heartbeat:Connect(checkDistance)
             Main:Notify({ Title = "Killaura", Content = "Enabled", Duration = 2 })
        else
            if killauraConnection then
                killauraConnection:Disconnect()
                killauraConnection = nil
            end
             Main:Notify({ Title = "Killaura", Content = "Disabled", Duration = 2 })
        end
    end
})

Tabs.Main:AddParagraph({
    Title = "Important #2",
    Content = "Do not press spacebar while speeding, you will get lagback."
})

Tabs.Main:AddParagraph({
    Title = "Important #3",
    Content = "Keep touching ground to avoid lagback."
})

Tabs.Main:AddToggle("FlyToggle", {
    Title = "Speed (Bypass anti-cheat", Default = false,
    Callback = function(value)
        isSpeeding = value
        if isSpeeding and not SpeedLoop then
            if not Character or not Humanoid or Humanoid.Health <= 0 or not RootPart then
                 Main:Notify({ Title = "Fly", Content = "Cannot fly, invalid character state.", Duration = 3 })
                 isFlying = false
                 return
            end

            if not setupFlightState() then
                Main:Notify({ Title = "Fly Error", Content = "Failed to set flight state.", Duration = 3 })
                isFlying = false
                return
            end

            SpeedLoop = true
            Main:Notify({ Title = "Fly", Content = "Enabled (CFrame)", Duration = 2 })
            task.spawn(function()
                local cam = Workspace.CurrentCamera
                Humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated, false)
                Humanoid.Sit = true

                while isSpeeding do
                    if not Character or not Humanoid or Humanoid.Health <= 0 or not RootPart then
                        isSpeeding = false
                        break
                    end
                    
                    local moveDir = Vector3.new(0, 0, 0)
                    local currentCamCF = cam.CFrame
                    
                    if UserInputService:IsKeyDown(Enum.KeyCode.W) then 
                        moveDir = moveDir + currentCamCF.LookVector 
                    end
                    if UserInputService:IsKeyDown(Enum.KeyCode.S) then 
                        moveDir = moveDir - currentCamCF.LookVector 
                    end
                    if UserInputService:IsKeyDown(Enum.KeyCode.A) then 
                        moveDir = moveDir - currentCamCF.RightVector 
                    end
                    if UserInputService:IsKeyDown(Enum.KeyCode.D) then 
                        moveDir = moveDir + currentCamCF.RightVector 
                    end
                    if UserInputService:IsKeyDown(Enum.KeyCode.Space) then 
                        moveDir = moveDir + Vector3.new(0, 1, 0) 
                    end
                    if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) or 
                       UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then 
                        moveDir = moveDir - Vector3.new(0, 1, 0) 
                    end
                    
                    local deltaTime = RunService.Heartbeat:Wait()
                    
                    if moveDir.Magnitude > 0.01 then
                        moveDir = moveDir.Unit
                        local moveStep = moveDir * WalkSpeed * deltaTime
                        local targetPos = RootPart.CFrame.Position + moveStep
                        
                        local lookAt = targetPos + moveDir * Vector3.new(1, 0, 1)
                        local newCFrame = CFrame.new(targetPos, lookAt)
                        
                        RootPart.CFrame = CFrame.new(targetPos) * CFrame.Angles(0, newCFrame.Rotation.Y, 0)
                    end
                    RootPart.Velocity = Vector3.new(0, 0, 0)
                end
                Humanoid.Sit = false
                Humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated, true)
                stopFlightState()
                SpeedLoop = false
                Main:Notify({ Title = "Fly", Content = "Disabled", Duration = 2 })
            end)

        elseif not isSpeeding and SpeedLoop then
            return
        end
    end
})

Tabs.Main:AddSlider("WalkSpeedSlider", {
    Title = "WalkSpeed (Studs/sec)",
    Default = WalkSpeed,
    Min = 10,
    Max = 500,
    Rounding = 0,
    Compact = false,
    Callback = function(value)
        WalkSpeed = value
    end
})

SaveManager:SetLibrary(Main)
InterfaceManager:SetLibrary(Main)
InterfaceManager:BuildInterfaceSection(Tabs.Settings)
SaveManager:BuildConfigSection(Tabs.Settings)
