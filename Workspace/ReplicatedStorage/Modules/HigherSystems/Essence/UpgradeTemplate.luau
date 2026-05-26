local EssenceUpgradeTemplate = {}

function EssenceUpgradeTemplate.setData(EssenceUpgrades, isNextUpgradeCost)
	--[[
		Expects: (ex.)
		
		EssenceUpgrades = {
			BaseLuckIncrease = 0,
			UpgradeBargain = 0,
			AutoUpgrade = 0,
			ModifierCountIncrease = 0
		},

		Returns Map
	]]
	
	local nextUpgradeCostFactor = 0

	if isNextUpgradeCost then
		nextUpgradeCostFactor = 1
	end

	local Map = {
		BaseLuckIncrease = {
			MaxUpgrades = 10,
			Factor = 2 * EssenceUpgrades.BaseLuckIncrease, -- +2x base luck per upgrade, maxes out at +20x
			Cost = 2 ^ (EssenceUpgrades.BaseLuckIncrease + nextUpgradeCostFactor)
		},
		UpgradeBargain = {
			MaxUpgrades = 15,
			Factor = 1 - (1 - 0.1) ^ EssenceUpgrades.UpgradeBargain, -- n% discount, maxes out at 80%
			Cost = 4 ^ (EssenceUpgrades.UpgradeBargain + nextUpgradeCostFactor)
		},
		AutoUpgrading = {
			MaxUpgrades = 1,
			Factor = EssenceUpgrades.AutoUpgrading, -- Upgrades your structures
			Cost = 250
		},
		ModifierCountIncrease = {
			MaxUpgrades = 49,
			Factor = EssenceUpgrades.ModifierCountIncrease, -- Diminishing returns!!
			Cost = 1.5 ^ (EssenceUpgrades.ModifierCountIncrease + nextUpgradeCostFactor)
		}
	}
	
	return Map

end

return EssenceUpgradeTemplate
