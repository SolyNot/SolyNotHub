local Services = setmetatable({}, {
	__index = function(self, name)
		local ok, svc = pcall(function()
			return cloneref(game:GetService(name));
		end);
		if ok then
			rawset(self, name, svc);
			return svc;
		end;
		error("Invalid Service: " .. tostring(name));
	end
});

local player = Services.Players.LocalPlayer;

local gui = Instance.new("ScreenGui");
gui.ResetOnSpawn = false;
gui.IgnoreGuiInset = true;

local frame = Instance.new("Frame");
frame.Size = UDim2.new(1, 0, 1, 0);
frame.BackgroundColor3 = Color3.fromRGB(15, 15, 15);
frame.BorderSizePixel = 0;
frame.Parent = gui;

local label = Instance.new("TextLabel");
label.AnchorPoint = Vector2.new(0.5, 0.4);
label.Position = UDim2.new(0.5, 0, 0.4, 0);
label.Size = UDim2.new(0.8, 0, 0.25, 0);
label.BackgroundTransparency = 1;
label.TextColor3 = Color3.fromRGB(255, 80, 80);
label.TextScaled = true;
label.Font = Enum.Font.GothamBold;
label.Text = "THIS SCRIPT IS DISCONTINUED\n\nUsing it may cause bugs or result in a ban.";
label.Parent = frame;

local button = Instance.new("TextButton");
button.AnchorPoint = Vector2.new(0.5, 0.65);
button.Position = UDim2.new(0.5, 0, 0.65, 0);
button.Size = UDim2.new(0.25, 0, 0.08, 0);
button.BackgroundColor3 = Color3.fromRGB(40, 40, 40);
button.TextColor3 = Color3.fromRGB(255, 255, 255);
button.TextScaled = true;
button.Font = Enum.Font.Gotham;
button.Text = "Continue Anyway";
button.Parent = frame;

gui.Parent = gethui();

button.MouseButton1Click:Connect(function()
	gui:Destroy();
	loadstring(game:HttpGet("https://raw.githubusercontent.com/SolyNot/temp_piggy/refs/heads/main/temp_chess.luau"))()
end);
