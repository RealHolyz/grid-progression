local DisplaySquares = require(game:GetService("ServerScriptService").Modules.StructureFunctionalities.BaseGenerator.DisplaySquare)
local StructureAttributes = require(game:GetService("ServerScriptService").Modules.StructureAttributes)
local ProfileStoreManager = require(game:GetService("ServerScriptService").Modules.ProfileStoreManager)

local RunGenerator = {}


function RunGenerator.runGenerator(activeGenerators, generator: Model)
	if not activeGenerators[generator] then
		activeGenerators[generator] = true
		
		task.spawn(function()
			
			-- Gets ID and sets attribute
			local structure_ID = generator:GetAttribute("ID")
			local structure_attributes = StructureAttributes.SetData(`{generator.Name}`, ProfileStoreManager.GetProfile().Data.PlacedStructures[structure_ID].Data.Tier)
			local structure_AttributeFactor = structure_attributes.AttributeFactor
			
			generator:SetAttribute("AttributeFactor", structure_AttributeFactor)
			
			while activeGenerators[generator] and generator.Parent do
				DisplaySquares.build_InitialDisplay(generator:GetPivot())
				
				task.wait(generator:GetAttribute("AttributeFactor"))
			end
		end)
	end
end
return RunGenerator
