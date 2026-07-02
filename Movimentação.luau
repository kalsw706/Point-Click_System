local player = game.Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local MovementController = require(ReplicatedStorage.Modules:WaitForChild("MovementController"))

local camera = workspace.CurrentCamera
local emCombate = false

-- Events
local RE = ReplicatedStorage:WaitForChild("RemoteEvents")
local TurnChanged = RE:WaitForChild("TurnChanged")
local CombatEnded = RE:WaitForChild("CombatEnded")

-- Visual Effect
local function criarEfeitoClique(posicao)
	local anel = Instance.new("Part")
	anel.Shape = Enum.PartType.Cylinder
	anel.Material = Enum.Material.Neon
	anel.Color = Color3.fromRGB(0, 255, 255)
	anel.Transparency = 0.5
	anel.Anchored = true
	anel.CanCollide = false
	anel.CastShadow = false
	anel.Size = Vector3.new(0.1, 0.5, 0.5)
	anel.CFrame = CFrame.new(posicao + Vector3.new(0, 0.1, 0)) * CFrame.Angles(0, 0, math.rad(90))
	anel.Parent = workspace

	local tween = TweenService:Create(
		anel,
		TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		{
			Size = Vector3.new(0.05, 3.5, 3.5),
			Transparency = 1
		}
	)

	tween:Play()
	tween.Completed:Connect(function()
		anel:Destroy()
	end)
end

-- Combat detection
TurnChanged.OnClientEvent:Connect(function(data)
	emCombate = true
	MovementController.Parar(player.Character)
end)

CombatEnded.OnClientEvent:Connect(function()
	emCombate = false
end)

-- movements input
UserInputService.InputBegan:Connect(function(input, gpe)
	if gpe or emCombate or not player.Character then return end

	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		local mousePos = UserInputService:GetMouseLocation()
		local ray = camera:ViewportPointToRay(mousePos.X, mousePos.Y)

		local params = RaycastParams.new()
		params.FilterDescendantsInstances = {player.Character}
		params.FilterType = Enum.RaycastFilterType.Exclude

		local result = workspace:Raycast(ray.Origin, ray.Direction * 1000, params)

		if result then
			criarEfeitoClique(result.Position)

			MovementController.Mover(
				player.Character,
				result.Position,
				16,
				false,
				false
			)
		end
	end
end)