-- 자체제작 핵 v2 (스핀핵 - 카메라 자유 + 몸만 회전)
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
		FOV = 200,
		TeamCheck = true,
		WallCheck = true,
		FOVVisible = true,
		MaxDistance = 1500,
	},
	ESP = {
		Enabled = false,
		Box = true,
		Name = true,
		Distance = true,
		Health = true,
		TeamCheck = true,
		MaxDistance = 1500,
		Color = Color3.fromRGB(210, 210, 220),
	},
	Player = {
		InfiniteJump = false,
		Noclip = false,
	},
	Spinbot = {
		Enabled = false,
		Speed = 40,
		Range = 30,
		AutoShoot = true,
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
	Name = "벽 체크",
	CurrentValue = true,
	Flag = "WallCheck",
	Callback = function(Value) Settings.Aimbot.WallCheck = Value end,
})

CombatTab:CreateToggle({
	Name = "FOV 원 보이기",
	CurrentValue = true,
	Flag = "FOVVisible",
	Callback = function(Value) Settings.Aimbot.FOVVisible = Value end,
})

CombatTab:CreateSlider({
	Name = "FOV 크기",
	Range = {40, 600},
	Increment = 10,
	CurrentValue = 200,
	Flag = "FOVSize",
	Callback = function(Value) Settings.Aimbot.FOV = Value end,
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
	Name = "무한 점프",
	CurrentValue = false,
	Flag = "InfiniteJump",
	Callback = function(Value) Settings.Player.InfiniteJump = Value end,
})

PlayerTab:CreateToggle({
	Name = "벽통과",
	CurrentValue = false,
	Flag = "Noclip",
	Callback = function(Value) Settings.Player.Noclip = Value end,
})

PlayerTab:CreateSection("스핀핵")

PlayerTab:CreateToggle({
	Name = "스핀핵",
	CurrentValue = false,
	Flag = "Spinbot",
	Callback = function(Value) Settings.Spinbot.Enabled = Value end,
})

PlayerTab:CreateSlider({
	Name = "스핀 속도",
	Range = {10, 80},
	Increment = 1,
	CurrentValue = 40,
	Flag = "SpinSpeed",
	Callback = function(Value) Settings.Spinbot.Speed = Value end,
})

PlayerTab:CreateSlider({
	Name = "감지 거리",
	Range = {10, 80},
	Increment = 1,
	CurrentValue = 30,
	Flag = "SpinRange",
	Callback = function(Value) Settings.Spinbot.Range = Value end,
})

