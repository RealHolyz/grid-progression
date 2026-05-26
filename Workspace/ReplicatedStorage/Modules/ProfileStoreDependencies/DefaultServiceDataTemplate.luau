local Shared = {}
	Shared.DEFAULT_SERVER_DATA = {
		FirstTime = true,
		
		Structures = {
			BaseGenerator = 1,
			BaseModifier = 1,
			BaseSeller = 1
		},
		
		PlacedStructures = {},
		
		Squares = {},
		
		Tokens = 0,
		Essence = 0,
		
		EssenceUpgrades = {
			BaseLuckIncrease = 0,
			UpgradeBargain = 0,
			AutoUpgrade = 0,
			ModifierCountIncrease = 0
		},
		
		UnlockedSystems = {
			["Essence"] = false,
			--["Vigor"] = false,
			--["Transcendence"] = false,
		},
		
		TotalTime = 0
	}
export type ServerData = typeof(Shared.DEFAULT_SERVER_DATA)

return Shared