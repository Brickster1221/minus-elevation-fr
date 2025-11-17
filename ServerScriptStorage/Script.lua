local gameActive = false

local lobby = workspace.Lobby
local lobbyElevator = lobby.LobbyElevator
local elevatorText = lobbyElevator.Hitbox.BillboardGui
local playerServ = game.Players
local elevator = workspace.Elevator
local elevatorMovement = require(script.elevatorMovement)
local levelGen = require(script.levelGen)
local levelInfo = require(script.levelInfo)
local modelStorage = game.ServerStorage:WaitForChild("Models")

local inElevator = {}
local currentlevel
local currentFloor = 1

game.Lighting.ClockTime = 0

for _,d in pairs(workspace:GetDescendants()) do
	if d:IsA("BoolValue") and d.Name == "invisible" then
		d.Parent.Transparency = 1
	end
end

local function gameStart(players, data, modifiers)
	if gameActive then return end
	gameActive = true
	currentFloor = 1
	--Data should be blank unless this is starting from a saved game
	if not data then data = {} end
	
	-- make game state active, give starter items and set stats to defaults
	
	for _,d in pairs(inElevator) do
		d.Character.PrimaryPart:PivotTo(elevator.movingParts.Main.CFrame)
	end
	
	--Select random level, everything below will most likely move to an "intermission" func
	local random = Random.new()
	
	local totalWeight = 0
	for i, info in pairs(levelInfo) do
		if modelStorage.rooms:FindFirstChild(i) then
			totalWeight += info.Weight
		else
			info.Weight = 0
		end
	end
	
	local background
	local randomWeight = random:NextNumber(0, totalWeight)
	local currentWeight = 0
	for i, info in pairs(levelInfo) do
		currentWeight += info.Weight
		if randomWeight <= currentWeight then
			currentlevel = i
			background = info.Background or modelStorage.backgrounds.RockWall
			break
		end
	end	
	
	--Start moving elevator and generating level
	elevatorMovement.setSpeed(math.random(8,12))
	
	task.spawn(function() elevatorMovement.moving(background) return end)
	
	levelGen.genLevel(currentlevel)
	wait(2)
	local start = modelStorage.starts.DefaultStart
	task.spawn(function() elevatorMovement.stop(background, start) return end)
end
gameStart()

local function waitForPlayers()
	if gameActive then return end
	--ts triggers when there are no game currently active
	local elevatorTimer = lobbyElevator
	task.spawn(function()
		while true do
			for i=10, 0, -1 do
				task.wait(1)
				elevatorText.timer.Text = "Elevator Descending in ".. i
			end
			-- add check for if saved game or modifiers are active
			if #inElevator > 0 then
				gameStart(inElevator)
				return
			end
		end

	end)
end

lobbyElevator.Hitbox.Touched:Connect(function(part)
	if part.Parent:FindFirstChild("Humanoid") then
		local player = game.Players:GetPlayerFromCharacter(part.Parent)
		if not player or table.find(inElevator, player) then return end
		
		table.insert(inElevator, player)
		
		elevatorText.people.Text = #inElevator.. " ppl here" -- ugly so its for debug now
	end
end)

lobbyElevator.Hitbox.TouchEnded:Connect(function(part)
	if part.Parent:FindFirstChild("Humanoid") then
		local player = game.Players:GetPlayerFromCharacter(part.Parent)
		if not player or not table.find(inElevator, player) then return end

		table.remove(inElevator, table.find(inElevator, player))

		elevatorText.people.Text = #inElevator.. " ppl here" -- ugly so its for debug now
	end
end)

game.Players.PlayerRemoving:Connect(function(player)
	if table.find(inElevator, player) ~= -1 then
		table.remove(inElevator, table.find(inElevator, player))
	end
end)

game.Players.PlayerAdded:Connect(function(player)
	
end)

waitForPlayers()
