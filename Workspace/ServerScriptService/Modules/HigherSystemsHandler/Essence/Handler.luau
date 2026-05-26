---------- Init. ----------


local EssenceHandler = {}

local EssenceResetEvent = game:GetService("ReplicatedStorage").Events.EssenceReset
local UpgradeTemplate = require(game:GetService("ReplicatedStorage").Modules.HigherSystems.Essence.UpgradeTemplate)
local GetData = game:GetService("ReplicatedStorage").Events.GetData
local ProfileStoreManager = require(game:GetService("ServerScriptService").Modules.ProfileStoreManager)
local EssenceUpgrade = game:GetService("ReplicatedStorage").Events.EssenceUpgrade

---------- Init. Variables ----------


local validation = false

-- TESTING
local PRIVATE_SERVER_OVERRIDE = true

---------- Functions ----------


-- Resets Tokens and Structures
function EssenceHandler.resetEssence(player, EssencePoints, isEssenceReset)
	
	-- Checks if PS owner clicked
	if game.PrivateServerId ~= 0 or game.PrivateServerId ~= "" then
		if player.UserId == game.PrivateServerOwnerId or PRIVATE_SERVER_OVERRIDE then
			validation = true
		end
	else
		validation = true
	end
	
	local Profile = ProfileStoreManager.GetProfile()
	
	if Profile.Data.Tokens < 10000 then validation = false end
	
	if validation == false then return validation end
	
	-- Reset Tokens -> 0
	Profile.Data.Tokens = 0
	
	-- Adds Essence
	Profile.Data.Essence += EssencePoints
	
	-- Sets Visibility (Essence)
	Profile.Data.UnlockedSystems.Essence = true
	
	-- Reset Data.Structures Count -> 1
	for key, _ in Profile.Data.Structures do
		Profile.Data.Structures[key] = 1
	end
	
	-- Reset Data.PlacedStructures -> nil
	for PlacedStructure, _ in Profile.Data.PlacedStructures do
		Profile.Data.PlacedStructures[PlacedStructure] = nil
	end
	
	-- Destroys physical structures
	for _, typeFolder in workspace.PlacedStructures:GetChildren() do
		for _, structure in typeFolder:GetChildren() do
			structure:Destroy()
		end
	end
	-- not isEssence = Higher System Reset, meaning that the Essence Upgrades ALSO have to be reset
	if not isEssenceReset then 
		
		-- Resets Essence -> 0
		Profile.Data.Essence = 0
		
		-- Resets Essence Upgrades -> 0
		for key, upgradeCount in Profile.Data.EssenceUpgrades do
			Profile.Data.EssenceUpgrades[key] = 0
		end
	end
	
	ProfileStoreManager.ReconcileProfile()
	
	return validation
end

-- Updates Data and Updates Board on Upgrade
function EssenceHandler.upgradeBoard(player, ButtonType)
	local CanBuy = false
	local ReturnData = {}

	local Profile = ProfileStoreManager.GetProfile()

	-- Get the type of upgrade
	local UpgradeType = UpgradeTemplate.setData(Profile.Data.EssenceUpgrades)[ButtonType]

	-- See if server has enough Essence
	if Profile.Data.Essence >= UpgradeType.Cost then
		-- Set Data: Cost -> Subtract Tokens using UpgradeTemplate
		Profile.Data.Tokens -= UpgradeType.Cost

		-- Increase the number of upgrades for this type in profile
		-- Factor is accounted for in their respective RunStructure ModuleScript
		Profile.Data.EssenceUpgrades[UpgradeType] += 1

		-- Update Board Display
		ReturnData = {
			CurrentFactor = UpgradeType.Factor,
			NextCost = UpgradeTemplate.setData(Profile.Data.EssenceUpgrades[UpgradeType] + 1)[UpgradeType].Cost
		}

		CanBuy = true
	end

	return CanBuy, ReturnData
end

-- Initial Setup
EssenceHandler.boardUpdate(ProfileStoreManager.GetProfile())


---------- Listeners ----------

-- Updates the board and profile when updated
EssenceUpgrade.OnServerInvoke = function(player, ButtonType)
	return EssenceUpgrade.upgradeBoard(player, ButtonType)
end

-- Esssence Reset
EssenceResetEvent.OnServerEvent:Connect(function(player, EssencePoints)
	EssenceHandler.resetEssence(player, EssencePoints, true)
	GetData:FireAllClients(ProfileStoreManager.GetData())
end)


---------- ----------


return EssenceHandler

--[[
	Essence Upgrades
	
	+2 base luck		Init
	25% off upgrades
	Auto Upgrading
	+1 Modifiers
	
	Essence (itself) increases sell value (+N multiplier)

]]