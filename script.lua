-- 자체제작 핵 v2 (인피니트 점프)
-- by 랭온

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
	Name = "자체제작 핵 v2",
	LoadingTitle = "자체제작 핵 v2",
	LoadingSubtitle = "by 랭온",
	Theme = "Default",
	ConfigurationSaving = { Enabled = false },
	KeySystem = false,
})

local CombatTab = Window:CreateTab("전투", 4483362458)
local VisualTab = Window:CreateTab("시각", 4483362458)
local PlayerTab = Window:CreateTab("플레이어", 4483362458)

local Settings = {
	Aimbot = {
		Enabled = false,
		FOV = 150,
		Smoothness = 0.12,
		TeamCheck = true,
		FOVVisible = true,
	},
	ESP = {
		Enabled = false,
		Box = true,
		Name = true,
		Distance = true,
		Health = true,
		TeamCheck = true,
		Color = Color3.fromRGB(210, 210, 220),
	},
	Player = {
		InfiniteJump = false,
		Noclip = false,
	}
}

-- 전투 탭
CombatTab:CreateSection("에임봇")

CombatTab:CreateToggle({
	Name = "에임봇 켜기",
	CurrentValue = false,
	Flag = "AimbotEnabled",
	Callback = function(Value) Settings.Aimbot.Enabled = Value end,
})

CombatTab:CreateToggle({
	Name = "팀 체크",
	CurrentValue = true,
	Flag = "TeamCheck",
	Callback = function(Value)
		Settings.Aimbot.TeamCheck = Value
		Settings.ESP.TeamCheck = Value
	end,
})

CombatTab:CreateToggle({
	Name = "FOV 원 보이기",
	CurrentValue = true,
	Flag = "FOVVisible",
	Callback = function(Value) Settings.Aimbot.FOVVisible = Value end,
})

CombatTab:CreateSlider({
	Name = "FOV 크기",
	Range = {40, 500},
	Increment = 5,
	CurrentValue = 150,
	Flag = "FOVSize",
	Callback = function(Value) Settings.Aimbot.FOV = Value end,
})

CombatTab:CreateSlider({
	Name = "부드러움",
	Range = {0, 100},
	Increment = 1,
	CurrentValue = 12,
	Flag = "Smoothness",
	Callback = function(Value) Settings.Aimbot.Smoothness = Value / 100 end,
})

-- 시각 탭
VisualTab:CreateSection("ESP")

VisualTab:CreateToggle({
	Name = "ESP 켜기",
	CurrentValue = false,
	Flag = "ESPEnabled",
	Callback = function(Value) Settings.ESP.Enabled = Value end,
})

VisualTab:CreateToggle({
	Name = "박스 ESP",
	CurrentValue = true,
	Flag = "ESPBox",
	Callback = function(Value) Settings.ESP.Box = Value end,
})

VisualTab:CreateToggle({
	Name = "이름 표시",
	CurrentValue = true,
	Flag = "ESPName",
	Callback = function(Value) Settings.ESP.Name = Value end,
})

VisualTab:CreateToggle({
	Name = "거리 표시",
	CurrentValue = true,
	Flag = "ESPDistance",
	Callback = function(Value) Settings.ESP.Distance = Value end,
})

VisualTab:CreateToggle({
	Name = "체력바",
	CurrentValue = true,
	Flag = "ESPHealth",
	Callback = function(Value) Settings.ESP.Health = Value end,
})

-- 플레이어 탭
PlayerTab:CreateSection("이동")

PlayerTab:CreateToggle({
	Name = "인피니트 점프",
	CurrentValue = false,
	Flag = "InfiniteJump",
	Callback = function(Value) Settings.Player.InfiniteJump = Value end,
})

PlayerTab:CreateToggle({
	Name = "노클립",
	CurrentValue = false,
	Flag = "Noclip",
	Callback = function(Value) Settings.Player.Noclip = Value end,
})

