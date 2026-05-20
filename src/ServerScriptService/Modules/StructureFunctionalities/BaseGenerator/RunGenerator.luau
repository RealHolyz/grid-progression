local DisplaySquares = require(game:GetService("ServerScriptService").Modules.StructureFunctionalities.BaseGenerator.DisplaySquare)

local RunGenerator = {}


function RunGenerator.runGenerator(activeGenerators, generator: Model)
	if not activeGenerators[generator] then
		activeGenerators[generator] = true

		task.spawn(function()
			while activeGenerators[generator] and generator.Parent do
				local generator_SpawnPeriod = generator:GetAttribute("AttributeFactor")
				if not generator_SpawnPeriod then return end

				task.wait(generator_SpawnPeriod)

				DisplaySquares.build_InitialDisplay(generator:GetPivot())
			end
		end)
	end
end
return RunGenerator
