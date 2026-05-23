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
        --[[
           Get structure ID by attribute
           Find the structure within profile.Data.PlacedStructures
               Remove the key
           Add the count of the type of structure -> structureName
           Remove the structure itself
        ]]
	   
		local structure_ID = structure:GetAttribute("ID")
		
		if profile_Data.Data.Structures[`{structure.Name}`] == 0 then
			InventoryAddStructure:FireClient(player, profile_Data.Data.PlacedStructures[structure_ID])
		end
		
		profile_Data.Data.PlacedStructures[structure_ID] = nil
		profile_Data.Data.Structures[`{structure.Name}`] += 1
		structure:Destroy()
	end,
	["Upgrade"] = function(structure: Model, profile_Data) 
		--[[
           Get structure ID by attribute
           Get data attributes of the structure
           Compute requested attribute
           Check if server has enough tokens
               true: increase level of attribute, subtract tokens, hide structure property gui
               false: display "cannot afford", but keep gui
               
           {
            ["Data"] =  ▼  {
               ["FirstTime"] = true,
               ["PlacedStructures"] =  ▼  {
                  ["9de783e1-fe5b-4bf1-a733-1c7840824f24"] =  ▼  {
                     ["Data"] =  ▼  {
                        ["Tier"] = 1
                     },
                     ["ID"] = "9de783e1-fe5b-4bf1-a733-1c7840824f24",
                     ["Position"] =  ▶ {...},
                     ["Type"] = "BaseModifier",
                     ["rotation"] = 180
                  },
                  ["9e7ae91d-20f5-4e74-90f7-392361627af9"] =  ▶ {...},
                  ["a8a3d7f9-f516-4399-8924-91e982fcfd21"] =  ▶ {...}
               },
               ["Squares"] = {},
               ["Structures"] =  ▶ {...},
               ["Tokens"] = 258.7307320698203
            },
       ]]
		
		local structure_ID = structure:GetAttribute("ID")
		local tier = profile_Data.Data.PlacedStructures[structure_ID].Data.Tier
		
		local upgrades = StructureAttributes.SetData(tostring(structure.Name), tier + 1)
		
		-- If the server can afford it and its an acceptable tier
		if upgrades.Cost <= profile_Data.Data.Tokens and tier <= upgrades.MaxUpgrades then
			
			-- Subtract the tokens
			profile_Data.Data.Tokens -= upgrades.Cost
			
			-- Increase the tier
			profile_Data.Data.PlacedStructures[structure_ID].Data.Tier += 1
			
			-- Set the proceeding tier
			structure:SetAttribute("AttributeFactor", upgrades.AttributeFactor)
			
			UpdateStatistics:FireAllClients(profile_Data)
		end
	end,
       
	["View Stats"] = function(structure: Model) end,
	["Exit"] = function(structure: Model) end
}

function StructureFunctionsProperties.executeProperties(player, structure, property, profile_Data, ...)
	PropertiesMap[property](structure, profile_Data, player, ...)
end

return StructureFunctionsProperties
