local Formatter = {}

local suffixes = {
	{limit = 1e6,  suffix = "%.3f", divisor = 1},
	{limit = 1e9,  suffix = "%.3fM", divisor = 1e6},
	{limit = 1e12, suffix = "%.3fB", divisor = 1e9},
	{limit = 1e15, suffix = "%.3fT", divisor = 1e12},
	{limit = 1e18, suffix = "%.3fQd", divisor = 1e15},
	{limit = 1e21, suffix = "%.3fQi", divisor = 1e18},
	{limit = 1e24, suffix = "%.3fS", divisor = 1e21},
	{limit = 1e27, suffix = "%.3fSp", divisor = 1e24},
}

function Formatter.format(number)
	for _, s in ipairs(suffixes) do
		if number < s.limit then
			return string.format(s.suffix, number / s.divisor)
		end
	end
	return string.format("%.0e", number)
end

return Formatter
