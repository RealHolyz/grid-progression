---------- Init. Variables ----------

local Essence = {}

local Formatter = require(game:GetService("ReplicatedStorage").Modules.Misc.Formatter)
local Events = game:GetService("ReplicatedStorage").Events

local Essence_Model = workspace.SpawnParts.EssenceParts:FindFirstChild("EssenceModel")

-- Main Board
local ScreenPart = Essence_Model:WaitForChild("ScreenPart")
local ScreenGui = ScreenPart:WaitForChild("SurfaceGui")
local EssencePointsText = ScreenGui:WaitForChild("Points")
local EssenceButton = ScreenGui:WaitForChild("Button")
local Essence_Trigger = Essence_Model:FindFirstChild("EssenceTrigger")

-- Upgrade Table
local Scroll = workspace.SpawnParts.EssenceParts.PostVisuals.ScreenModel.ScreenPart.SurfaceGui.ScrollingFrame

local EssencePoints = 0

---------- Local Functions ----------
 


---------- Main Functions ----------

function Essence.updateApproxEssence(tokens)
	EssencePoints = math.sqrt(tokens) / 250
	EssencePointsText.Text = Formatter.format(EssencePoints)
end

---------- Events ----------

EssenceButton.Activated:Connect(function(onResult)
	Events.EssenceReset:FireServer(EssencePoints)
end)

for _, frame in Scroll:GetChildren() do

	-- Upgrades respectively -> UpgradeType
	local UpgradeButton: TextButton = frame:WaitForChild("Button")
	UpgradeButton.Activated:Connect(function()
		local success, CanBuy, Data = Events.EssenceUpgrade:InvokeServer(tostring(frame.Name))
		if success and CanBuy then
			-- Actually Update the Upgrade Board using Data
			Events.EssenceUpgrade:InvokeServer(frame.Name)
		elseif success and not CanBuy then
			-- Gui Appears -> "Insufficient Essence"
		else
			print("Error: StarterPlayerScripts...Essence (Essence Gui Handler)")
		end
		
	end)
end

-- TODO: Update the Gui, Check other scripts for global profile changes (factor implmentation)
return Essence
