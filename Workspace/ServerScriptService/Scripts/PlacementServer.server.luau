-- Services
local ReplicatedServer = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

-- Modules
	-- References
local Modules = ServerScriptService.Modules
local StructureFunctionalities = Modules.StructureFunctionalities
	-- ServerScript Dependencies
local StructurePlaceModule = require(Modules.StructurePlaceModule)
local RunStructuresSetup = require(StructureFunctionalities.RunStructuresSetup)
	-- Structure Run Modules
local RunGenerator = StructureFunctionalities.BaseGenerator.RunGenerator
local RunModifier = StructureFunctionalities.BaseModifier.RunModifier
local RunSeller = StructureFunctionalities.BaseSeller.RunSeller

-- Events
local InitStructurePlace = ReplicatedServer.Events.InitStructurePlace
local StructurePlace = ReplicatedServer.Events.StructurePlace


-- Variables
local activeGenerators = {}
local activeModifiers = {}
local activeSellers = {}

-- Startup
require(Modules.ProfileStoreManager)

-- Initial and Runtime Structure Placement
	-- Initial Structure Setup
InitStructurePlace.Event:Connect(function(structure_Model, structure_Name, structure_Tier, structure_CFrame, structure_Rotation, creatingData, ID)
	StructurePlaceModule.validatedPlace(structure_Model, structure_Name, structure_Tier, structure_CFrame, structure_Rotation, creatingData, ID)
end)

	-- Runtime Structure Setup
StructurePlace.OnServerInvoke = function(player, structureName, structure_CFrame, structureRotation)
	return StructurePlaceModule.place(player, structureName, structure_CFrame, structureRotation)
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

]]