-- 서비스
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- FOV 원
local FOVGui = Instance.new("ScreenGui")
FOVGui.Name = "FOVCircleGui"
FOVGui.IgnoreGuiInset = true
FOVGui.ResetOnSpawn = false
FOVGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local FOVFrame = Instance.new("Frame")
FOVFrame.AnchorPoint = Vector2.new(0.5, 0.5)
FOVFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
FOVFrame.Size = UDim2.new(0, 300, 0, 300)
FOVFrame.BackgroundTransparency = 1
FOVFrame.Visible = false
FOVFrame.Parent = FOVGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(1, 0)
corner.Parent = FOVFrame

local stroke = Instance.new("UIStroke")
stroke.Thickness = 2
stroke.Color = Color3.fromRGB(200, 200, 210)
stroke.Transparency = 0.2
stroke.Parent = FOVFrame

-- ESP
local ESPObjects = {}

local function CreateESP(player)
	if player == LocalPlayer then return end

	local highlight = Instance.new("Highlight")
	highlight.FillTransparency = 0.78
	highlight.OutlineTransparency = 0
	highlight.FillColor = Settings.ESP.Color
	highlight.OutlineColor = Settings.ESP.Color
	highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
	highlight.Enabled = false

	local billboard = Instance.new("BillboardGui")
	billboard.Size = UDim2.new(0, 180, 0, 48)
	billboard.StudsOffset = Vector3.new(0, 2.9, 0)
	billboard.AlwaysOnTop = true
	billboard.Enabled = false

	local nameLabel = Instance.new("TextLabel")
	nameLabel.Size = UDim2.new(1, 0, 0, 16)
	nameLabel.BackgroundTransparency = 1
	nameLabel.TextColor3 = Settings.ESP.Color
	nameLabel.Font = Enum.Font.GothamBold
	nameLabel.TextSize = 12
	nameLabel.TextStrokeTransparency = 0.45
	nameLabel.Parent = billboard

	local infoLabel = Instance.new("TextLabel")
	infoLabel.Size = UDim2.new(1, 0, 0, 14)
	infoLabel.Position = UDim2.new(0, 0, 0, 15)
	infoLabel.BackgroundTransparency = 1
	infoLabel.TextColor3 = Color3.fromRGB(180, 180, 190)
	infoLabel.Font = Enum.Font.Gotham
	infoLabel.TextSize = 11
	infoLabel.TextStrokeTransparency = 0.45
	infoLabel.Parent = billboard

	local hpBG = Instance.new("Frame")
	hpBG.Size = UDim2.new(0.55, 0, 0, 3)
	hpBG.Position = UDim2.new(0.225, 0, 0, 34)
	hpBG.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
	hpBG.BorderSizePixel = 0
	hpBG.Parent = billboard
	Instance.new("UICorner", hpBG).CornerRadius = UDim.new(1, 0)

	local hpBar = Instance.new("Frame")
	hpBar.Size = UDim2.new(1, 0, 1, 0)
	hpBar.BackgroundColor3 = Color3.fromRGB(100, 220, 120)
	hpBar.BorderSizePixel = 0
	hpBar.Parent = hpBG
	Instance.new("UICorner", hpBar).CornerRadius = UDim.new(1, 0)

	ESPObjects[player] = {
		Highlight = highlight,
		Billboard = billboard,
		NameLabel = nameLabel,
		InfoLabel = infoLabel,
		HealthBar = hpBar,
		HealthBarBG = hpBG
	}

	local function attach(char)
		highlight.Parent = char
		local head = char:WaitForChild("Head", 3)
		if head then billboard.Parent = head end
	end
	if player.Character then attach(player.Character) end
	player.CharacterAdded:Connect(attach)
end

