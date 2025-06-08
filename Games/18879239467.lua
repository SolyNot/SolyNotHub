local Library = loadstring(Game:HttpGet("https://raw.githubusercontent.com/bloodball/-back-ups-for-libs/main/wizard"))()
local Window = Library:NewWindow("Main")

local section = Window:NewSection("OP")

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

local Swing = ReplicatedStorage.Remotes:WaitForChild("Swing")

-- kill aura stuff
local killAuraEnabled = false

section:CreateToggle("Kill Aura", function(value)
    killAuraEnabled = value
end)

task.spawn(function()
    while task.wait() do
        if killAuraEnabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            for _, targetPlayer in pairs(Players:GetPlayers()) do
                if targetPlayer ~= LocalPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") and targetPlayer.Character:FindFirstChildOfClass("Humanoid").Health > 0 then
                    
                    local localRoot = LocalPlayer.Character.HumanoidRootPart
                    local targetRoot = targetPlayer.Character.HumanoidRootPart
                    local dist = (localRoot.Position - targetRoot.Position).Magnitude
                    
                    if dist <= 12 then -- attack range
                        local combatObject = LocalPlayer.Character:FindFirstChild("Combat")
                        local targetLimb = targetPlayer.Character:FindFirstChild("Left Arm")
                        
                        if combatObject and targetLimb then
                            Swing:FireServer(combatObject, "Hit", targetLimb)
                        end
                    end
                end
            end
        end
    end
end)

-- speed hack
local customWalkSpeedEnabled = false
local currentSpeed = 16

section:CreateToggle("Enable Custom Speed", function(value)
    customWalkSpeedEnabled = value
end)

section:CreateSlider("WalkSpeed", 16, 100, 16, false, function(value)
    currentSpeed = value
end)

RunService.Heartbeat:Connect(function(deltaTime)
    if not customWalkSpeedEnabled then return end

    local character = LocalPlayer.Character
    if not character then return end
    
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    local rootPart = character:FindFirstChild("HumanoidRootPart")

    if not humanoid or not rootPart then return end

    if humanoid.MoveDirection.Magnitude > 0 then
        local moveVector = humanoid.MoveDirection * currentSpeed * deltaTime
        rootPart.CFrame = rootPart.CFrame + moveVector
    end
end)
