local StructureAttributes = require(game:GetService("ServerScriptService").Modules.StructureAttributes)

local RunModifier = {}

function RunModifier.runModifier(activeModifiers, BaseModifier: Model)
	if not activeModifiers[BaseModifier] then 
		activeModifiers[BaseModifier] = true
		
		local hitbox = BaseModifier:WaitForChild("Hitbox")
		local modifier_attributes = StructureAttributes.SetData(`{BaseModifier.Name}`, 1)
		local modifier_Luck = modifier_attributes.AttributeFactor
		
		hitbox.Touched:Connect(function(hit: Part)
			local square_Luck = hit:GetAttribute("Luck")
			if square_Luck then
				hit:SetAttribute("Luck", (square_Luck + modifier_Luck))
				local text = hit:WaitForChild("RarityDisplay"):WaitForChild("RarityText")
				text.Text = string.format(`Luck: {hit:GetAttribute("Luck")}x`)
			else
				print("Object does not have luck attribute")
			end
		end)
	end
end

return RunModifier
