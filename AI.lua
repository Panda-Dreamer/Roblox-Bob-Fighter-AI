local PathFindingService = game:GetService("PathfindingService")
local TweenService = game:GetService("TweenService")

local ActiveAI = {}

local module = {}

----------------------- AI SERVICE
module.AIService = {}
local AI = module.AIService
AI.__index = module.AIService
function AI.new(character,ExtraData)
	local ExtraData = ExtraData or {}
	local self = setmetatable({},AI)
	
	
	character.PrimaryPart:SetNetworkOwner(nil)
	self.Char = character
	self.Target = nil
	self.Disabled = false
	self.ViewRange = ExtraData.ViewRange or 2000
	self.Wander = ExtraData.Wander or false
	self.DebugMode = ExtraData.DebugMode or false
	
	
	self.Key = ExtraData.CustomKey or character
	self.Connections = {main={},misc={}}
	ActiveAI[self.Key] = self
	
	return self
end
function AI:SetTarget(Data)
	if Data == false then
		self.Target = nil
		return true
	end
	if not Data then
		return false,"Data is nil"
	end
	local target = Data.Target
	local pathfind = Data.Pathfind or false
	local persist = Data.Persist or true
	
	if not target or not target:IsA("BasePart") then
		return false,"No target or target not Class:BasePart (use $Data.Target to set a target) TYPE:TARGET="..tostring(target)
	end
	local Character = self.Char
	local Humanoid = Character:WaitForChild("Humanoid",3)
	if not Humanoid then
		return false,"Failed to find humanoid"
	end
	
	-- functions
	local function makeDebugPart(params)
		local newPart = Instance.new("Part",workspace.Debug)
		for par,val in pairs(params) do
			newPart[par] = val
		end
		return newPart
	end
	
	local function checkView()
		return false
	end
	local function getDist()
		return (target.Position-Character.HumanoidRootPart.Position).Magnitude
	end
	local function makePath()
	
		local newPath = PathFindingService:CreatePath({
			["AgentRadius"] = 2,
			["AgentHeight"] = 5,
			["AgentCanJump"] = true
		})
		newPath:ComputeAsync(Character.HumanoidRootPart.Position,target.Position)
		local waypoints = newPath:GetWaypoints()
		
		if self.DebugMode then
			for _,Point in pairs(waypoints) do
				local t = {
					["Size"] = Vector3.new(1,1,1),
					["Anchored"] = true,
					["CanCollide"] = false,
					["Material"] = Enum.Material.Neon,
					["Position"] = Point.Position,
				}
				local newPart = makeDebugPart(t)
				delay(3,function()
					newPart:Destroy()
				end)
			end
		end
		
		if newPath.Status == Enum.PathStatus.Success then
			--print("made path")
			for _,Point in pairs(waypoints) do
				if self.Target == nil then
					break
				end
				if Point.Action == Enum.PathWaypointAction.Jump then
					Humanoid.Jump = true
				end
				Humanoid:MoveTo(Point.Position)
				local timeout = Humanoid.MoveToFinished:Wait()
				if not timeout then
					Humanoid.Jump = true
					makePath()
					break
				end
				if checkView() then
				
					repeat
						Humanoid:MoveTo(target.Position)
						--print(self.Target,self.Disabled,getDist())
						if self.Target and not self.Disabled and getDist() <= 5 then
							--print("hit")
						end
						wait(0.1)
						if not self.Target then
							break
						end
					until not checkView()
					--print("lost view")
					if persist and self.Target and not self.Disabled then
						makePath()
					end
					break
				end
				if (target.Position-waypoints[#waypoints].Position).Magnitude > 20 then
					makePath()
					break
				end
			end
		else
			--print("failed to make path")
			makePath()
		end
	end
	
	-- core
	coroutine.wrap(function()
		self.Target = target
		makePath()
	end)()
	return true
end
function AI:Destroy()
	for _,Table in pairs(self.Connections) do
		for _,Connection in pairs(Table) do
			Connection:Disconnect()
		end
	end
	
	table.remove(ActiveAI,table.find(ActiveAI,self.Key))
	self.Char:Destroy()
	return true
end

--------------------- AI MODULE
function module.GetAI(Key)
	if not Key then
		return false,"Key is nil"
	end
	if ActiveAI[Key] then
		return ActiveAI[Key]
	else
		return false,"No results for Key: "..Key
	end
end

return module
