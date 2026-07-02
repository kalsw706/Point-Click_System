---CameraSystem
---StarterCharacterScripts
---LocalScript



local UserInputService = game:GetService("UserInputService")


local RunService = game:GetService("RunService")
local ContextActionService = game:GetService("ContextActionService")
local player = game.Players.LocalPlayer
local camera = workspace.CurrentCamera

-- 1. CONFIG
local PlayerScripts = player:WaitForChild("PlayerScripts")
local Controls = require(PlayerScripts:WaitForChild("PlayerModule")):GetControls()
Controls:Disable() 

camera.CameraType = Enum.CameraType.Scriptable

local function anularBotaoDireito() return Enum.ContextActionResult.Sink end
ContextActionService:BindAction("BloquearGiroNativo", anularBotaoDireito, false, Enum.UserInputType.MouseButton2)

-- 2. Variables configs
local zoomMin, zoomMax = 8, 50
local RAIO_MAXIMO = 90      
local sensibilidadeMouse = 0.5
local suavidadeGeral = 0.12   -- Lerp speed
local suavidadeZoom = 0.12   -- Lerp speed for zoom
local velocidadeWASD = 1.0    -- WASD speed

-- Variables "target" (which the camera wants to reach)
local zoomAlvo = 45
local anguloAlvo = 0 
local inclinacaoAlvo = -60 
local posLivreAlvo = Vector3.new(0, 45, 0)

-- Variables "lerp" (where the camera is right now)
local zoomSuave = 45
local anguloSuave = 0
local inclinacaoSuave = -60
local posLivreSuave = posLivreAlvo

local seguindoPersonagem = true

-- 3. Zoom Input
UserInputService.InputChanged:Connect(function(input, gpe)
	if gpe then return end
	if input.UserInputType == Enum.UserInputType.MouseWheel then
		zoomAlvo = math.clamp(zoomAlvo - (input.Position.Z * 12), zoomMin, zoomMax)
	end
end)

-- 4. Press space to change between "Follow" and "Free" camera
UserInputService.InputBegan:Connect(function(input, gpe)
	if gpe then return end
	if input.KeyCode == Enum.KeyCode.Space then
		seguindoPersonagem = not seguindoPersonagem
		if not seguindoPersonagem then
			posLivreAlvo = camera.CFrame.Position
			posLivreSuave = posLivreAlvo
		end
	end
end)

-- 5. Render Apply
RunService.RenderStepped:Connect(function()
	local char = player.Character
	local root = char and char:FindFirstChild("HumanoidRootPart")
	if not root then return end

	-- --- Apply smoothness---
	zoomSuave = zoomSuave + (zoomAlvo - zoomSuave) * suavidadeGeral
	anguloSuave = anguloSuave + (anguloAlvo - anguloSuave) * suavidadeGeral
	inclinacaoSuave = inclinacaoSuave + (inclinacaoAlvo - inclinacaoSuave) * suavidadeGeral

	-- 
	if UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton3) then
		local delta = UserInputService:GetMouseDelta()
		anguloAlvo = anguloAlvo - (delta.X * sensibilidadeMouse)
		inclinacaoAlvo = math.clamp(inclinacaoAlvo - (delta.Y * sensibilidadeMouse), -80, -10)
		UserInputService.MouseBehavior = Enum.MouseBehavior.LockCurrentPosition
	else
		if not UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
			UserInputService.MouseBehavior = Enum.MouseBehavior.Default
		end
	end

	if UserInputService:IsKeyDown(Enum.KeyCode.Q) then anguloAlvo = anguloAlvo + 2 end
	if UserInputService:IsKeyDown(Enum.KeyCode.E) then anguloAlvo = anguloAlvo - 2 end

	local rotacaoHorizontal = CFrame.Angles(0, math.rad(anguloSuave), 0)
	local inclinacaoVertical = CFrame.Angles(math.rad(inclinacaoSuave), 0, 0)

	if seguindoPersonagem then
		-- Follow cam mode
		local radInclina = math.rad(inclinacaoSuave)
		local offsetZ = zoomSuave * math.cos(radInclina)
		local offsetY = -zoomSuave * math.sin(radInclina)

		local posicaoDesejada = root.Position + (rotacaoHorizontal * Vector3.new(0, offsetY, offsetZ))
		camera.CFrame = CFrame.lookAt(posicaoDesejada, root.Position)
	else
		-- Free cam mode (WASD)
		local moveDir = Vector3.new(0,0,0)
		if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDir += (camera.CFrame.LookVector * Vector3.new(1,0,1)) end
		if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDir -= (camera.CFrame.LookVector * Vector3.new(1,0,1)) end
		if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDir -= camera.CFrame.RightVector end
		if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDir += camera.CFrame.RightVector end

		if moveDir.Magnitude > 0 then
			posLivreAlvo = posLivreAlvo + (moveDir.Unit * velocidadeWASD)
		end

		-- Raidius limit
		local diff = (posLivreAlvo - root.Position)
		if diff.Magnitude > RAIO_MAXIMO then
			posLivreAlvo = root.Position + (diff.Unit * RAIO_MAXIMO)
		end

		-- Wasd lerp
		posLivreSuave = posLivreSuave:Lerp(posLivreAlvo, suavidadeGeral)

		local posicaoFinal = Vector3.new(posLivreSuave.X, zoomSuave, posLivreSuave.Z)
		camera.CFrame = CFrame.new(posicaoFinal) * rotacaoHorizontal * inclinacaoVertical
	end
end)