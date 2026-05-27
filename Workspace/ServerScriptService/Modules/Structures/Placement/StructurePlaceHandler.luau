local StructurePlaceModule = {}


---------- SERVICES ----------


local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")


---------- MODULES -----------


local Modules = ServerScriptService.Modules

local Core = Modules.Core
local Structures = Modules.Structures
local Templates = Structures.Templates

local ProfileStoreManager = require(Core.ProfileStoreManager)
local StructureFactory = require(Templates.StructureFactory)
local UpgradeTemplate = require(Templates.UpgradeTemplate)

local GetProfile = ReplicatedStorage.Events.Data.GetProfile


---------- FUNCTIONS -----------


-- Server places INITIAL structures from session profile
function StructurePlaceModule.validatedPlace(structure: Model, structure_Name, structure_Tier, structure_CFrame, structure_Rotation, creatingData: boolean, ...)

	-- Structure Init.
	local structure_physical = structure:Clone()
	local structureFolder = `{string.sub(structure_Name, 5)}s`
	
	structure_physical.Parent = workspace.PlacedStructures[structureFolder]
	structure_physical:PivotTo(structure_CFrame) 
	
	-- Creating data IF ONLY client placing
	if creatingData then
		local playerNewStructureData = StructureFactory.CreateStructure(
			structure_Name,
			structure_Tier,
			{
				X = structure_CFrame.X,
				Y = structure_CFrame.Y,
				Z = structure_CFrame.Z
			},
			structure_Rotation
		)
		
		local structure_ID = playerNewStructureData.ID

		ProfileStoreManager.GetProfile().Data.PlacedStructures[structure_ID] = playerNewStructureData
		structure_physical:SetAttribute("ID", structure_ID)
		ProfileStoreManager.ReconcileProfile()
	else
		structure_physical:SetAttribute("ID", ...)
	end
	
	for key, value in pairs(UpgradeTemplate.SetData(structure_Name, 1)) do
		structure_physical:SetAttribute(`{key}`, value)
	end
end

-- Server places RUNTIME structures from session profile
function StructurePlaceModule.place(player, structureName, structure_CFrame, structureRotation)

	local valid_placement = true

	local params = OverlapParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	params.ExcludeInstances = {workspace.SpawnParts.MainParts.Base}

	local structure = ReplicatedStorage.StructureBaseModels:WaitForChild(structureName)

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
		StructurePlaceModule.validatedPlace(structure, structureName, 0, structure_CFrame, structureRotation, true)
	end

	return valid_placement
end


--------------------


return StructurePlaceModule


