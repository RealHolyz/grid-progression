---------- SERVICES ----------


local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")


---------- EVENTS ----------


local Events = ReplicatedStorage.Events


---------- Init. Var ----------


local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
local screenGui = playerGui:WaitForChild("ScreenGui")

local Inventory = screenGui:WaitForChild("Inventory")
local InventoryFrame = Inventory:WaitForChild("InventoryFrame")

local CategoryPage = InventoryFrame:WaitForChild("CategoryPage")
local ItemsPage = InventoryFrame:WaitForChild("ItemsPage")
local button = screenGui:WaitForChild("DisplayButtons"):WaitForChild("InventoryButton")
local sideFrame = Inventory:WaitForChild("SideFrames")

local activePropertiesStructures = {}


---------- MODULES ----------


local PlayerScripts = Players.LocalPlayer.PlayerScripts

local UI = PlayerScripts.Modules.UI

local InventoryModule = require(UI.Inventory)
local SideFrameModule = require(UI.SideFrame)
local EditStructureClient = require(PlayerScripts.Modules.EditStructureClient)
local StatisticsDisplay = require(UI.StatisticsDisplay)


---------- LISTENERS ----------


CategoryPage.Structures.MouseButton1Click:Connect(function()
	Inventory.showPage("Structures")
end)

CategoryPage.Squares.MouseButton1Click:Connect(function()
	Inventory.showPage("Squares")
end)

Events.Data.GetInitProfile.OnClientEvent:Connect(function(profileData)
	for _, structure in ipairs(profileData) do
		InventoryModule.buildButtons(structure, true)
	end
end)

button.MouseButton1Click:Connect(function()
	InventoryModule.toggleVisibility()
end)

sideFrame.StructuresSideFrame.StartPlace.Activated:Connect(function()
	InventoryModule.startPlacing()
end)

Events.Structures.Gui.InventoryAddStructure.OnClientEvent:Connect(function(structure, isInitial)
	InventoryModule.buildButtons(structure, isInitial)
end)

Events.Gui.UpdateStatistics.OnClientEvent:Connect(function(data)
	StatisticsDisplay.displayStats(data)
end)

EditStructureClient.runProperties(activePropertiesStructures)
-- Remember to account for visual counter of structures