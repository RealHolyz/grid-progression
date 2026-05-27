local StructureAttributes = {}

function StructureAttributes.SetData(structureName: string, tier: number)
	local structuresMap = {
		Tier = tier,
		BaseGenerator = {
			AttributeFactor = 5 / (tier + 1) ^ 1.1,
			MaxUpgrades = 100,
			Cost = math.floor(5 * math.e ^ tier)
		},
		BaseModifier = {
			AttributeFactor = 0.173286795 * tier, 
			MaxUpgrades = 50,
			Cost = math.floor(2 ^ tier)
		},
		BaseSeller = {
			AttributeFactor = 1 + 0.1 * tier,
			MaxUpgrades = 50,
			Cost = math.floor(5 * 2 ^ tier)
		}
	}
	
	return structuresMap[structureName]
end

return StructureAttributes