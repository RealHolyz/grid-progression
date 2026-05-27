local AttributesModule = require(game:GetService("ServerScriptService").Modules.StructureFunctionalities.BaseSeller.AttributesModule)
local ProfileStoreManager = require(game:GetService("ServerScriptService").Modules.ProfileStoreManager)
local UpdateStatistics = game:GetService("ReplicatedStorage").Events.UpdateStatistics
local StructureAttributes = require(game:GetService("ServerScriptService").Modules.StructureAttributes)
local Formatter = require(game:GetService("ReplicatedStorage").Modules.Misc.Formatter)
local UpgradeTemplate = require(game:GetService("ReplicatedStorage").Modules.HigherSystems.Essence.UpgradeTemplate)

local RunSeller = {}
local RunSellTable = {}
-- Rarity Computation functions

local attributeLevels = {
	{req = 1e+12, col = Color3.new(1, 0.0823529, 0.0980392), texture = true, key = "ruby"},
	{req = 1e+10, col = Color3.new(0.796078, 0.0588235, 1), texture = true, key = "amethyst"},
	{req = 1e+9, col = Color3.new(0.458824, 1, 0.0980392), texture = true, key = "emerald"},
	{req = 1e+8, col = Color3.new(0.0862745, 0.878431, 0.921569), key = "diamond"},
	{req = 1e+7, col = Color3.new(0.905882, 0.921569, 0), key = "gold"},
	{req = 1e+6, col = Color3.new(0.552941, 0.552941, 0.552941), key = "silver"}
}

local rarityLevels = {
	{limit = 0, color = "Dark grey"},
	{limit = 1e+5, color = "Grey"},
	{limit = 1e+6, color = "Light grey"},
	{limit = 1e+9, color = "White"},
	{limit = 1e+12, color = "Cool yellow"},
	{limit = 1e+15, color = "Deep orange"},
	{limit = 1e+18, color = "Really red"},
	{limit = 1e+21, color = "Magenta"},
}

local function build_ComputedDisplay_Computation(square: Part)

	local square_Luck = square:GetAttribute("Luck")
	local square_Rarity, square_RarestAttributeValue, square_AttributeCount, square_String = AttributesModule.calculateSquare(square_Luck)
	
	local textLabel = square:WaitForChild("RarityDisplay"):WaitForChild("RarityText")
	textLabel.Text = string.format("%s%s", square_String, "\n" .. "1 in " .. Formatter.format(square_Rarity))

	-- Rarest Attribute -> TextColor and Outline
	for _, level in attributeLevels do
		if square_RarestAttributeValue >= level.req then
			textLabel.TextColor3 = level.col
			
			local Outline = Instance.new("SelectionBox")
			Outline.Parent = square
			Outline.Adornee = square
			Outline.Transparency = 0
			Outline.Color3 = Color3.new(level.col)
		end
		break
	end
	
	-- Rarity Value -> BrickColor
	
	for _, condition in ipairs(rarityLevels) do
		if square_Rarity < condition.limit then
			square.BrickColor = BrickColor.new(condition.color)
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
		
			
			ProfileStoreManager.GetProfile().Data.Tokens += sell_value * BaseSeller:GetAttribute("AttributeFactor") * (1 + ProfileStoreManager.GetProfile().Data.Essence)
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
