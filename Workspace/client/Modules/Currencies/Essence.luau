local Essence = {}


---------- SERVICES ----------


local ReplicatedStorage = game:GetService("ReplicatedStorage")


---------- MODULES ----------

local Formatter = require(ReplicatedStorage.Modules.Misc.Formatter)

local Events = ReplicatedStorage.Events

local Essence_Model = workspace.SpawnParts.EssenceParts:FindFirstChild("EssenceModel")

-- Main Board
local ScreenPart = Essence_Model:WaitForChild("ScreenPart")
local ScreenGui = ScreenPart:WaitForChild("SurfaceGui")
local EssencePointsText = ScreenGui:WaitForChild("Points")
local EssenceButton = ScreenGui:WaitForChild("Button")
local Essence_Trigger = Essence_Model:FindFirstChild("EssenceTrigger")

-- Upgrade Table
local Scroll = workspace.SpawnParts.EssenceParts.PostVisuals.ScreenModel:WaitForChild("ScreenPart").SurfaceGui.ScrollingFrame

local EssencePoints = 0

---------- Local Functions ----------

-- Applies Current Effect Text -> updateEntireUpgradeBoard(...)
local function applyCurrentEffectText(frameName, Factor)
	local textDict = {
		AutoUpgrade = `Auto Upgrading(?)`,
		BaseLuckIncrease = `+{Formatter.format(Factor)} Base Luck`,
		ModifierCountIncrease = `+{Formatter.format(Factor)} Modifiers`,
		UpgradeBargain = `{math.floor(Factor * 10000)/100}% Off`
	}
	
	for name, text in textDict do
		if frameName == name then
			return text
		end
	end
end

-- Sets the text of a Frame to MAXED
local function MaxedUpgradeText(frameName: Frame)
	local frame = Scroll:WaitForChild(frameName)
	
	local OldButton: TextButton = frame:WaitForChild("Button")
	
	local Button: TextButton = OldButton:Clone()
	
	OldButton:Destroy()
	frame.NextUpgradeCostDescription.Text = ""
	frame.NextUpgradeCost. Text = ""
	
	Button.Parent = Scroll:WaitForChild(frameName)
	
	Button.Active = false
	Button.BackgroundColor3 = Color3.new(0.243137, 0.14902, 0.0784314)
	Button.TextColor3 = Color3.new(0.772549, 0.482353, 0.247059)
	Button.TextStrokeColor3 = Color3.new(0.772549, 0.482353, 0.247059)
	Button.Text = "MAXED"
	Button.FontFace.Bold = true
	Button.FontFace.Style = Enum.FontStyle.Italic
	Button.Interactable = false
	Button.TextSize = 75
end

-- Updates the Essence Upgrade Board on Initialization
local function updateEntireUpgradeBoard(Map, isMaxedTable)
	for k, frame in Scroll:GetChildren() do
		local UpgradeData = Map[tostring(frame.Name)]
		if isMaxedTable[frame.Name] then
			MaxedUpgradeText(frame.Name)
		end
		
		frame:WaitForChild("CurrentEffect").Text = applyCurrentEffectText(frame.Name, UpgradeData.Factor)		-- CurrentEffect.Text = Factor of that Type of Upgrade
		frame:WaitForChild("NextUpgradeCost").Text = Formatter.format(UpgradeData.Cost)							-- NextUpgradeCost.Text = Cost of that Type of Upgrade
	end
end

-- Updates the Essence Upgrade Board on Upgrade
local function updateSingularUpgrade(UpgradeTypeTable, UpgradeType, isMaxedUpgrade)
	for _, frame in Scroll:GetChildren() do
		if frame.Name == UpgradeType then
			frame:WaitForChild("CurrentEffect").Text = applyCurrentEffectText(frame.Name, UpgradeTypeTable.Factor)
			frame:WaitForChild("NextUpgradeCost").Text = Formatter.format(UpgradeTypeTable.Cost)
			
			if isMaxedUpgrade then
				MaxedUpgradeText(frame.Name)
			end
		end
	end
end
---------- Main Functions ----------

-- Calculates and Displays Essence Points
function Essence.updateApproxEssence(tokens)
	EssencePoints = math.sqrt(tokens) / 250
	EssencePointsText.Text = Formatter.format(EssencePoints)
end

---------- Events ----------

-- When the Essence Reset Button is activated, call the server for reset implementations
EssenceButton.Activated:Connect(function(onResult)
	Events.Currencies.Essence.EssenceReset:InvokeServer(EssencePoints)
end)

-- When player clicks on a certain upgrade button, call server to upgrade and update gui
for _, frame in Scroll:GetChildren() do
	local UpgradeButton: TextButton = frame:WaitForChild("Button")
	UpgradeButton.Activated:Connect(function()
		local CanBuy, UpgradeTypeTable, UpgradeType, isMaxedUpgrade = Events.Currencies.Essence.EssenceUpgrade:InvokeServer(frame.Name)
		if CanBuy then
			updateSingularUpgrade(UpgradeTypeTable, UpgradeType, isMaxedUpgrade)
		end
	end)
end


-- Request initial data on startup (avoids race condition with FireAllClients)
task.spawn(function()
	local initData = Events.Data.GetProfile:InvokeServer()
	if initData then
		local data, isMaxedTable = Events.Currencies.Essence.EssenceInit:InvokeServer()
		updateEntireUpgradeBoard(data, isMaxedTable)
	end
end)



-- TODO: Update the Gui, Check other scripts for global profile changes (factor implmentation)
return Essence
