local module = {}
local levelInfo = require(script.Parent.levelInfo)
local random = Random.new()
local modelStorage = game.ServerStorage:WaitForChild("Models")
local level = nil
local info
local genRoomFolder = workspace.GeneratedRooms

local function GetConnectors()
	local start = info.Start or modelStorage.starts.DefaultStart
	local model = Instance.new("Model")
	model.Parent = genRoomFolder
	for _,d in pairs(start:GetChildren()) do
		if d.Name == "Connector" or d.Name == "Center" then
			local new = d:Clone()
			new.Parent = model
			if new.Name == "Center" then
				model.PrimaryPart = new
			end
		end
	end
	model:PivotTo(workspace.Elevator.movingParts.Main.CFrame)
end

local function GetRandom()
	local totalWeight = 0
	for n, weight in pairs(info.rooms) do
		totalWeight += weight
	end

	local randomWeight = random:NextNumber(0, totalWeight)
	local currentWeight = 0
	local randomRoom = nil
	for n, weight in pairs(info.rooms) do
		currentWeight += weight
		if randomWeight <= currentWeight then
			randomRoom = modelStorage.rooms[level]:FindFirstChild(n)
			break
		end
	end
	return randomRoom
end

function module.unloadLevel()
	script.Parent.mapGenerated.Value = false
	level = nil
	info = nil
	--unload the map
	genRoomFolder:ClearAllChildren()
end

function module.genLevel(l)
	module.unloadLevel()
	level = l
	info = levelInfo[level]
	if info.Type == "single" then
		local room = GetRandom(level):Clone()
		room.Parent = genRoomFolder
		room:PivotTo(workspace.Elevator.movingParts.Main.CFrame)
	elseif info.Type == "mult" then
		GetConnectors() -- make base connectors
		for i=1, info.defaultAmount do
			local room = GetRandom(level):Clone()
			
			local connections = {}
			for _,d in pairs(room:GetChildren()) do
				if d.Name == "Connector" then
					table.insert(connections, d)
				end
			end
			
			local AllConnections = {}
			for _,d in pairs(genRoomFolder:GetDescendants()) do
				if d.Name == "Connector" then
					table.insert(AllConnections, d)
				end
			end
			if AllConnections == 0 then
				print("No connections found")
				return
			end
			
			local prevConnector = AllConnections[math.random(1,#AllConnections)]
			local Connector = connections[math.random(1,#connections)]
			Connector.Orientation += Vector3.new(0,180,0)
			
			room.PrimaryPart = Connector
			room:PivotTo(prevConnector.CFrame)
			room.Parent = genRoomFolder
			Connector:Destroy()
			prevConnector:Destroy()
			
			
		end
		script.Parent.mapGenerated.Value = true
		
	end
	
	
end





return module
