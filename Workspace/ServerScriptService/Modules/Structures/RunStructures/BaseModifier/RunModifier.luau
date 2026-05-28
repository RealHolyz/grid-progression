local RunModifier = {}


---------- SERVICES ----------


local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")


---------- MODULES -----------


local Modules = ServerScriptService.Modules

local Core = Modules.Core
local Structures = Modules.Structures
local Templates = Structures.Templates

local EssenceUpgradeTemplate = require(ReplicatedStorage.Modules.Currencies.Essence.EssenceUpgradeTemplate)
local ProfileStoreManager = require(Core.ProfileStoreManager)
local UpgradeTemplate = require(Templates.UpgradeTemplate)


---------- FUNCTIONS -----------

RunModifier.activeModifiers = {}

function RunModifier.runModifier(BaseModifier: Model)
	if not RunModifier.activeModifiers[BaseModifier] then 
		RunModifier.activeModifiers[BaseModifier] = true
		
		local hitbox = BaseModifier:WaitForChild("Hitbox")
		
		local structure_ID = BaseModifier:GetAttribute("ID")
		local structure_attributes = UpgradeTemplate.SetData(`{BaseModifier.Name}`, ProfileStoreManager.GetProfile().Data.PlacedStructures[structure_ID].Data.Tier)
		local structure_AttributeFactor = structure_attributes.AttributeFactor
		local EssenceUpgrades = ProfileStoreManager.GetProfile().Data.EssenceUpgrades
		local BaseLuckIncreaseFactor = EssenceUpgradeTemplate.setData(EssenceUpgrades, false)["BaseLuckIncrease"]["Factor"]
		
		BaseModifier:SetAttribute("AttributeFactor", structure_AttributeFactor)
		
		hitbox.Touched:Connect(function(hit: Part)
			local square_Luck = hit:GetAttribute("Luck")
			if square_Luck then
				hit:SetAttribute("Luck", (square_Luck + BaseModifier:GetAttribute("AttributeFactor")) * BaseLuckIncreaseFactor)
				local text = hit:WaitForChild("RarityDisplay"):WaitForChild("RarityText")
				text.Text = string.format(`Luck: {math.floor(hit:GetAttribute("Luck") * 100) / 100}x`)
			else
				print("Object does not have luck attribute")
			end
		end)
	end
end


---------------------


return RunModifier
