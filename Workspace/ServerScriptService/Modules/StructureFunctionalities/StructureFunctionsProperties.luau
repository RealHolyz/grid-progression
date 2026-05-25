local InventoryAddStructure = game:GetService("ReplicatedStorage").Events.InventoryAddStructure
local StructureAttributes = require(game:GetService("ServerScriptService").Modules.StructureAttributes)
local UpdateStatistics = game:GetService("ReplicatedStorage").Events.UpdateStatistics

local StructureFunctionsProperties = {}

local PropertiesMap = {
	["Move"] = function(structure: Model)
       --[[
           Get structure ID by attribute


           Find the structure within profile.Data.PlacedStructures
               Remove the key, but pass data over to the proceeding function
          
           Remove the existing structure


           Call the PlacementClient function -> PlacementServer
       ]]
		local structure_ID = structure:GetAttribute("ID")


	end,
	["Sell"] = function(structure: Model) end,
       --[[
           Get structure ID by attribute
           (Set a runtime function
               Init: :SetAttribute("Worth", ...)
               Add to worth each time it's upgraded
           )
           Remove existing structure and profile.Data.PlacedStructures key
           Add structure:GetAttribute("Worth") to server tokens
       ]]
	["Store"] = function(structure: Model, profile_Data, player)
		local structure_ID = structure:GetAttribute("ID")
		
		-- Update GUI -> StructureButtons
		if profile_Data.Data.Structures[`{structure.Name}`] == 0 then
			InventoryAddStructure:FireClient(player, profile_Data.Data.PlacedStructures[structure_ID])
		end
		
		-- Delete the key
		profile_Data.Data.PlacedStructures[structure_ID] = nil
		-- Increase Structure Count (Inventory)
		profile_Data.Data.Structures[`{structure.Name}`] += 1
		-- Destroy the physical structure
		structure:Destroy()
	end,
	["Upgrade"] = function(structure: Model, profile_Data) 
		local structure_ID = structure:GetAttribute("ID")
		local tier = profile_Data.Data.PlacedStructures[structure_ID].Data.Tier
		local upgrades = StructureAttributes.SetData(tostring(structure.Name), tier + 1)
		
		-- If the server can afford it and its an acceptable tier
		if upgrades.Cost <= profile_Data.Data.Tokens and tier < upgrades.MaxUpgrades then
			-- Subtract the tokens
			profile_Data.Data.Tokens -= upgrades.Cost
			-- Increase the tier
			profile_Data.Data.PlacedStructures[structure_ID].Data.Tier += 1
			-- Set the proceeding tier
			structure:SetAttribute("AttributeFactor", upgrades.AttributeFactor)
			UpdateStatistics:FireAllClients(profile_Data)
		end
	end,
       
	["View Stats"] = function(structure: Model, profile_Data) 
		-- Shows structure name and tier
		local structure_ID = structure:GetAttribute("ID")
		
		print(`{structure.Name}: Tier {profile_Data.Data.PlacedStructures[structure_ID].Data.Tier}`)
		print(`Next Upgrade Cost: {StructureAttributes.SetData(structure.Name, profile_Data.Data.PlacedStructures[structure_ID].Data.Tier + 1).Cost} Tokens`)
	end,
	["Exit"] = function(structure: Model) end
}

function StructureFunctionsProperties.executeProperties(player, structure, property, profile_Data, ...)
	PropertiesMap[property](structure, profile_Data, player, ...)
end

return StructureFunctionsProperties
