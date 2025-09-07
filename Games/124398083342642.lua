local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/x2zu/OPEN-SOURCE-UI-ROBLOX/refs/heads/main/X2ZU%20UI%20ROBLOX%20OPEN%20SOURCE/DummyUi-leak-by-x2zu/fetching-main/Tools/Framework.luau"))()
local rs, player = game:GetService("ReplicatedStorage"), game:GetService("Players").LocalPlayer
local farming, bv, charConn, chosenCar

local function getHRP()
    return (player.Character or player.CharacterAdded:Wait()):WaitForChild("HumanoidRootPart")
end

local function getCarts()
    local t = {}
    for _, v in ipairs(rs.NewCarts:GetChildren()) do
        t[#t+1] = v.Name
    end
    return t
end

local win = Library:Window({
    Title = "Ride A Cart Down A Slide",
    Desc = "SolyNot on top",
    Icon = 96112338375785,
    Theme = "Dark",
    Config = {Keybind = Enum.KeyCode.LeftControl, Size = UDim2.new(0, 500, 0, 400)},
    CloseUIButton = {Enabled = true, Text = "SolyNot"}
})

do -- Main Tab
    local tab = win:Tab({Title = "Main", Icon = "star"})
    tab:Section({Title = "Auto Farm"})
    tab:Code({Title = "Click Copy To Join Our Discord", Code = "https://discord.gg/PKbEwkAuj8"})

    tab:Toggle({
        Title = "Auto Farm",
        Value = false,
        Callback = function(v)
            farming = v
            if v then
                rs.GetEquipped:InvokeServer("VIP")
                bv = Instance.new("BodyVelocity", getHRP())
                bv.Velocity, bv.MaxForce, bv.P = Vector3.new(0, 1000, 0), Vector3.new(math.huge, math.huge, math.huge), 1e5
                if charConn then charConn:Disconnect() end
                charConn = player.CharacterAdded:Connect(function(c)
                    if farming and bv then bv.Parent = c:WaitForChild("HumanoidRootPart") end
                end)
            else
                if bv then bv:Destroy() bv = nil end
                if charConn then charConn:Disconnect() charConn = nil end
            end
        end
    })
end

do -- Car Tab
    local tab = win:Tab({Title = "Cars", Icon = "car"})
    tab:Section({Title = "Spawn Cars"})

    tab:Dropdown({
        Title = "Choose Car",
        List = getCarts(),
        Value = nil,
        Callback = function(ch) chosenCar = ch end
    })

    tab:Button({
        Title = "Spawn Car",
        Desc = "Click to spawn the selected car",
        Callback = function()
            if chosenCar then
                rs.GetEquipped:InvokeServer(chosenCar)
            end
        end
    })
end
