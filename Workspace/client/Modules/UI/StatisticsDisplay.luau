local StatisticsGroup = game:GetService("Players").LocalPlayer.PlayerGui.ScreenGui.StatisticsGroup
local group = StatisticsGroup.CanvasGroup

local TokensText = group.Tokens_Display

local StatisticsDisplay = {}

function StatisticsDisplay.displayStats(data)
	print(data.Data.Tokens)
	TokensText.Text = `Tokens: {math.floor(data.Data.Tokens * 100) / 100}`
	print(TokensText.Text)
end

return StatisticsDisplay
