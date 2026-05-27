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
		
		if profile_Data.Data.Structures[`{structure.Name}`] == 0 then
			InventoryAddStructure:FireClient(player, profile_Data.Data.PlacedStructures[structure_ID])	-- Update GUI -> StructureButtons
		end
		
		profile_Data.Data.PlacedStructures[structure_ID] = nil											-- Delete the key
		profile_Data.Data.Structures[`{structure.Name}`] += 1											-- Increase Structure Count (Inventory)
		structure:Destroy()																				-- Destroy the physical structure
	end,
	["Upgrade"] = function(structure: Model, profile_Data) 
		local structure_ID = structure:GetAttribute("ID")
		local tier = profile_Data.Data.PlacedStructures[structure_ID].Data.Tier
		local upgrades = StructureAttributes.SetData(tostring(structure.Name), tier + 1)
		
		if upgrades.Cost <= profile_Data.Data.Tokens and tier < upgrades.MaxUpgrades then				-- If the server can afford it and its an acceptable tier
			profile_Data.Data.Tokens -= upgrades.Cost													-- Subtract the tokens
			profile_Data.Data.PlacedStructures[structure_ID].Data.Tier += 1								-- Increase the tier
			structure:SetAttribute("AttributeFactor", upgrades.AttributeFactor)							-- Set the proceeding tier
			
			UpdateStatistics:FireAllClients(profile_Data)
		end
	end,
       
	["View Stats"] = function(structure: Model, profile_Data) 
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
