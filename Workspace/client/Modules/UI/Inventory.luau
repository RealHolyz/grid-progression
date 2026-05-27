local Inventory = {}


---------- SERVICES ----------


local Players = game:GetService("Players")
local StarterPlayer = game:GetService("StarterPlayer")
local ReplicatedStorage = game:GetService("ReplicatedStorage")


---------- MODULES ----------


local playerGui = Players.LocalPlayer.PlayerGui
local StarterPlayerScriptsModules = StarterPlayer.StarterPlayerScripts.Modules

local SideFrameModule = require(StarterPlayerScriptsModules.UI.SideFrame)
local PlacementClient = require(StarterPlayerScriptsModules.PlacementClient)

---------- EVENTS ----------

local Events = ReplicatedStorage.Events
local GetProfileEvent = Events.Data.GetProfile


---------- Main Structural Frames / Components ----------


local InventoryFrame = playerGui.ScreenGui.Inventory.InventoryFrame
local SideFrame = playerGui.ScreenGui.Inventory.SideFrames
local InventoryButton = InventoryFrame.Parent.Parent.DisplayButtons.InventoryButton
	-- Inventory Frame Children
local CategoryPage = InventoryFrame.CategoryPage
local ItemsPage = InventoryFrame.ItemsPage
local Templates = InventoryFrame.Templates

local Templates_Folder = Templates.Structures
	-- Items Categories
local pages = {
	Squares = ItemsPage.Squares_ScrollingFrame,
	Structures = ItemsPage.Structures_ScrollingFrame
}

---------- Init. Var ----------


	-- Nil Variables
local currentButton = nil
local currentStructure = nil
	-- Misc.
local player = game.Players.LocalPlayer


---------- FUNCTIONS ----------


function Inventory.showPage(pageName)
	for name, frame in pairs(pages) do
		local isVisible = (name == pageName)
		frame.Visible = isVisible
		frame.Interactable = isVisible
	end
end

function Inventory.buildButtons(structure, isInitial)
	
	local child = nil
	
	if isInitial then
		child = structure.Type
	elseif isInitial == false then
		child = structure
	else
		print("ERROR")
	end
	
	local template = Templates_Folder:FindFirstChild(`{child}_Template`)
	local button = template:Clone()
	
	
	button.Visible = true
	button.Parent = pages.Structures
	button.Text = child
	button.BackgroundColor = BrickColor.new("Light stone grey")

	local UICorner = Instance.new("UICorner")
	UICorner.Parent = button
	UICorner.CornerRadius = UDim.new(0, 10)

	local UIStroke = Instance.new("UIStroke")
	UIStroke.Parent = button
	UIStroke.Thickness = 2
	UIStroke.Color = BrickColor.new("Mid gray").Color

	button.MouseButton1Click:Connect(function()

		if currentButton == button then

			SideFrame.GroupTransparency = 1
			SideFrame.Interactable = false
			SideFrame.Active = false

			currentButton = nil

		else

			currentButton = button

			SideFrame.GroupTransparency = 0
			SideFrame.Interactable = true
			SideFrame.Active = true

			currentStructure = SideFrameModule.loadSideFrame(structure, isInitial)

		end
	end)
end

function Inventory.toggleVisibility()
	if InventoryFrame.GroupTransparency == 1 then

		InventoryFrame.GroupTransparency = 0
		InventoryFrame.Interactable = true
		InventoryFrame.Active = true

		pages.Structures.Interactable = true
		pages.Squares.Interactable = true

	else

		InventoryFrame.GroupTransparency = 1
		InventoryFrame.Interactable = false
		InventoryFrame.Active = false


		SideFrame.GroupTransparency = 1
		SideFrame.Interactable = false
		SideFrame.Active = false

		currentButton = nil
	end
end

function Inventory.startPlacing()
	InventoryFrame.GroupTransparency = 1
	InventoryFrame.Interactable = false
	InventoryFrame.Active = false

	SideFrame.GroupTransparency = 1
	SideFrame.Interactable = false
	SideFrame.Active = false

	InventoryButton.Transparency = 1
	InventoryButton.ImageTransparency = 1
	InventoryButton.Interactable = false
	InventoryButton.Active = false

	currentButton = nil

	local succeed = PlacementClient.StartPlacement(player, currentStructure, function(succeed)
		if succeed then
			InventoryFrame.GroupTransparency = 0
			InventoryFrame.Interactable = true
			InventoryFrame.Active = true

			SideFrame.GroupTransparency = 0
			SideFrame.Interactable = true
			SideFrame.Active = true

			InventoryButton.Transparency = 0
			InventoryButton.ImageTransparency = 0
			InventoryButton.Interactable = true
			InventoryButton.Active = true

			local data = GetProfileEvent:InvokeServer()
			
			if not data then return end
			
			if data.Data.Structures[currentStructure] == 0 then
				InventoryFrame.ItemsPage.Structures_ScrollingFrame:WaitForChild(`{currentStructure}_Template`):Destroy()
			end
		end
	end)
end

function Inventory.addButtonsConditionals(structure)
	Inventory.buildButtons(structure)
end


--------------------


return Inventory
