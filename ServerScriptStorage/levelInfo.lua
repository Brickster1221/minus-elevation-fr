local modelStorage = game.ServerStorage:WaitForChild("Models")
local module = {
	["TestingZone"] = {
		["Weight"] = 0,
		["Start"] = modelStorage.starts.TestingZoneStart,
		["Type"] = "single",
		["rooms"] = {
			["main"] = 1
		}
	},
	["Kit"] = {
		["Weight"] = 1,
		["Type"] = "mult",
		["defaultAmount"] = 15,
		["Background"] = modelStorage.backgrounds.Kit,
		["rooms"] = {
			["3Way1"] = 0,
			["3Way2"] = 0,
			["Corner1"] = 0,
			["Corner2"] = 0,
			["Crossroads1"] = 0,
			["Crossroads2"] = 0,
			["EndWall"] = 0,
			["Hallway1"] = 1,
			["Hallway2"] = 1,
			["Hallway3"] = 1,
		}
	}
}

return module
