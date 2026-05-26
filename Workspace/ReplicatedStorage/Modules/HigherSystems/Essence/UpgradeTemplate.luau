local EssenceUpgradeTemplate = {}

function EssenceUpgradeTemplate.setData(upgradeCount)
	
	local Map = {
		-- Essence Upgrades
		Upgrades = {
			-- Profile.Data.EssenceUpgrades. ...
			BaseLuckIncrease = {
				MaxUpgrades = 10,
				Factor = 2 * upgradeCount, -- +2x base luck per upgrade, maxes out at +20x
				Cost = 2 ^ upgradeCount
			},
			UpgradeBargain = {
				MaxUpgrades = 15,
				Factor = 1 - (1 - 0.1) ^ upgradeCount, -- n% discount, maxes out at 80%
				Cost = 4 ^ upgradeCount
			},
			AutoUpgrading = {
				MaxUpgrades = 1,
				Factor = upgradeCount, -- Upgrades your structures
				Cost = 250
			},
			ModifierCountIncrease = {
				MaxUpgrades = 49,
				Factor = upgradeCount, -- Diminishing returns!!
				Cost = 1.5 ^ upgradeCount
			}
		},
	}
	
	return Map
end

return EssenceUpgradeTemplate
