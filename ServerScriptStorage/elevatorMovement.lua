  local module = {}

local elevator = workspace.Elevator
local tweenS = game:GetService("TweenService")
local main = elevator.movingParts.Main
local elevatorLength = 30 --this should never change unless theres a massive change in modeling
local modelStorage = game.ServerStorage:WaitForChild("Models")

local speed = 10 -- should be constant between loops, only changed at the start of elevator motion, otherwise it looks wonky

local Data = {} -- holds data for when certain loops

function module.setSpeed(newspeed)
	speed = newspeed
end

local function makeNewPart(center, length) -- ts makes the part for the tween to move to
	local newPos = Instance.new("Part")
	newPos.Size = Vector3.new(1,1,1)
	newPos.Transparency = 1
	newPos.CanCollide = false
	newPos.Anchored = true
	newPos.Parent = workspace
	newPos.Position = Vector3.new(center.Position.X, center.Position.Y+length, center.Position.Z)
	game:GetService("Debris"):AddItem(newPos, 60)
	return newPos
end

--make the continous tween
local function makeNewThing(model, style, length)
	local center = model.PrimaryPart
	if not length then length = model.length.Value end
	local newPos = makeNewPart(center,length)
	local tweenInfo

	if style == "start" then
		--need to fix the ending being too fast, causing the speed to jump a little on the continous
		tweenInfo = TweenInfo.new(length/speed*1.3, Enum.EasingStyle.Sine, Enum.EasingDirection.In)
	elseif style == "stop" then
		tweenInfo = TweenInfo.new(length/speed*1.3, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
	else
		-- da continous loop
		tweenInfo = TweenInfo.new(length/speed, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, -1)
	end

	local tween = game:GetService("TweenService"):Create(center, tweenInfo, {CFrame = newPos.CFrame})
	tween:Play()
	if style == "start" then wait(length/speed*1.3 - 0.05) end

	return tween
end

local function addSection(org, model, startlength ,count)
	-- to add sections above, lowk make startlength negative
	if not model then model = org end
	if not count then count = 1 end
	if not startlength then startlength = 0 end

	--holy YAP SESH, this makes the sections :O
	local model = model:Clone()
	model.Parent = org
	model.PrimaryPart:PivotTo(makeNewPart(org.PrimaryPart.CFrame, -startlength).CFrame)
	for i=1, count do
		for _,d in pairs(model:GetChildren()) do
			if d:IsA("BasePart") and d.Name ~= "Center" then
				local new = d:Clone()
				local weld = new:FindFirstChild("WeldConstraint")
				weld.Enabled = false
				weld.Part1 = org.PrimaryPart
				new.Position = Vector3.new(d.Position.X, d.Position.Y - (i * model.length.Value), d.Position.Z)
				new.Parent = org
				weld.Enabled = true
			end
		end
	end
	model:Destroy() -- trust this makes it easier and more organized
end

function module.moving(background)
	local newbackground = background:Clone()
	local newtrusses = modelStorage.backgrounds.Trusses:Clone() -- ts consistant so no need for entire ahh paramater
	newbackground.Parent = elevator.movingParts
	newtrusses.Parent = elevator.movingParts

	newtrusses.PrimaryPart:PivotTo(main.CFrame)
	newbackground:PivotTo(main.CFrame)
	addSection(newbackground)

	-- add chances for funny things like skeletons to be on the moving wall

	--make and save tween data fr fr
	Data["continous"] = {
		startTime = time(),
		bgTween = makeNewThing(newbackground),
		trussTween = makeNewThing(newtrusses), -- why do these jitter sometimes, ts pmo
		bgObj = newbackground,
		trussObj = newtrusses
	} -- logs when the loop starts
end

function module.descend(background, start)
	if Data["Start"] then start = Data["Start"] else start = start:Clone() end
	start.Parent = elevator.movingParts
	start:PivotTo(main.CFrame)
	addSection(start, background, start.startlength.Value)
	makeNewThing(start, "start", elevatorLength + start.startlength.Value)
	start:Destroy()
	if Data["Start"] then Data["Start"] = nil end

	module.moving(background)
end

function module.stop(background, start)
	local start = start:Clone()-- obv not gonna be this but its temp so who cares
	start.Parent = elevator.movingParts
	start:PivotTo(makeNewPart(main, -(start.stoplength.Value + background.length.Value*2)).CFrame)
	addSection(start, background, -(elevatorLength  + start.stoplength.Value + background.length.Value*2), 2)
	makeNewThing(start,"stop", start.stoplength.Value + background.length.Value*2)

	wait(.07)
	local data = Data["continous"]
	-- use the start time to make this loop nicely, but me too lazy rn
	if data then
		data.bgTween:Cancel()
		data.trussTween:Cancel()
		data.bgObj:Destroy()
		data.trussObj:Destroy()			
	end

	Data["Start"] = start
end

return module