PlayerTab:CreateToggle({
	Name = "범위 안 자동 조준 사격",
	CurrentValue = true,
	Flag = "SpinAutoShoot",
	Callback = function(Value) Settings.Spinbot.AutoShoot = Value end,
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
FOVFrame.Size = UDim2.new(0, 400, 0, 400)
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
	billboard.Size = UDim2.new(0, 160, 0, 42)
	billboard.StudsOffset = Vector3.new(0, 2.7, 0)
	billboard.AlwaysOnTop = true
	billboard.Enabled = false

	local nameLabel = Instance.new("TextLabel")
	nameLabel.Size = UDim2.new(1, 0, 0, 14)
	nameLabel.BackgroundTransparency = 1
	nameLabel.TextColor3 = Settings.ESP.Color
	nameLabel.Font = Enum.Font.GothamBold
	nameLabel.TextSize = 12
	nameLabel.TextStrokeTransparency = 0.45
	nameLabel.Parent = billboard

	local infoLabel = Instance.new("TextLabel")
	infoLabel.Size = UDim2.new(1, 0, 0, 12)
	infoLabel.Position = UDim2.new(0, 0, 0, 14)
	infoLabel.BackgroundTransparency = 1
	infoLabel.TextColor3 = Color3.fromRGB(180, 180, 190)
	infoLabel.Font = Enum.Font.Gotham
	infoLabel.TextSize = 10
	infoLabel.TextStrokeTransparency = 0.45
	infoLabel.Parent = billboard

	local hpBG = Instance.new("Frame")
	hpBG.Size = UDim2.new(0.4, 0, 0, 3)
	hpBG.Position = UDim2.new(0.3, 0, 0, 30)
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
		if not char then return end
		highlight.Parent = char
		local head = char:WaitForChild("Head", 3)
		if head then billboard.Parent = head end
	end

	if player.Character then attach(player.Character) end
	player.CharacterAdded:Connect(attach)
end

local function UpdateESP()
	local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")

	for player, data in pairs(ESPObjects) do
		local char = player.Character
		if not player.Parent or not char then
			data.Highlight.Enabled = false
			data.Billboard.Enabled = false
			continue
		end

		local humanoid = char:FindFirstChildOfClass("Humanoid")
		local root = char:FindFirstChild("HumanoidRootPart")
		local head = char:FindFirstChild("Head")

		if not humanoid or not root or not head or humanoid.Health <= 0 then
			data.Highlight.Enabled = false
			data.Billboard.Enabled = false
			continue
		end

		if Settings.ESP.TeamCheck and player.Team and LocalPlayer.Team and player.Team == LocalPlayer.Team then
			data.Highlight.Enabled = false
			data.Billboard.Enabled = false
			continue
		end

		local dist = 0
		if myRoot then
			dist = (root.Position - myRoot.Position).Magnitude
		end
		if dist > Settings.ESP.MaxDistance then
			data.Highlight.Enabled = false
			data.Billboard.Enabled = false
			continue
		end

		local on = Settings.ESP.Enabled
		data.Highlight.Enabled = on and Settings.ESP.Box
		data.Billboard.Enabled = on

		if on then
			data.NameLabel.Text = Settings.ESP.Name and player.Name or ""
			data.InfoLabel.Text = Settings.ESP.Distance and (math.floor(dist) .. "m") or ""

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

-- 벽 체크
local function IsVisible(targetPart)
	if not Settings.Aimbot.WallCheck then return true end
	local myChar = LocalPlayer.Character
	if not myChar or not myChar:FindFirstChild("Head") then return false end

	local origin = myChar.Head.Position
	local direction = targetPart.Position - origin
	local raycastParams = RaycastParams.new()
	raycastParams.FilterDescendantsInstances = {myChar}
	raycastParams.FilterType = Enum.RaycastFilterType.Exclude

	local result = workspace:Raycast(origin, direction, raycastParams)
	if not result then return true end
	return result.Instance:IsDescendantOf(targetPart.Parent)
end

-- 가장 가까운 적
local function GetClosest()
	local closest, shortest = nil, Settings.Aimbot.FOV
	local myChar = LocalPlayer.Character
	if not myChar or not myChar:FindFirstChild("HumanoidRootPart") then return nil end
	local myRoot = myChar.HumanoidRootPart

	for _, player in pairs(Players:GetPlayers()) do
		if player == LocalPlayer then continue end
		if Settings.Aimbot.TeamCheck and player.Team and LocalPlayer.Team and player.Team == LocalPlayer.Team then continue end

		local char = player.Character
		if not char then continue end
		local humanoid = char:FindFirstChildOfClass("Humanoid")
		local head = char:FindFirstChild("Head")
		local root = char:FindFirstChild("HumanoidRootPart")
		if not humanoid or humanoid.Health <= 0 or not head or not root then continue end

		local dist3d = (root.Position - myRoot.Position).Magnitude
		if dist3d > Settings.Aimbot.MaxDistance then continue end
		if not IsVisible(head) then continue end

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

-- 범위 안 적
local function GetEnemyInRange()
	local myChar = LocalPlayer.Character
	if not myChar or not myChar:FindFirstChild("HumanoidRootPart") then return nil end
	local myRoot = myChar.HumanoidRootPart

	local closest, closestDist = nil, Settings.Spinbot.Range
	for _, player in pairs(Players:GetPlayers()) do
		if player == LocalPlayer then continue end
		if Settings.Aimbot.TeamCheck and player.Team and LocalPlayer.Team and player.Team == LocalPlayer.Team then continue end

		local char = player.Character
		if not char then continue end
		local humanoid = char:FindFirstChildOfClass("Humanoid")
		local head = char:FindFirstChild("Head")
		local root = char:FindFirstChild("HumanoidRootPart")
		if not humanoid or humanoid.Health <= 0 or not head or not root then continue end

		local dist = (root.Position - myRoot.Position).Magnitude
		if dist < closestDist then
			closestDist = dist
			closest = head
		end
	end
	return closest
end

-- 전신 강제
local function ForceFullBody(char)
	if not char then return end
	for _, v in pairs(char:GetDescendants()) do
		if v:IsA("BasePart") or v:IsA("Decal") then
			v.LocalTransparencyModifier = 0
		end
	end
end

-- 무한 점프
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

local spinAngle = 0
local lastShoot = 0

-- 메인 루프
RunService:BindToRenderStep("MainLoop", Enum.RenderPriority.Character.Value, function(dt)
	local size = Settings.Aimbot.FOV * 2
	FOVFrame.Size = UDim2.new(0, size, 0, size)
	FOVFrame.Visible = Settings.Aimbot.Enabled and Settings.Aimbot.FOVVisible

	UpdateESP()

	local char = LocalPlayer.Character
	local root = char and char:FindFirstChild("HumanoidRootPart")
	local humanoid = char and char:FindFirstChildOfClass("Humanoid")

	if Settings.Spinbot.Enabled and root and humanoid then
		ForceFullBody(char)

		-- 캐릭터만 회전 (카메라는 건드리지 않음)
		spinAngle = (spinAngle + Settings.Spinbot.Speed * dt * 15) % 360
		local pos = root.Position
		root.CFrame = CFrame.new(pos) * CFrame.Angles(0, math.rad(spinAngle), 0)

		-- 범위 안 자동 사격
		if Settings.Spinbot.AutoShoot then
			local target = GetEnemyInRange()
			if target and tick() - lastShoot > 0.2 then
				lastShoot = tick()
				local tool = char:FindFirstChildOfClass("Tool")
				if tool then
					local oldCF = Camera.CFrame
					Camera.CFrame = CFrame.new(Camera.CFrame.Position, target.Position)
					pcall(function() tool:Activate() end)
					task.delay(0.03, function()
						if Camera then Camera.CFrame = oldCF end
					end)
				end
			end
		end
	end

	-- 일반 에임봇
	if Settings.Aimbot.Enabled and not Settings.Spinbot.Enabled then
		local target = GetClosest()
		if target then
			Camera.CFrame = CFrame.new(Camera.CFrame.Position, target.Position)
		end
	end

	-- 벽통과
	if Settings.Player.Noclip and char then
		for _, part in pairs(char:GetDescendants()) do
			if part:IsA("BasePart") then
				part.CanCollide = false
			end
		end
	end
end)

Rayfield:Notify({
	Title = "자체제작 핵 v2",
	Content = "스핀핵 업데이트 - by 랭온",
	Duration = 4,
})