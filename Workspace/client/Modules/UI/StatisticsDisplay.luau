local StatisticsGroup = game:GetService("Players").LocalPlayer.PlayerGui.ScreenGui.StatisticsGroup
local group = StatisticsGroup.CanvasGroup

local TokensText = group.Tokens_Display
local ProfileTimeText = group.ProfileTime_Display

local StatisticsDisplay = {}

local suffixes = {
	{limit = 1e6,  suffix = "%.3f", divisor = 1},
	{limit = 1e9,  suffix = "%.3fM", divisor = 1e6},
	{limit = 1e12, suffix = "%.3fB", divisor = 1e9},
	{limit = 1e15, suffix = "%.3fT", divisor = 1e12},
	{limit = 1e18, suffix = "%.3fQ", divisor = 1e15},
	{limit = 1e21, suffix = "%.3fQi", divisor = 1e18},
	{limit = 1e24, suffix = "%.3fS", divisor = 1e21},
	{limit = 1e27, suffix = "%.3fSp", divisor = 1e24},
}

local function suffixFormat(number)
	for _, s in ipairs(suffixes) do
		if number < s.limit then
			return string.format(s.suffix, number / s.divisor)
		end
	end
	return string.format("%.0e", number)
end

local function timeFormat(seconds)
	
	local hrs = math.floor(seconds/3600)
	local mins = math.floor(seconds/60) % 60
	local secs = seconds % 60
	
	return string.format("%02d:%02d:%02d", hrs, mins, secs)
end

function StatisticsDisplay.displayStats(data)
	TokensText.Text = `Tokens: {suffixFormat(data.Data.Tokens)}`
	ProfileTimeText.Text = `Total Time: {timeFormat(data.Data.TotalTime)}`
end

return StatisticsDisplay
