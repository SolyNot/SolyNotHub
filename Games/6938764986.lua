--credit to Marco8642 for logic i am too lazy to make
local Players = game:GetService("Players")
local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local Player = Players.LocalPlayer

local contractsEnabled = false
local currentPlaneName = "Cessna Skyhawk"
local mainLoopThread = nil
local landingPad = nil

local function hasContract()
    local contractsFolder = Player:FindFirstChild("Contracts")
    if not contractsFolder then return nil end
    for _, contract in ipairs(contractsFolder:GetChildren()) do
        local isSelected = contract:FindFirstChild("IsSelected")
        if isSelected and isSelected.Value == true then
            return contract
        end
    end
    return nil
end

local function findMarker()
    local targetMarker = nil
    for _, descendant in ipairs(Workspace:GetDescendants()) do
        if descendant.Name == "LocationMarker" then
            targetMarker = descendant
        end
    end
    return targetMarker
end

local function createLandingPlatform()
    if landingPad and landingPad.Parent then return end
    local character = Player.Character
    local rootPart = character and character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return end
    local newPad = Instance.new("Part", Workspace)
    newPad.Name = "justanormalpart"
    newPad.Anchored = true
    newPad.CanCollide = true
    newPad.Size = Vector3.new(10000, 10, 10000)
    newPad.Transparency = 0.8
    newPad.Position = rootPart.Position + Vector3.new(0, 5000, 0)
    landingPad = newPad
end

local function destroyLandingPlatform()
    if landingPad then
        landingPad:Destroy()
        landingPad = nil
    end
end

local function updateCurrentPlaneName()
    if Player.Character then
        local humanoid = Player.Character:FindFirstChildOfClass("Humanoid")
        if humanoid and humanoid.SeatPart then
            local seatPart = humanoid.SeatPart
            local planeModel = seatPart.Parent and seatPart.Parent.Parent
            if planeModel and planeModel:IsA("Model") then
                 currentPlaneName = planeModel.Name
            end
        end
    end
end

