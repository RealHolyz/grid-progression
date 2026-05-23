local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local ProfileStore = require(ServerScriptService.Libraries.ProfileStore)
local DefaultServerDataTemplate = require(ReplicatedStorage.Modules.ProfileStoreDependencies.DefaultServiceDataTemplate)
local StructureFactory = require(ServerScriptService.Modules.StructureFactory)
local StructureFunctionsProperties = require(ServerScriptService.Modules.StructureFunctionalities.StructureFunctionsProperties)

local Events = ReplicatedStorage:WaitForChild("Events")
local GetProfileEvent = Events.GetProfile
--[[

ProfileServerModule Routine:
	1. ServerScript boots up ProfileStoreManager
	2. PSM loads data: PrivateServerOwnerID ? private : public
		if private:
			Key: "Private_" .. PrivateServerOwnerID
			Value: StartSessionAsync object (from ProfileStore)
		if public
			Starts from DefaultServerDataTemplate
			
]]

-- Checks if the server type is public or private OR playtesting
local ownerID = game.PrivateServerOwnerId
local ServerType = "Public"
local privateServerKey = "Private_" .. tostring(ownerID + 11) -- welp time to increase this every time i run out of structures
local isReady = false

if ownerID then 
	ServerType = "Private" 
end

if RunService:IsStudio() then
	ServerType = "Test_" .. ServerType
end

-- World Data Init Variables
local worldData
local worldProfile

-- Creates a ProfileStore Object (public/private)
local ServerStore = ProfileStore.New(privateServerKey, DefaultServerDataTemplate.DEFAULT_SERVER_DATA)
local Profiles: {[string]: typeof(ServerStore:StartSessionAsync())} = {}

local Shared = {}
local Local = {}

----- Local -----

-- Loads the server profile !!PRIVATE SERVERS!!
function Local.LoadProfile(server: string)
	local profile = ServerStore:StartSessionAsync(privateServerKey)
	profile:Reconcile()
end 

-- Loads server data
function Local.OnStart()
	if ServerType == "Private" or ServerType == "Test_Private" then
		
		-- Get the private world save
		worldProfile = ServerStore:StartSessionAsync(privateServerKey)
		-- Load in the place with private server data
		
		if worldProfile then
			worldProfile:Reconcile()
			worldData = worldProfile
		end
	else
		-- Public servers start from scratch: a default template
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

----- Shared -----

-- Returns server data
function Shared.GetData()
	return worldData
end

-- Returns server profile (serverside)
function Shared.GetProfile()
	worldProfile:Reconcile()
	return worldProfile
end

function Shared.ReconcileProfile()
	worldProfile:Reconcile()
end

-- Returns server profile on GetProfile
GetProfileEvent.OnServerInvoke = function(player)
	return worldProfile
end

----- Misc. -----
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
	worldProfile:Reconcile()
	print(worldProfile)
	local profile_PlacedStructures = worldProfile.Data.PlacedStructures
	
	for ID, structure in pairs(profile_PlacedStructures) do
		 
		local structure_Name = structure.Type
		local structure_Rotation = structure.rotation
		local structure_CFrame = CFrame.new(structure.Position.X, structure.Position.Y, structure.Position.Z) * CFrame.Angles(0, math.rad(structure_Rotation), 0)
		local structure_Tier = structure.Data.Tier
		
		local structure_Model = ReplicatedStorage.StructureBaseModels:WaitForChild(structure_Name)
		
		Events.InitStructurePlace:Fire(structure_Model, structure_Name, structure_Tier, structure_CFrame, structure_Rotation, false, ID)
	end
	
	Events.GetInitProfile:FireClient(player, returnCurrentStructureData())
	Events.UpdateStatistics:FireAllClients(worldProfile)
end)

local ExecuteProperties = game:GetService("ReplicatedStorage").Events.ExecuteProperties

ExecuteProperties.OnServerInvoke = function(player, structure, property)
	local profile_data = Shared.GetProfile()
	StructureFunctionsProperties.executeProperties(player, structure, property, profile_data)
end

Local.OnStart()

return Shared
