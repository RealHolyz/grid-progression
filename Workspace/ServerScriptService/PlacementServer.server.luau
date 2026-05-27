---------- SERVICES ----------


local ReplicatedServer = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")


---------- MODULES ----------


	-- References
local Modules = ServerScriptService.Modules
local RunStructures = Modules.Structures.RunStructures
	-- ServerScript Dependencies
local StructurePlaceHandler = require(Modules.Structures.Placement.StructurePlaceHandler)
local RunStructuresSetup = require(Modules.Structures.Shared.RunStructuresSetup)
	-- Structure Run Modules
local RunGenerator = RunStructures.BaseGenerator.RunGenerator
local RunModifier = RunStructures.BaseModifier.RunModifier
local RunSeller = RunStructures.BaseSeller.RunSeller

-- Events
local InitStructurePlace = ReplicatedServer.Events.Structures.Placement.InitStructurePlace
local StructurePlace = ReplicatedServer.Events.Structures.Placement.StructurePlace


-- Variables
local activeGenerators = {}
local activeModifiers = {}
local activeSellers = {}

-- Startup
require(Modules.Core.ProfileStoreManager)
require(Modules.Currencies.Essence.Handler)

-- Initial and Runtime Structure Placement
InitStructurePlace.Event:Connect(function(structure_Model, structure_Name, structure_Tier, structure_CFrame, structure_Rotation, creatingData, ID)
	StructurePlaceHandler.validatedPlace(structure_Model, structure_Name, structure_Tier, structure_CFrame, structure_Rotation, creatingData, ID)
end)

StructurePlace.OnServerInvoke = function(player, structureName, structure_CFrame, structureRotation)
	return StructurePlaceHandler.place(player, structureName, structure_CFrame, structureRotation)
end

-- Initial and Runtime structure functionalities
RunStructuresSetup.setup("Generators", RunGenerator, "runGenerator", activeGenerators)
RunStructuresSetup.setup("Modifiers", RunModifier, "runModifier", activeModifiers)
RunStructuresSetup.setup("Sellers", RunSeller, "runSeller", activeSellers)


--[[

	TO-DO

	Restructure UI
	  Remove Square category in inventory -> Server will display, physically, the most valuable squares
	  Redesign the inventory: Inventory is sleeker with bought and NOT bought rotating structure models
	  Add function: Updates client rendering each time a server data modification is called (PSM)
	  Add Settings Icon (perhaps, could store player settings in a PSM playerstore)

	Organize ModuleScripts and hierarchies

	Add Structure Properties
	  Add new live functions: Move, Store, Sell, etc.
	  Add new UI on right-click

	Add new structures
	  Add new ModuleScript: Modular structure additions and functionalities

	Modifier Luck Application Revamp
	  1. Luck stacking: diminishing returns -> compounded luck = (1) + sum(Luck_i - 1)/ i^2
	  2. Luck upgrade cost curve: cost = 20x^5 per level
	  3. Luck per level: luck = (1) + x^2 / 400
	
	Add platforms
	  Platforms: seperates factory lines -> max 1 generator/seller, but infinite modifiers
	  Add a platform overview -> players can edit placements or size of a platform
	  Platform configurations
	
	Add modifier types (Prestige #)
		Resurrection 1: Splitter = chance to duplicate squares
		Resurrection 2: Reroller = chance to reroll the worst attribute
		
		Transcendence 1: Support = adds an upgrade to EVERY modifier
	  
cd "C:\Users\Huy\OneDrive\Documents\ScriptingProjects\Grid Progression"
$env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")
rojo syncback --input "C:\Users\Huy\OneDrive\Documents\GridProgression.rbxl"
git add .
git commit -m "update scripts"
git push

Events.Currencies.Essence.EssenceInit
Events.Currencies.Essence.EssenceReset
Events.Currencies.Essence.EssenceUpgrade

Events.Data.GetProfile
Events.Data.GetData
Events.Data.GetInitProfile

Events.Gui.SystemGuiUpdate
Events.Gui.UpdateStatistics

Events.Structures.Functionality.ExecuteProperties
Events.Structures.Gui.InventoryAddStructure
Events.Structures.Placement.StructurePlace
Events.Structures.Placement.InitStructurePlace


]]




