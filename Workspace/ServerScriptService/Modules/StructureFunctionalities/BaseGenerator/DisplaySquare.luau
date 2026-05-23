local PhysicsService = game:GetService("PhysicsService")


local DisplaySquare = {}

PhysicsService:RegisterCollisionGroup("Squares")
PhysicsService:CollisionGroupSetCollidable("Squares", "Squares", false)

function DisplaySquare.build_InitialDisplay(BaseGenerator_CFrame, BaseSeller, isComputed)
	
	-- Creating the square instance
	local square = Instance.new("Part")
	--square.Name = "Square_" .. square_Rarity
	square.Parent = game.Workspace.GeneratedSquares
	square.Name = "Square"
	square.Size = Vector3.new(4, 1, 4)
	square.Position = BaseGenerator_CFrame.Position + Vector3.new(0, 9, 0)
	square.Anchored = false	
	square.CanCollide = true
	square.Transparency = 0.4
	
	square.CollisionGroup = "Squares"
	
	-- Luck
	square:SetAttribute("Luck", 1)
	
	-- Creating the surfaceGUI
	local surfaceGui = Instance.new("SurfaceGui")
	surfaceGui.Name = "RarityDisplay"
	surfaceGui.Parent = square
	surfaceGui.Adornee = square
	surfaceGui.Face = Enum.NormalId.Top
	
	local textLabel = Instance.new("TextLabel")
	textLabel.Name = "RarityText"
	textLabel.Parent = surfaceGui
	textLabel.Size = UDim2.new(1, 0, 1, 0)
	textLabel.BackgroundTransparency = 1
	textLabel.TextScaled = true
	textLabel.Font = Enum.Font.RobotoMono
	textLabel.TextStrokeTransparency = 0.1
	-- Change this to the luck attribute later
	textLabel.Text = string.format('Luck: 1x')
	
	isComputed = true
	square:SetAttribute("Computed", isComputed)
	square:SetNetworkOwner(nil)
end

return DisplaySquare
