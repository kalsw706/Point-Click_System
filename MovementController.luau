local PathfindingService = game:GetService("PathfindingService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

-- ReplicatedStorage/MovementController.lua

local MovementController = {}

local SETTINGS = {
	AGENT_RADIUS = 2.2,
	WAYPOINT_SPACING = 4.0,
	PROXIMIDADE_INTERMEDIARIA = 4.5, 
	PROXIMIDADE_FINAL = 1.5,
	DISTANCIA_FRENAGEM = 8
}

local path = PathfindingService:CreatePath({
	AgentRadius = SETTINGS.AGENT_RADIUS,
	AgentCanJump = true,
	WaypointSpacing = SETTINGS.WAYPOINT_SPACING
})

local currentMoveID = 0

function MovementController.Mover(model, destino, velocidade, travarAoChegar, ehSkill)
	print("--- [MODULO] Iniciando Mover. Skill: " .. tostring(ehSkill))

	local hum = model:FindFirstChild("Humanoid")
	local root = model:FindFirstChild("HumanoidRootPart")
	if not hum or not root then 
		print("[MODULO] Error: character missing Humanoid or RootPart.")
		return 
	end

	currentMoveID += 1
	local meuID = currentMoveID
	local velMax = velocidade or 16

	-- Small delay to synchronize physics when the server takes ownership
	task.wait(0.05)

	hum.WalkSpeed = velMax
	hum.AutoRotate = true 

	local success, _ = pcall(function()
		path:ComputeAsync(root.Position, destino)
	end)

	print("[MODULO] Status Pathfinding: " .. tostring(path.Status))

	if success and path.Status == Enum.PathStatus.Success then
		local waypoints = path:GetWaypoints()
		print("[MODULO] Creating path: " .. #waypoints .. " points.")

		for i = 2, #waypoints do
			if meuID ~= currentMoveID then 
				print("[MODULO] Movement interrupted by a new command..")
				break 
			end

			local wp = waypoints[i]
			hum:MoveTo(wp.Position)

			if wp.Action == Enum.PathWaypointAction.Jump then
				hum.Jump = true
			end

			-- -- Braking adjustment for skill movement
			local distFrenagem = ehSkill and 2 or SETTINGS.DISTANCIA_FRENAGEM
			local velMinima = ehSkill and 15 or 5

			if i >= #waypoints - 1 then
				task.spawn(function()
					while meuID == currentMoveID and i >= #waypoints - 1 do
						local distFinal = (root.Position - waypoints[#waypoints].Position).Magnitude
						if distFinal < distFrenagem then
							hum.WalkSpeed = math.max(velMinima, velMax * (distFinal / distFrenagem))
						end
						RunService.Heartbeat:Wait()
					end
				end)
			end

			local distAlvo = (i == #waypoints) and SETTINGS.PROXIMIDADE_FINAL or SETTINGS.PROXIMIDADE_INTERMEDIARIA
			repeat
				RunService.Heartbeat:Wait()
			until (root.Position - wp.Position).Magnitude <= distAlvo or meuID ~= currentMoveID
		end
	else
		print("[MODULO] Pathfinding failed. Using fallback movement.")
		if ehSkill then hum:MoveTo(destino) end
	end

	if meuID == currentMoveID then
		hum.WalkSpeed = travarAoChegar and 0 or 16
		print("[MODULO] Movimento completed.")
	end
end

function MovementController.Parar(model)
	currentMoveID += 1
	local hum = model:FindFirstChild("Humanoid")
	if hum then hum:MoveTo(model.PrimaryPart.Position) end
end

return MovementController