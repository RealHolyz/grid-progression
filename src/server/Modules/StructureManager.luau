local StructureManager = {}

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PlacedStructures = workspace:WaitForChild("PlacedStructures")

StructureManager.ActiveStructures = {}

function StructureManager.CreateStructure(structureData)

	-- Get the base template from replicated storage
	local template = ReplicatedStorage.StructureBaseModels[structureData.Type]

	if not template then
		warn("Structure template not found: " .. structureData.Type)
		return
	end

	-- Clone model
	local model = template:Clone()
	model.Parent = PlacedStructures
	
	model:SetAttribute("StructureId", structureData.ID)

	-- Position + rotation
	model:PivotTo(
		CFrame.new(
			structureData.Position.X,
			structureData.Position.Y,
			structureData.Position.Z
		) *
			CFrame.Angles(
				0,
				math.rad(structureData.Rotation),
				0
			)
	)
	
	StructureManager.ActiveStructures[structureData.ID] = model
	
	return model
end

function StructureManager.RemoveStructure(id)
	local model = StructureManager.ActiveStructures[id]
	if model then
		model:Destroy()
		model = nil
	end
end

return StructureManager