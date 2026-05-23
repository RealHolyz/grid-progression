-- Game Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local SideFrame = {}

-- Uninitialized Variables
local rotateConnection
local currentModel

-- Nil Variables
local currentStructure = nil

-- Main Structural Frames / Components
local sideFrame = game:GetService("Players").LocalPlayer.PlayerGui.ScreenGui.Inventory.SideFrames
local structureSideFrame = sideFrame.StructuresSideFrame
local descriptionBox = structureSideFrame.DescriptionBox

-- Viewport
local viewportCamera = Instance.new("Camera")
viewportCamera.CFrame = CFrame.new(0, 0, 25)

local viewportFrame = structureSideFrame.ViewportFrame
viewportFrame.CurrentCamera = viewportCamera

viewportCamera.Parent = viewportFrame


local structureDescriptions = {
	BaseGenerator = "It generates some RNG dependent squares...maybe sell them?",
	BaseModifier = "Adds a modifier to your squares.",
	BaseSeller = "Transport your squares into this seller for rarity points."
}

function SideFrame.loadSideFrame(structureData)

	descriptionBox.Text = structureDescriptions[structureData.Type]

	viewportFrame.ViewportModel:ClearAllChildren()

	if rotateConnection then
		rotateConnection:Disconnect()
		rotateConnection = nil
	end

	local tempModel = ReplicatedStorage.StructureBaseModels[structureData.Type]:Clone()
	tempModel.Parent = viewportFrame.ViewportModel
	currentModel = tempModel

	rotateConnection = RunService.PreRender:Connect(function(dt)
		if currentModel then
			currentModel:PivotTo(currentModel:GetPivot() * CFrame.Angles(0, math.rad(60) * dt, 0))
		end
	end)

	currentStructure = structureData.Type
	
	return currentStructure
end

return SideFrame
