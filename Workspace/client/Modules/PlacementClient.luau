local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local StructurePlace = ReplicatedStorage.Events.StructurePlace


local PlacementClient = {}


local positionConnection
local structureRotation = 0
local notColliding = false
local previewModel_CFrame = nil

-- Rotate Keybind
UIS.InputBegan:Connect(function(input, processed)
	if not processed and input.KeyCode == Enum.KeyCode.R then
		structureRotation += 90
	end
end)


local function setChildrenColor(model, color)
	for _, part in ipairs(model:GetDescendants()) do
		if part:IsA("Part") then
			part.BrickColor = BrickColor.new(color)
		end
	end
end

function PlacementClient.StartPlacement(player, structureName, onResult)
	-- Start creating a ghost model at the mouse CFrame
	-- Constantly keep the ghost updated at the mouse CFrame
	-- Check for collisions, wrong orientations
	
	local previewModel = ReplicatedStorage.StructureBaseModels:FindFirstChild(structureName):Clone()
	previewModel.Parent = workspace
	
	for _, parts in ipairs(previewModel:GetDescendants()) do
		if parts:IsA("Part") then
			parts.CanCollide = false
			if parts.Name ~= "CenterPart" then
				parts.Transparency = 0.5
			end
		end
	end
	
	local mouse = player:GetMouse()
	mouse.TargetFilter = previewModel
	
	-- Preview at mouse.Hit.Position
	local connection
	connection = RunService.PreRender:Connect(function()
		
		if previewModel and previewModel.Parent then
			
			local centerPart = previewModel:WaitForChild("CenterPart")
			
			local yOffset = centerPart.Size.Y / 2
			local flooredHitPos = Vector3.new(
				math.round(mouse.Hit.Position.X) + 0.5,
				math.round(mouse.Hit.Position.Y + yOffset),
				math.round(mouse.Hit.Position.Z) + 0.5
			)
			
			previewModel_CFrame = CFrame.new(flooredHitPos) * CFrame.Angles(0, math.rad(structureRotation), 0)
			
			previewModel:PivotTo(previewModel_CFrame)
			
			local params = OverlapParams.new()
			params.FilterType = Enum.RaycastFilterType.Exclude
			params.ExcludeInstances = {previewModel, workspace.SpawnParts.Base}
			
			local prevParts = workspace:GetPartsInPart(centerPart, params)
			
			if #prevParts > 0 then
				setChildrenColor(previewModel, "Really red")
				notColliding = false
			else
				setChildrenColor(previewModel, "Really green")
				notColliding = true
			end
			
		else
			connection:Disconnect()
		end
	end)
	
	-- When user clicks for placement -> send server request for validation
	local inputConnection
	inputConnection = UIS.InputBegan:Connect(function(input, processed)
		if previewModel and previewModel.Parent then
			if processed or notColliding ~= true then return end
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				local success, request = StructurePlace:InvokeServer(structureName, previewModel_CFrame, structureRotation)
				onResult(success)
				if success then
					previewModel:Destroy() 
					inputConnection:Disconnect()
					connection:Disconnect()
				end
				
				return success
			end
		else
			inputConnection:Disconnect()
		end
	end)
	
end

return PlacementClient
