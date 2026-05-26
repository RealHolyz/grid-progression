local PlayerScripts = game:GetService("Players").LocalPlayer.PlayerScripts
local StatisticsGroup = game:GetService("Players").LocalPlayer.PlayerGui.ScreenGui.StatisticsGroup

local Formatter = require(game:GetService("ReplicatedStorage"):WaitForChild("Modules").Misc.Formatter)
local Essence = require(PlayerScripts.Modules.HigherSystems.Essence)

local Events = game:GetService("ReplicatedStorage").Events

local group = StatisticsGroup.CanvasGroup

local TokensText = group.Tokens_Display
local ProfileTimeText = group.ProfileTime_Display
local EssenceText = group.Essence_Display

local StatisticsDisplay = {}


---------- Init. Variables ----------


local previousTokens = 0
local cached_Data = nil
local cached_TPS = nil
local isReady = false


---------- Init. Functions ----------


function StatisticsDisplay.GuiSet(data)
	for System, Unlocked in data.Data.UnlockedSystems do
		local SystemText: TextLabel = group:WaitForChild(`{System}_Display`)
		if Unlocked then
			SystemText.TextTransparency = 0
			for _, part in workspace.SpawnParts[`{System}Parts`]:WaitForChild("PostVisuals"):GetDescendants() do
				if part:IsA("Part") then 
					part.Transparency = 0
					part.CanCollide = true
				end
			end
		end
	end
end

Events.GetData.OnClientEvent:Connect(function(data)
	StatisticsDisplay.GuiSet(data)
end)

---------- Runtime Functions ----------


-- Formats the time
local function timeFormat(seconds)
	
	local hrs = math.floor(seconds/3600)
	local mins = math.floor(seconds/60) % 60
	local secs = seconds % 60
	
	return string.format("%02d:%02d:%02d", hrs, mins, secs)
end

-- Updates tokens per second and higher system approx gained points
task.spawn(function()
	while true do 
		task.wait(1)
		if isReady and cached_Data then
			cached_TPS = cached_Data.Data.Tokens - previousTokens 
			previousTokens = cached_Data.Data.Tokens
		end
		
		Essence.updateApproxEssence(cached_Data.Data.Tokens)
	end	
end)

-- Displays the statistics
function StatisticsDisplay.displayStats(data)
	cached_Data = data
	isReady = true
	
	if cached_TPS == nil then
		task.wait(5)
	end
	
	TokensText.Text = `Tokens: {Formatter.format(data.Data.Tokens)}			T/s: {Formatter.format(cached_TPS)}`
	ProfileTimeText.Text = `Total Time: {timeFormat(data.Data.TotalTime)}`
	EssenceText.Text = `Essence: {Formatter.format(data.Data.Essence)}`
end



return StatisticsDisplay
