---------- Init. ----------


local EssenceHandler = {}

local EssenceResetEvent = game:GetService("ReplicatedStorage").Events.EssenceReset
local UpgradeTemplate = require(game:GetService("ReplicatedStorage").Modules.HigherSystems.Essence.UpgradeTemplate)
local GetData = game:GetService("ReplicatedStorage").Events.GetData
local ProfileStoreManager = require(game:GetService("ServerScriptService").Modules.ProfileStoreManager)
local EssenceUpgrade = game:GetService("ReplicatedStorage").Events.EssenceUpgrade
local EssenceInit = game:GetService("ReplicatedStorage").Events.EssenceInit

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


	Profile.Data.Tokens = 0 										-- Reset Tokens -> 0
	Profile.Data.Essence += EssencePoints 							-- Adds Essence
	Profile.Data.UnlockedSystems.Essence = true 					-- Sets Visibility (Essence)

	for key, _ in Profile.Data.Structures do						-- Reset Data.Structures Count -> 1
		Profile.Data.Structures[key] = 1
	end

	for PlacedStructure, _ in Profile.Data.PlacedStructures do		-- Reset Data.PlacedStructures -> nil
		Profile.Data.PlacedStructures[PlacedStructure] = nil
	end

	for _, typeFolder in workspace.PlacedStructures:GetChildren() do -- Destroys physical structures
		for _, structure in typeFolder:GetChildren() do
			structure:Destroy()
		end
	end

	-- not isEssence = Higher System Reset, meaning that the Essence Upgrades ALSO have to be reset
	if not isEssenceReset then 
		Profile.Data.Essence = 0									-- Resets Essence -> 0
		for key, upgradeCount in Profile.Data.EssenceUpgrades do 	-- Resets Essence Upgrades -> 0
			Profile.Data.EssenceUpgrades[key] = 0
		end
	end

	ProfileStoreManager.ReconcileProfile()

	return validation
end

-- Initial Upgrade Board Loading
function EssenceHandler.initialBoardUpdate()
	local Profile = ProfileStoreManager.GetProfile()
	local ReturnMap = UpgradeTemplate.setData(Profile.Data.EssenceUpgrades, true)
	
	local isMaxedTable = {
		AutoUpgrade = false, 
		BaseLuckIncrease = false,
		ModifierCountIncrease = false,
		UpgradeBargain = false
	}
	
	for UpgradeType, UpgradeTypeTable in ReturnMap do
		if Profile.Data.EssenceUpgrades[UpgradeType] == UpgradeTypeTable.MaxUpgrades then
			isMaxedTable[UpgradeType] = true
		end
	end
	
	return ReturnMap, isMaxedTable -- Returns every upgrades' Current Factor and Next Cost
end

-- Updates Data and Updates Board on Upgrade
function EssenceHandler.upgradeBoard(UpgradeType: string)
	local CanBuy = false
	local isMaxedUpgrade = false
	local Profile = ProfileStoreManager.GetProfile()
	
	-- Get the type of upgrade
	local UpgradeTypeTable = UpgradeTemplate.setData(Profile.Data.EssenceUpgrades, false)[UpgradeType] -- Map: CurrentFactor, CurrentCost
	
	if Profile.Data.Essence >= UpgradeTypeTable.Cost then 									-- See if server has enough Essence
		Profile.Data.Essence -= UpgradeTypeTable.Cost 										-- Set Data: Cost -> Subtract Tokens using UpgradeTemplate
		Profile.Data.EssenceUpgrades[UpgradeType] += 1 										-- Increase the number of upgrades for this type in profile, Factor is accounted for in their respective RunStructure ModuleScript

		CanBuy = true
		
		if Profile.Data.EssenceUpgrades[UpgradeType] + 1 > UpgradeTypeTable.MaxUpgrades then	-- Maxed Out Upgrade -> Remove the button, replace text!
			isMaxedUpgrade = true
		end
	end

	local ReturnData = UpgradeTemplate.setData(Profile.Data.EssenceUpgrades, true)[UpgradeType] -- Map: CurrentFactor, NextCost, MaxUpg

	return CanBuy, ReturnData, UpgradeType, isMaxedUpgrade
end


---------- Listeners ----------


-- Esssence Reset
EssenceResetEvent.OnServerInvoke = function(player, EssencePoints)
	EssenceHandler.resetEssence(player, EssencePoints, true)
	GetData:FireAllClients(ProfileStoreManager.GetData())
	
	return ProfileStoreManager.GetProfile().Data.Structures
end

-- Updates the Essence Upgrade Board and Profile when Upgraded
EssenceUpgrade.OnServerInvoke = function(player, ButtonType)
	return EssenceHandler.upgradeBoard(ButtonType)
end

-- Updates the Essence Upgrade Board on Initialization
EssenceInit.OnServerInvoke = function(player)
	return EssenceHandler.initialBoardUpdate()
end

---------- ----------


return EssenceHandler