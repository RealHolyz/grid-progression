local AttributesModule = require(game:GetService("ServerScriptService").Modules.StructureFunctionalities.BaseSeller.AttributesModule)
local ProfileStoreManager = require(game:GetService("ServerScriptService").Modules.ProfileStoreManager)
local UpdateStatistics = game:GetService("ReplicatedStorage").Events.UpdateStatistics
local StructureAttributes = require(game:GetService("ServerScriptService").Modules.StructureAttributes)


local RunSeller = {}
local RunSellTable = {}
-- Rarity Computation functions
local suffixes = {
	{limit = 1e6,  suffix = "%.0f", divisor = 1},
	{limit = 1e9,  suffix = "%.3fM", divisor = 1e6},
	{limit = 1e12, suffix = "%.3fB", divisor = 1e9},
	{limit = 1e15, suffix = "%.3fT", divisor = 1e12},
	{limit = 1e18, suffix = "%.3fQ", divisor = 1e15},
	{limit = 1e21, suffix = "%.3fQi", divisor = 1e18},
	{limit = 1e24, suffix = "%.3fS", divisor = 1e21},
	{limit = 1e27, suffix = "%.3fSp", divisor = 1e24},
}

local function suffixFormat(number)
	for _, s in ipairs(suffixes) do
		if number < s.limit then
			return string.format(s.suffix, number / s.divisor)
		end
	end
	return string.format("%.0e", number)
end

local function build_ComputedDisplay_Computation(square)

	local square_Luck = square:GetAttribute("Luck")
	local square_Rarity, square_RarestAttributeValue, square_AttributeCount, square_String = AttributesModule.calculateSquare(square_Luck)

	local textLabel = square:WaitForChild("RarityDisplay"):WaitForChild("RarityText")
	textLabel.Text = string.format("%s%s", square_String, "\n" .. "1 in " .. suffixFormat(square_Rarity))

	-- Setting text color based on the rarity attribute
	local attributeLevels = {
		{req = 1e+12, col = Color3.new(1, 0.0823529, 0.0980392), texture = true, key = "ruby"},
		{req = 1e+10, col = Color3.new(0.796078, 0.0588235, 1), texture = true, key = "amethyst"},
		{req = 1e+9, col = Color3.new(0.458824, 1, 0.0980392), texture = true, key = "emerald"},
		{req = 1e+8, col = Color3.new(0.0862745, 0.878431, 0.921569), key = "diamond"},
		{req = 1e+7, col = Color3.new(0.905882, 0.921569, 0), key = "gold"},
		{req = 1e+6, col = Color3.new(0.552941, 0.552941, 0.552941), key = "silver"}
	}

	for _, level in ipairs(attributeLevels) do
		if square_RarestAttributeValue >= level.req then
			textLabel.TextColor3 = level.col
			break
		end
	end
	
	local sell_Value = (40.5 ^ (math.log10(square_Rarity) / 3)) /  100
	
	return sell_Value
end

local function sellSquare(BaseSeller: Model, sell_value)
	local hitbox = BaseSeller:WaitForChild("SellHitbox")
	
	-- Gets ID and sets attribute
	local structure_ID = BaseSeller:GetAttribute("ID")
	local structure_attributes = StructureAttributes.SetData(`{BaseSeller.Name}`, ProfileStoreManager.GetProfile().Data.PlacedStructures[structure_ID].Data.Tier)
	local structure_AttributeFactor = structure_attributes.AttributeFactor

	BaseSeller:SetAttribute("AttributeFactor", structure_AttributeFactor)
	
	hitbox.Touched:Connect(function(hit)
		if not RunSellTable[hit] and hit:IsA("Part") and hit:GetAttribute("Computed") then
			RunSellTable[hit] = true
			
			task.wait()
			hit:Destroy()
			
			RunSellTable[hit] = nil
			ProfileStoreManager.GetProfile().Data.Tokens += sell_value * BaseSeller:GetAttribute("AttributeFactor")
			UpdateStatistics:FireAllClients(ProfileStoreManager.GetProfile())
		end
	end)
end

-- Computed Display is per BaseSeller
function RunSeller.runSeller(activeSellers, BaseSeller: Model)
	if not activeSellers[BaseSeller] then
		activeSellers[BaseSeller] = true
		local hitbox = BaseSeller:WaitForChild("ComputeHitbox")
		hitbox.Touched:Connect(function(hit)
			if hit:GetAttribute("Computed") and hit:IsA("Part") then
				local sell_value = build_ComputedDisplay_Computation(hit)
				sellSquare(BaseSeller, sell_value)
			end
		end)
	end
end



return RunSeller
