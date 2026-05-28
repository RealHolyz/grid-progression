local PacketManager = {}

local Packet = require(game:GetService("ReplicatedStorage").Libraries.Packet)

PacketManager.Events = {
	Currencies = {
		Essence = {
			EssenceInit = "Events.Currencies.Essence.EssenceInit", --  Packet(name, param.)
			EssenceReset = "Events.Currencies.Essence.EssenceReset",
			EssenceUpgrade = "Events.Currencies.Essence.EssenceUpgrade"
		}
	},
	Data = {
		GetProfile = "Events.Data.GetProfile",
		GetData = "Events.Data.GetData",
		GetInitProfile = "Events.Data.GetInitProfile",
	},
	Gui = {
		SystemGuiUpdate = "Events.Gui.SystemGuiUpdate",
		UpdateStatistics = "Events.Gui.UpdateStatistics"
	},
	Structures = {
		Functionality = {
			ExecuteProperties = "Events.Structures.Functionality.ExecuteProperties"
		},
		Gui = {
			InventoryAddStructure = "Events.Structures.Gui.InventoryAddStructure"
		},
		Placement = {
			StructurePlace = "Events.Structures.Placement.StructurePlace",
			InitStructurePlace = "Events.Structures.Placement.InitStructurePlace"
		}
	}
}