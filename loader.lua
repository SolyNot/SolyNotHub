local baseUrl = "https://raw.githubusercontent.com/SolyNot/SolyNotHub/main/Games/"
local url = baseUrl .. tostring(game.PlaceId) .. ".lua"

if not isfile("intro.mp4") then
    writefile("intro.mp4", game:HttpGet("https://github.com/SolyNot/SolyNotHub/raw/main/intro.mp4"))
end

local screenGui = Instance.new("ScreenGui",game:GetService("CoreGui"))

local videoFrame = Instance.new("VideoFrame",screenGui)
videoFrame.Size = UDim2.new(0.5, 0, 0.5, 0)
videoFrame.Position = UDim2.new(0.25, 0, 0.25, 0)
videoFrame.BackgroundColor3 = Color3.new(0, 0, 0)
videoFrame.Video = getcustomasset("intro.mp4")
videoFrame.Looped = false

task.spawn(function()
    while not videoFrame.IsLoaded do
        task.wait()
    end
    videoFrame:Play()
end)
videoFrame.Ended:Connect(function()
    screenGui:Destroy()
end)

local success, scriptContent = pcall(function()
    return game:HttpGet(url)
end)

if success then
    loadstring(scriptContent)()
else
    loadstring(game:HttpGet(baseUrl .. "universal.lua"))()
end
