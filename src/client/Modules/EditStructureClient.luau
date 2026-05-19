local EditStructureClient = {}

--[[
	Shows the properties of a structure:
		For all: exit
		Generator:
			Move
			Sell
			Upgrade
			View Stats
			Toggle Active
]]

local propertiesMap = {
	BaseGenerator = {"Move", "Sell", "Upgrade", "View Stats", "ToggleActive", "Exit"},
	BaseModifier = {"Move", "Sell", "Upgrade", "View Stats", "ToggleActive", "Exit"},
	BaseSeller = {"Move", "Sell", "Upgrade", "View Stats", "ToggleActive", "Exit"}
}

local function showProperties(structure: Model)
	local billboardGUI = Instance.new("BillboardGui")
	billboardGUI.Parent = structure
	billboardGUI.Adornee = structure
	billboardGUI.Size = UDim2.new(0, 200, 0, 50)
	billboardGUI.StudsOffset = Vector3.new(10, 5, 0)
	billboardGUI.AlwaysOnTop = true

	local frame = Instance.new("Frame")
	frame.Parent = billboardGUI
	frame.Size = UDim2.new(1, 0, 1, 0)
	frame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
	frame.BackgroundTransparency = 0.2
	frame.BorderSizePixel = 1

	local UICorner = Instance.new("UICorner")
	UICorner.Parent = frame
	UICorner.CornerRadius = UDim.new(0, 10)

	local text = Instance.new("TextLabel")
	text.Parent = billboardGUI
	text.Size = UDim2.new(1, 0, 1, 0)
	text.BackgroundTransparency = 1
	text.Text = table.concat(propertiesMap[structure.Name])
	text.TextScaled = true
	text.TextColor3 = Color3.fromRGB(255, 255, 255)
end

local function hideProperties(structure: Model)
	local billboardGUI = structure:WaitForChild("BillboardGUI")
end

local function addInstances(structure: Model)
	if structure:GetAttribute("EditSetup") then return end
	
	local click = Instance.new("ClickDetector")
	click.Parent = structure
	
	click.RightMouseClick:Connect(function()
		showProperties(structure)
	end)
	
	structure:SetAttribute("EditSetup")
end


local PlacedStructures = workspace.PlacedStructures

function EditStructureClient.runProperties(activeStructures)
	
	-- For initial structures
	for _, structureType_Folder in ipairs(PlacedStructures:GetChildren()) do
		for _, structure in pairs(structureType_Folder:GetChildren()) do
			if not activeStructures[structure] then
				addInstances(structure)

				activeStructures[structure] = true
			end
		end
	end
	
	-- For added structures (ingame)
	for _, structureType_Folder in pairs(PlacedStructures:GetChildren()) do
		structureType_Folder.ChildAdded:Connect(function(structure: Model)
			if not activeStructures[structure] then
				addInstances(structure)
				
				activeStructures[structure] = true
			end
		end)
	end
	
end
return EditStructureClient
