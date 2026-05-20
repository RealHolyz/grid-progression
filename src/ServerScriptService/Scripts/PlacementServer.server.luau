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
local StructurePlace = ReplicatedServer.Events.StructurePlace

-- Variables
local activeGenerators = {}
local activeModifiers = {}
local activeSellers = {}

-- Startup
require(Modules.ProfileStoreManager)

-- Placing Structures
StructurePlace.OnServerInvoke = function(player, structureName, structure_CFrame, structureRotation)
	return StructurePlaceModule.place(player, structureName, structure_CFrame, structureRotation)
end

-- Initial and Runtime structure functionalities
RunStructuresSetup.setup("Generators", RunGenerator, "runGenerator", activeGenerators)
RunStructuresSetup.setup("Modifiers", RunModifier, "runModifier", activeModifiers)
RunStructuresSetup.setup("Sellers", RunSeller, "runSeller", activeSellers)


--[[

Modules that require ProfileStoreManager -> To be replaced with DataStore
	DataStoreService: Handles data management for a unique server ID
	
	1. Main ServerScript: Starts DataStoreService and module setups
	2. DataStoreService:
		if private: grabs data using "PrivateWorld_" .. PrivateServerOwnerID if it exists
		if public: starts from default world template module
	3. Autosave using DataStore Service
	4. Save on server IsClosing
	
	No:
		DisplaySquare - Builds initial display from a generator
		RunGenerator - Spawns a single thread to spawn squares for live generators using DisplaySquare
		RunModifier - Spawns a single thread to apply modifiers to all squares using StructureAttributes
		AttributesModule - Square attributes calculations and returns important square data
		RunStructureSetup - Generalized structure setup for all structures
		StructureAttributes - Handles attributes (upgrades, rate of cost, etc.)
		StructureFactory - Returns a structure table for the client to use
		StructureManager - Physical creation or removal of structures
		EditStructureClient - Client right clicks to show properties
		PlacementClient - Handles placing previews and feedback from PlacementServer
		
		
	Yes:
		RunSeller - Handles square rarity/attribute calculations, uses ProfileStoreManager to get player data -> modifies Rarity Points
		StructurePlaceModule - Handles physical placement and data modification, ex. # of structures owned, 
		PlacementServer - Boots up ProfileStoreManager
		PlayerData - Default player template for ProfileStoreManager
	
	Once DataStoreService and MemoryStoreService is implemented, 
		
		
		
]]



