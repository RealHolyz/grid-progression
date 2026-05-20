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
		RarityPoints = 0,
	}
export type ServerData = typeof(Shared.DEFAULT_SERVER_DATA)

return Shared