--pls dont look at it
local function mainTask()
    local lastTargetParent = nil
    while contractsEnabled do
        task.wait(0.1)
        local success, err = pcall(function()
            local character = Player.Character
            local humanoid = character and character:FindFirstChildOfClass("Humanoid")
            if not humanoid then return end
            local currentContract = hasContract()
            if humanoid.SeatPart then
                local planeModel = humanoid.SeatPart.Parent and humanoid.SeatPart.Parent.Parent
                local primaryPart = planeModel and planeModel.PrimaryPart
                if not planeModel or not primaryPart then return end
                currentPlaneName = planeModel.Name
                if currentContract then
                    local targetMarker = findMarker()
                    if targetMarker then
                        local targetPosition = nil
                        local targetParent = nil
                        if targetMarker.ClassName == "Part" and targetMarker.Parent and targetMarker.Parent:FindFirstChild("Highlight") then
                             targetPosition = targetMarker.Parent.Highlight.WorldPivot
                             targetParent = targetMarker.Parent
                        elseif targetMarker:IsA("BasePart") then
                             targetPosition = targetMarker.CFrame * CFrame.new(0, targetMarker.Size.Y / 2, 0)
                             targetParent = targetMarker.Parent
                        else
                            return
                        end
                        local distance = character and character:FindFirstChild("HumanoidRootPart") and (character.HumanoidRootPart.Position - targetPosition.Position).Magnitude or math.huge
                        if distance > 70 then
                            if targetParent == lastTargetParent then
                            end
                            primaryPart.Anchored = false
                            local ts = TweenService
                            local tInfoUp = TweenInfo.new(0, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut)
                            local tValueUp = Instance.new("CFrameValue")
                            tValueUp.Value = planeModel:GetPrimaryPartCFrame()
                            local connUp
                            connUp = tValueUp.Changed:Connect(function() planeModel:SetPrimaryPartCFrame(tValueUp.Value) end)
                            local tweenUp = ts:Create(tValueUp, tInfoUp, {Value = primaryPart.CFrame + Vector3.new(0, 1000, 0)})
                            tweenUp:Play()
                            tweenUp.Completed:Wait()
                            connUp:Disconnect()
                            tValueUp:Destroy()
                            local tInfoAcross = TweenInfo.new(5, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut)
                            local tValueAcross = Instance.new("CFrameValue")
                            tValueAcross.Value = planeModel:GetPrimaryPartCFrame()
                            local connAcross
                            connAcross = tValueAcross.Changed:Connect(function() planeModel:SetPrimaryPartCFrame(tValueAcross.Value) end)
                            local tweenAcross = ts:Create(tValueAcross, tInfoAcross, {Value = targetPosition * CFrame.new(0, 1000, 0)})
                            tweenAcross:Play()
                            tweenAcross.Completed:Wait()
                            connAcross:Disconnect()
                            tValueAcross:Destroy()
                            local tInfoDown = TweenInfo.new(0, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut)
                            local tValueDown = Instance.new("CFrameValue")
                            tValueDown.Value = planeModel:GetPrimaryPartCFrame()
                            local connDown
                            connDown = tValueDown.Changed:Connect(function() planeModel:SetPrimaryPartCFrame(tValueDown.Value) end)
                            local tweenDown = ts:Create(tValueDown, tInfoDown, {Value = targetPosition})
                            tweenDown:Play()
                            tweenDown.Completed:Wait()
                            connDown:Disconnect()
                            tValueDown:Destroy()
                            if landingPad then
                                landingPad.CFrame = CFrame.new(primaryPart.Position.X, targetPosition.Position.Y - 30, primaryPart.Position.Z)
                            end
                            primaryPart.Anchored = true
                            local anchorStartTime = tick()
                            repeat task.wait(0.1)
                            until tick() - anchorStartTime > 1.8 or not contractsEnabled
                            primaryPart.Anchored = false
                            lastTargetParent = targetParent
                        end
                    else
                        lastTargetParent = nil
                    end
                else
                    local spawnEvent = ReplicatedStorage:FindFirstChild("SpawnVehicle")
                    local spawners = Workspace:FindFirstChild("Spawners")
                    if spawnEvent and spawners then
                         pcall(spawnEvent.FireServer, spawnEvent, currentPlaneName, spawners, "Original", true)
                         task.wait(0.5)
                    end
                    lastTargetParent = nil
                end
            else
                lastTargetParent = nil
                if currentContract then
                     local spawnEvent = ReplicatedStorage:FindFirstChild("SpawnVehicle")
                     local spawners = Workspace:FindFirstChild("Spawners")
                     if spawnEvent and spawners then
                          pcall(spawnEvent.FireServer, spawnEvent, currentPlaneName, spawners, "Original", true)
                          task.wait(1.5)
                     end
                end
            end
        end)
        if not success then
        end
    end
    destroyLandingPlatform()
    mainLoopThread = nil
end

local Window = Fluent:CreateWindow({
    Title = "Airplane Simulator",
    SubTitle = "by SolyNot",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = true,
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.LeftControl
})

local Tabs = {
    Main = Window:AddTab({ Title = "Main", Icon = "box" }),
    Settings = Window:AddTab({ Title = "Settings", Icon = "settings" })
}

Tabs.Main:AddParagraph({
    Title = "IMPORTANT",
    Content = "SELECT CONTRACTS FIRST DUMBASS"
})
Tabs.Main:AddToggle("Auto Contracts", {
    Title = "Auto Contracts",
    Default = false, 
    Callback = function(state)
        contractsEnabled = state
        if contractsEnabled then
            updateCurrentPlaneName()
            createLandingPlatform()
            if not mainLoopThread or coroutine.status(mainLoopThread) == "dead" then
                mainLoopThread = task.spawn(mainTask)
            end
        else
            destroyLandingPlatform()
        end
    end
})

destroyLandingPlatform()
Window:SelectTab(1)
SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)
InterfaceManager:BuildInterfaceSection(Tabs.Settings)
SaveManager:BuildConfigSection(Tabs.Settings)
