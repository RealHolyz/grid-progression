local ReplicatedServer = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local Modules = ServerScriptService.Modules
local ProfileStoreManager = require(Modules.ProfileStoreManager)
local StructureFactory = require(Modules.StructureFactory)
local StructureAttributes = require(Modules.StructureAttributes)

local StructurePlaceModule = {}

function StructurePlaceModule.place(player, structureName, structure_CFrame, structureRotation)

	local valid_placement = true

	local params = OverlapParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	params.ExcludeInstances = {workspace.SpawnParts.Base}

	local structure = ReplicatedServer.StructureBaseModels:WaitForChild(structureName)

	local hitbox = structure:WaitForChild("CenterPart"):Clone()
	hitbox.Parent = workspace
	hitbox:PivotTo(structure_CFrame)

	local collisionParts = workspace:GetPartsInPart(hitbox, params)

	hitbox:Destroy()

	local profile = ProfileStoreManager.GetData()


	if profile then

		if profile.Data.Structures[structureName] > 0 then
			profile.Data.Structures[structureName] -= 1
		else
			valid_placement = false
		end
	end

	if valid_placement then

		local structure_physical = structure:Clone()
		local structureFolder = `{string.sub(structureName, 5)}s`
		structure_physical.Parent = workspace.PlacedStructures[structureFolder]
		structure_physical:PivotTo(structure_CFrame) 

		local playerNewStructureData = StructureFactory.CreateStructure(
			structureName,
			1,
			{
				X = structure_CFrame.X,
				Y = structure_CFrame.Y,
				Z = structure_CFrame.Z
			},
			structureRotation
		)

		profile.Data.PlacedStructures[playerNewStructureData.ID] = playerNewStructureData

		for key, value in pairs(StructureAttributes.SetData(structureName, 1)) do
			structure_physical:SetAttribute(`{key}`, value)
		end
		
		
	end

	return valid_placement
end

return StructurePlaceModule


