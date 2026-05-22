local StructurePropertiesFunctions = {}

local PropertiesMap = {
	["Move"] = function(structure: Model) end,
       --[[
           Get structure ID by attribute


           Find the structure within profile.Data.PlacedStructures
               Remove the key, but pass data over to the proceeding function
          
           Remove the existing structure


           Call the PlacementClient function -> PlacementServer
       ]]
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
	["Store"] = function(structure: Model, profile_Data)
       --[[
           Get structure ID by attribute
           Find the structure within profile.Data.PlacedStructures
               Remove the key
           Add the count of the type of structure -> structureName
           Remove the structure itself
       ]]

		local structure_ID = structure:GetAttribute("ID")
		
		profile_Data.Data.PlacedStructures[structure_ID] = nil
		profile_Data.Data.Structures[`{structure.Name}`] += 1
		
		structure:Destroy()
		
	end,
	["Upgrade"] = function(structure: Model) end,
       --[[
           Get structure ID by attribute
           Get data attributes of the structure
           Compute requested attribute
           Check if server has enough tokens
               true: increase level of attribute, subtract tokens, hide structure property gui
               false: display "cannot afford", but keep gui
       ]]
	["View Stats"] = function(structure: Model) end,
	["Exit"] = function(structure: Model) end
}

function StructurePropertiesFunctions.executeProperty(structure: Model, property, profile_data, ...)
	PropertiesMap[property](structure, profile_data, ...)
end

return StructurePropertiesFunctions