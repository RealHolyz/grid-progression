local RunStructuresSetup = {}

function RunStructuresSetup.setup(structureType_Folder: string, runModule: ModuleScript, moduleFunction: string)
	local loadedModule = require(runModule)
	local runFunction = loadedModule[moduleFunction]
	local folder = workspace.PlacedStructures:WaitForChild(structureType_Folder)
	-- For initial structures
	for _, structureType in ipairs(folder:GetChildren()) do
		if type(runFunction) == "function" then 
			runFunction(structureType) 
		end
	end
	
	-- For added structures (ingame)
	folder.ChildAdded:Connect(function(structure: Model)
		runFunction(structure) 
	end)
end


return RunStructuresSetup
