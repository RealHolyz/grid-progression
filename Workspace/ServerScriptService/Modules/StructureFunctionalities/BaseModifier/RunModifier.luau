local StructureAttributes = require(game:GetService("ServerScriptService").Modules.StructureAttributes)
local ProfileStoreManager = require(game:GetService("ServerScriptService").Modules.ProfileStoreManager)

local RunModifier = {}

function RunModifier.runModifier(activeModifiers, BaseModifier: Model)
	if not activeModifiers[BaseModifier] then 
		activeModifiers[BaseModifier] = true
		
		local hitbox = BaseModifier:WaitForChild("Hitbox")
		
		local structure_ID = BaseModifier:GetAttribute("ID")
		local structure_attributes = StructureAttributes.SetData(`{BaseModifier.Name}`, ProfileStoreManager.GetProfile().Data.PlacedStructures[structure_ID].Data.Tier)
		local structure_AttributeFactor = structure_attributes.AttributeFactor

		BaseModifier:SetAttribute("AttributeFactor", structure_AttributeFactor)
		
		hitbox.Touched:Connect(function(hit: Part)
			local square_Luck = hit:GetAttribute("Luck")
			if square_Luck then
				hit:SetAttribute("Luck", (square_Luck + BaseModifier:GetAttribute("AttributeFactor")))
				local text = hit:WaitForChild("RarityDisplay"):WaitForChild("RarityText")
				text.Text = string.format(`Luck: {math.floor(hit:GetAttribute("Luck") * 100) / 100}x`)
			else
				print("Object does not have luck attribute")
			end
		end)
	end
end

return RunModifier