local function UpdateESP()
	for player, data in pairs(ESPObjects) do
		if not player.Parent or not player.Character then
			data.Highlight.Enabled = false
			data.Billboard.Enabled = false
			continue
		end
		local char = player.Character
		local humanoid = char:FindFirstChildOfClass("Humanoid")
		local root = char:FindFirstChild("HumanoidRootPart")
		if not humanoid or not root or humanoid.Health <= 0 then
			data.Highlight.Enabled = false
			data.Billboard.Enabled = false
			continue
		end
		if Settings.ESP.TeamCheck and player.Team and LocalPlayer.Team and player.Team == LocalPlayer.Team then
			data.Highlight.Enabled = false
			data.Billboard.Enabled = false
			continue
		end

		local on = Settings.ESP.Enabled
		data.Highlight.Enabled = on and Settings.ESP.Box
		data.Billboard.Enabled = on

		if on then
			data.NameLabel.Text = Settings.ESP.Name and player.Name or ""
			local distTxt = ""
			if Settings.ESP.Distance and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
				distTxt = math.floor((root.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude) .. "m"
			end
			data.InfoLabel.Text = distTxt

			if Settings.ESP.Health then
				data.HealthBarBG.Visible = true
				local hp = math.clamp(humanoid.Health / humanoid.MaxHealth, 0, 1)
				data.HealthBar.Size = UDim2.new(hp, 0, 1, 0)
				if hp > 0.6 then
					data.HealthBar.BackgroundColor3 = Color3.fromRGB(80, 200, 120)
				elseif hp > 0.3 then
					data.HealthBar.BackgroundColor3 = Color3.fromRGB(220, 180, 60)
				else
					data.HealthBar.BackgroundColor3 = Color3.fromRGB(220, 70, 70)
				end
			else
				data.HealthBarBG.Visible = false
			end
		end
	end
end

-- 에임봇
local function GetClosest()
	local closest, shortest = nil, Settings.Aimbot.FOV
	local myChar = LocalPlayer.Character
	if not myChar or not myChar:FindFirstChild("HumanoidRootPart") then return nil end

	for _, player in pairs(Players:GetPlayers()) do
		if player == LocalPlayer then continue end
		if Settings.Aimbot.TeamCheck and player.Team and LocalPlayer.Team and player.Team == LocalPlayer.Team then continue end

		local char = player.Character
		if not char then continue end
		local humanoid = char:FindFirstChildOfClass("Humanoid")
		local head = char:FindFirstChild("Head")
		if not humanoid or humanoid.Health <= 0 or not head then continue end

		local pos, onScreen = Camera:WorldToViewportPoint(head.Position)
		if not onScreen then continue end

		local dist = (Vector2.new(pos.X, pos.Y) - Camera.ViewportSize / 2).Magnitude
		if dist < shortest then
			shortest = dist
			closest = head
		end
	end
	return closest
end

-- 인피니트 점프
UserInputService.JumpRequest:Connect(function()
	if Settings.Player.InfiniteJump then
		local char = LocalPlayer.Character
		if char then
			local humanoid = char:FindFirstChildOfClass("Humanoid")
			if humanoid then
				humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
			end
		end
	end
end)

-- 초기화
for _, p in pairs(Players:GetPlayers()) do CreateESP(p) end
Players.PlayerAdded:Connect(CreateESP)
Players.PlayerRemoving:Connect(function(p)
	if ESPObjects[p] then
		pcall(function() ESPObjects[p].Highlight:Destroy() end)
		pcall(function() ESPObjects[p].Billboard:Destroy() end)
		ESPObjects[p] = nil
	end
end)

-- 메인 루프
RunService:BindToRenderStep("AimbotFix", Enum.RenderPriority.Camera.Value + 1, function()
	local size = Settings.Aimbot.FOV * 2
	FOVFrame.Size = UDim2.new(0, size, 0, size)
	FOVFrame.Visible = Settings.Aimbot.Enabled and Settings.Aimbot.FOVVisible

	UpdateESP()

	-- 에임봇
	if Settings.Aimbot.Enabled and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
		local target = GetClosest()
		if target then
			local goal = CFrame.new(Camera.CFrame.Position, target.Position)
			local smooth = math.clamp(1 - Settings.Aimbot.Smoothness, 0.05, 1)
			Camera.CFrame = Camera.CFrame:Lerp(goal, smooth)
		end
	end

	-- 노클립
	if Settings.Player.Noclip and LocalPlayer.Character then
		for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
			if part:IsA("BasePart") then
				part.CanCollide = false
			end
		end
	end
end)

Rayfield:Notify({
	Title = "자체제작 핵 v2",
	Content = "인피니트 점프 추가 - by 랭온",
	Duration = 4,
})