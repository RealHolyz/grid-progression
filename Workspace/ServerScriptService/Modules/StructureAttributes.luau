local StructureAttributes = {}

function StructureAttributes.SetData(structureName: string, tier: number)
	local structuresMap = {
		Tier = tier,
		BaseGenerator = {
			AttributeFactor = 5 / tier ^ 1.1,
			MaxUpgrades = 50,
			Cost = math.floor(5 * math.e ^ tier)
		},
		BaseModifier = {
			AttributeFactor = (tier ^ 2) / 100,
			MaxUpgrades = 100,
			Cost = math.floor(2 ^ tier)
		},
		BaseSeller = {
			AttributeFactor = 0.9 + 0.1 * tier,
			MaxUpgrades = 50,
			Cost = math.floor(5 * 2 ^ tier)
		}
	}
	
	return structuresMap[structureName]
end

return StructureAttributes

--f(x) = (40.5^(x/3))/100

--[[

TO-DO
  1. Parent each structure to their OWN respective structure type folder (ex. workspace.PlacedStructures.Sellers)
  2. Add functionality to each type of structure
    Generators:
      :SetAttribute("SpawnSpeed", 1)
        Each increasing level would decrease the spawn time by -0.25 seconds (Default: 5)
        Cost per level: l(x) = floor (5e^x)
        MAX: -0.25s, 20 upgrades
    Modifiers:
      :SetAttribute("Luck", 1)
        Each increasing level would increase the base luck of each square by 0.05 (Default: 1)
        Cost per level: l(x) = floor (100e^x)
        MAX: +0.5 luck, 10 upgrades
    Sellers:
      :SetAttribute("SellMultiply", 1)
        Each increasing level would add a factor of 0.1 to the finalized worth of each square (Default: 1)
        Cost per level: l(x) = floor(e^2x)
        MAX: +5x worth, 50 upgrades
        
        
    local structuresMap = {
		Tier = tier,
		BaseGenerator = {
			AttributeFactor = 5 - 2.1 * math.log(tier, math.e),
			MaxUpgrades = 20,
			Cost = math.floor(5 * math.e ^ tier)
		},
		BaseModifier = {
			AttributeFactor = (tier ^ 2) / 400,
			MaxUpgrades = 20,
			Cost = math.floor(5 * tier ^ 5)
		},
		BaseSeller = {
			AttributeFactor = 0.9 + 0.1 * tier,
			MaxUpgrades = 50,
			Cost = math.floor(math.e ^ (2 * tier))
		}
	}
]]