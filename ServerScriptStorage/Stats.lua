local tweenServ = game:GetService("TweenService")

local function createStat(folder, name, value)
	local stat = Instance.new("IntValue")
	stat.Parent = folder
	stat.Name = name
	stat.Value = value
end

game.Players.PlayerAdded:Connect(function(plr)
	local folder = Instance.new("Folder", plr)
	folder.Name = "Stats"
	createStat(folder, "StamMax", 100)
	createStat(folder, "Stam", 100)
	createStat(folder, "StamDrain", 8)
	createStat(folder, "StamRegen", 2)
	createStat(folder, "HealthMax", 100)
	createStat(folder, "Health", 100)
	createStat(folder, "HealthRegen", 1)
	createStat(folder, "WalkSpeed", 16)
	createStat(folder, "RunSpeed", 24)
end)

--Stam
local function SetSpeed(plr, speed)
	local char = plr.Character
	if char then
		char:WaitForChild("Humanoid").WalkSpeed = speed
	end
end

local stamTimers = {}
local function sprintFunc(plr, value)
	local stamMax = plr.Stats.StamMax
	local stam = plr.Stats.Stam
	local stamDrain = plr.Stats.StamDrain
	local stamRegen = plr.Stats.StamRegen
	local walkSpeed = plr.Stats.WalkSpeed
	local runSpeed = plr.Stats.RunSpeed
	if value then
		SetSpeed(plr, runSpeed.Value)
		if stamTimers[plr.UserId] then stamTimers[plr.UserId]:Cancel() end
		stamTimers[plr.UserId] = tweenServ:Create(stam, TweenInfo.new(stam.Value/stamDrain.Value, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut), {Value = 0})
		stamTimers[plr.UserId]:Play()
	else
		SetSpeed(plr, walkSpeed.Value)
		if stamTimers[plr.UserId] then stamTimers[plr.UserId]:Cancel() end
		stamTimers[plr.UserId] = tweenServ:Create(stam, TweenInfo.new((stamMax.Value/stamRegen.Value)*(1-stam.Value/stamMax.Value), Enum.EasingStyle.Linear, Enum.EasingDirection.InOut), {Value = stamMax.Value})
		stamTimers[plr.UserId]:Play()
	end
end
game.ReplicatedStorage.Stats.Sprint.OnServerEvent:Connect(function(plr, value)
	sprintFunc(plr, value)
end)
