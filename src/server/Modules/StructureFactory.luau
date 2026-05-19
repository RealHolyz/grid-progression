local httpService = game:GetService("HttpService")

local StructureFactory = {}

function StructureFactory.CreateStructure(
	structureType, 
	tierLevel, 
	position, 
	rotation
)
	return {
		ID = httpService:GenerateGUID(false),
		Type = structureType,
		
		Position = {
			X = position.X,
			Y = position.Y,
			Z = position.Z
		},
		
		rotation = rotation,
		
		Data = {
			Tier = tierLevel,
		}
	}
end

return StructureFactory
