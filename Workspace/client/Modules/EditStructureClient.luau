local EditStructureClient = {}

local propertiesMap = {
	BaseGenerator = {"Move", "Sell", "Store", "Upgrade", "View Stats", "Exit"},
	BaseModifier = {"Move", "Sell", "Store", "Upgrade", "View Stats", "Exit"},
	BaseSeller = {"Move", "Sell", "Store", "Upgrade", "View Stats", "Exit"}
}

local function store(structure)
	--[[
	In order to store the structure:
		Set up or get data attributes of the structure (refer to StructureFactory)
	]]
end

local function showProperties(structure: Model)
	local billboardGUI = Instance.new("BillboardGui")
	billboardGUI.Parent = structure
	billboardGUI.Adornee = structure.PrimaryPart
	billboardGUI.Size = UDim2.new(0, 200, 0, 50)
	billboardGUI.StudsOffset = Vector3.new(10, 5, 0)
	billboardGUI.Enabled = true
	billboardGUI.AlwaysOnTop = true

	local frame = Instance.new("Frame")
	frame.Parent = billboardGUI
	frame.Size = UDim2.new(1, 0, 1, 0)
	frame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
	frame.BackgroundTransparency = 0.2
	frame.BorderSizePixel = 1
	
	local UIPadding = Instance.new("UIPadding")
	UIPadding.Parent = frame
	UIPadding.PaddingTop = UDim.new(0, 5)
	UIPadding.PaddingBottom = UDim.new(0, 5)
	UIPadding.PaddingLeft = UDim.new(0, 5)
	UIPadding.PaddingRight = UDim.new(0, 5)
	
	local UICorner = Instance.new("UICorner")
	UICorner.Parent = frame
	UICorner.CornerRadius = UDim.new(0, 10)
	
	local UIGridLayout = Instance.new("UIGridLayout")
	UIGridLayout.Parent = frame
	UIGridLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	UIGridLayout.VerticalAlignment = Enum.VerticalAlignment.Center
	UIGridLayout.CellPadding = UDim2.new(0, 2, 0, 2)
	UIGridLayout.CellSize = UDim2.new(0.323, 0, 0.5, 0)
	
	for _, property in ipairs(propertiesMap[`{structure.Name}`]) do
		local textbutton = Instance.new("TextButton")
		textbutton.Name = property
		textbutton.Parent = frame
		textbutton.Size = UDim2.new(0, 10, 0, 5)
		textbutton.BackgroundColor3 = Color3.new(0.529412, 0.529412, 0.529412)
		textbutton.Text = property
		textbutton.Font = Enum.Font.Highway
		textbutton.TextSize = 14
		
		local UICorner = Instance.new("UICorner")
		UICorner.Parent = textbutton
		UICorner.CornerRadius = UDim.new(0, 5)
	end
end

local function hideProperties(structure: Model)
	local billboardGUI = structure:WaitForChild("BillboardGUI")
	billboardGUI.Enabled = false
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
