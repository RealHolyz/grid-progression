local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local ProfileStore = require(ServerScriptService.Libraries.ProfileStore)
local DefaultServerDataTemplate = require(ReplicatedStorage.Modules.ProfileStoreDependencies.DefaultServiceDataTemplate)
local StructureFactory = require(ServerScriptService.Modules.StructureFactory)
local StructureFunctionsProperties = require(ServerScriptService.Modules.StructureFunctionalities.StructureFunctionsProperties)

local Events = ReplicatedStorage:WaitForChild("Events")
local GetProfileEvent = Events.GetProfile


---------- TESTING  ----------

local TESTING = true
local TESTING_PUBLIC = false
local TESTING_VARIABLES = true
local TESTING_NUMBER = 6

local TESTING_INIT_TOKENS = 10000000
local TESTING_INIT_ESSENCE = 0

local TESTING_TIER_MAP = {
	["BaseGenerator"] = 0,
	["BaseModifier"] = 0,
	["BaseSeller"] = 0,
}

---------- INIT. PROFILE/ DATA ----------

local ownerID = game.PrivateServerOwnerId

-- TEST_PRIVATE NUMBER
if not TESTING_PUBLIC and TESTING then
	ownerID += TESTING_NUMBER
end

local ServerType = "Public"
local privateServerKey = "Private_" .. tostring(ownerID)
local isReady = false

if (ownerID ~= 0 and ownerID ~= "") then
	if TESTING and not TESTING_PUBLIC then
		print("Private Test Server")
		ServerType = "Test_Private"
		privateServerKey = "Test_" .. privateServerKey
	else
		print("Private Server")
		ServerType = "Private"
	end
else
	--privateServerKey = nil
	if TESTING then
		print("Public Test Server")
		ServerType = "Test_Public"
	else
		print("Public Server")
		ServerType = "Public"
	end
end

-- World Data Init Variables
local worldData
local worldProfile

-- Creates a ProfileStore Object (public/private)
local ServerStore = ProfileStore.New(privateServerKey, DefaultServerDataTemplate.DEFAULT_SERVER_DATA)
local Profiles: {[string]: typeof(ServerStore:StartSessionAsync())} = {}

local Shared = {}
local Local = {}


-------------------- Local --------------------

-- Loads the server profile
function Local.LoadProfile(server: string)
	local profile = ServerStore:StartSessionAsync(privateServerKey)
	profile:Reconcile()
end 

-- Loads server data based on key
function Local.OnStart()
	
	-- PRIVATE SERVERS --
	if ServerType == "Private" or ServerType == "Test_Private" then
		
		-- Get the private world save and push profile to current server data
		worldProfile = ServerStore:StartSessionAsync(privateServerKey)
		
		if worldProfile then
			worldProfile:Reconcile()
			worldData = worldProfile
		end
		
		if TESTING and TESTING_VARIABLES and not TESTING_PUBLIC then
			worldProfile.Data.Tokens = TESTING_INIT_TOKENS
			worldProfile.Data.Essence = TESTING_INIT_ESSENCE
			worldProfile:Reconcile()
		end
		
	-- PUBLIC SERVERS --
	else
		-- Starts with a fresh template
		worldData = {
			Data = table.clone(DefaultServerDataTemplate.DEFAULT_SERVER_DATA)
		}
	end
	
	isReady = true
end

-- On server closing, autosave server data !!PRIVATE SERVERS!!
game:BindToClose(function(server: string)
	local profile = Profiles[server]
	if profile ~= nil then
		profile:EndSession()
	end
end)


-------------------- Shared --------------------


-- Returns server data
function Shared.GetData()
	return worldData
end

-- Returns server profile 
function Shared.GetProfile()
	if not worldProfile then return worldData end
	worldProfile:Reconcile()
	return worldProfile
end

-- Reconciles profile
function Shared.ReconcileProfile()
	if not worldProfile then return end
	worldProfile:Reconcile()
end

-- Returns server profile on GetProfile
GetProfileEvent.OnServerInvoke = function(player)
	if not worldProfile then return worldData end
	worldProfile:Reconcile()
	return worldProfile
end


-------------------- Misc. --------------------


-- Returns the current state of profile's structures count
local function returnCurrentStructureData()
	local data = {}
	for structure, count in pairs(worldData.Data.Structures) do
		if count >= 1 then
			table.insert(data, StructureFactory.CreateStructure(structure, 1, Vector3.new(0, 0, 0), 0))
		end
	end
	return data
end

-- Player added, load their UI
Players.PlayerAdded:Connect(function(player)
	while not isReady do
		task.wait()
	end
	
	-- Get profile data -> init PlacedStructures
	if worldProfile then 
	
		worldProfile:Reconcile()
		
		local profile_PlacedStructures = worldProfile.Data.PlacedStructures
		
		for ID, structure in pairs(profile_PlacedStructures) do
			
			local structure_Name = structure.Type
			local structure_Rotation = structure.rotation
			local structure_CFrame = CFrame.new(structure.Position.X, structure.Position.Y, structure.Position.Z) * CFrame.Angles(0, math.rad(structure_Rotation), 0)
			
			if TESTING and TESTING_VARIABLES and not TESTING_PUBLIC then
				structure.Data.Tier = TESTING_TIER_MAP[tostring(structure_Name)]
			end
			
			local structure_Tier = structure.Data.Tier
			local structure_Model = ReplicatedStorage.StructureBaseModels:WaitForChild(structure_Name)
			
			Events.InitStructurePlace:Fire(structure_Model, structure_Name, structure_Tier, structure_CFrame, structure_Rotation, false, ID)
		end
	end
	
	-- Update time
	task.spawn(function()
		while true do
			task.wait(1)
			worldData.Data.TotalTime += 1
			Events.UpdateStatistics:FireAllClients(worldData)
		end
	end)
	
	-- Init GUI
	Events.GetInitProfile:FireClient(player, returnCurrentStructureData())
	
	-- Init stats
	Events.UpdateStatistics:FireAllClients(worldData)
	
	-- Init. general data
	Events.GetData:FireAllClients(worldData)
end)

local ExecuteProperties = game:GetService("ReplicatedStorage").Events.ExecuteProperties

ExecuteProperties.OnServerInvoke = function(player, structure, property)
	local profile_data = Shared.GetProfile()
	StructureFunctionsProperties.executeProperties(player, structure, property, profile_data)
end

Local.OnStart()

return Shared
