local RunGenerator = {}


---------- SERVICES ----------

local ServerScriptService = game:GetService("ServerScriptService")

local Modules = ServerScriptService.Modules

local Core = Modules.Core
local Structures = Modules.Structures

local DisplaySquares = require(Structures.RunStructures.BaseGenerator.DisplaySquare)
local UpgradeTemplate = require(Structures.Templates.UpgradeTemplate)
local ProfileStoreManager = require(Core.ProfileStoreManager)


---------- FUNCTIONS ----------


function RunGenerator.runGenerator(activeGenerators, generator: Model)
	if not activeGenerators[generator] then
		activeGenerators[generator] = true
		
		local structure_ID = generator:GetAttribute("ID")
		local structure_attributes = UpgradeTemplate.SetData(`{generator.Name}`, ProfileStoreManager.GetProfile().Data.PlacedStructures[structure_ID].Data.Tier)
		local structure_AttributeFactor = structure_attributes.AttributeFactor

		generator:SetAttribute("AttributeFactor", structure_AttributeFactor)
		
		task.spawn(function()
			
			-- Gets ID and sets attribute
			
			
			while activeGenerators[generator] and generator.Parent do
				DisplaySquares.build_InitialDisplay(generator:GetPivot())
				
				task.wait(generator:GetAttribute("AttributeFactor"))
			end
		end)
		
		local generator_Button: Part = generator:FindFirstChild("Button")
		
		
		local click = Instance.new("ClickDetector")
		click.Parent = generator_Button
		
		local lastClick = 0
		click.MouseClick:Connect(function()
			local currentTime = tick()
			if currentTime-lastClick >= 0.25 then
				lastClick = currentTime
				DisplaySquares.build_InitialDisplay(generator:GetPivot())
			end
		end)
	end
end


---------- LISTENERS ----------


workspace.SpawnParts.MainParts.Base.Touched:Connect(function(hit)
	if hit:IsA("Part") and hit.Name == "Square" then
		hit:Destroy()
	end
end)


--------------------


return RunGenerator