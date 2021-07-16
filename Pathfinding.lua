local module = {}
PathService = game:GetService("PathfindingService")
module.gps = {}
module.nodes = {}
module.original = {}
module.config = {}
module.Debug = true


function module.spawn(pos,name,config)
	local clone = game.ServerScriptService.AI.NPC:Clone()
	clone.Name = name
	clone.Parent = workspace
	clone.HumanoidRootPart.CFrame = CFrame.new(pos)
	module.config = config
	clone.OnBoard.Allow_Shoot.Value = config.allow_shoot
	clone.Player.Value = true
	clone.Team.Value = config.Team
--	print("AI2")
	clone.OnBoard.CONFIG.Value = game:GetService("HttpService"):JSONEncode(config)
--	print("AI2")
	for i,p in pairs(clone:GetChildren()) do 
	--	print("AI3")
		if(p:IsA("BasePart")) then
		p:SetNetworkOwner(nil)
		end
	end
	--print("AI2")
	if(workspace:FindFirstChild("Waypoints3") == nil ) then
		local folder = Instance.new("Folder",workspace)
		folder.Name ="Waypoints3"
	end
	game.Workspace.Waypoints3:ClearAllChildren()
	return clone
end
function module.createparts(list,color,force)
	if(module.Debug == false) then return end
	for index, waypoint in pairs(list) do
		local point = Instance.new("Part")
		point.Position = waypoint.Position
		point.Anchored = true
		point.CanCollide = false
		point.Transparency = 0.5

		point.Material = Enum.Material.Neon
		if(index == 1) then
			point.Size = Vector3.new(2,2,2)
		else
			point.Size = Vector3.new(0.5,0.5,0.5)
		end
		point.Parent = workspace.Waypoints3
		point.Color = color
		point.Name = "WayPoint"
	end
end
function module.gennodes(target,npc,pathconfig)
	npc.OnBoard.PATHCONFIG.Value = game:GetService("HttpService"):JSONEncode(pathconfig)
	npc.OnBoard.Target.Value = target
	local original = {}
	local path = PathService:CreatePath({
		["AgentRadius"] = 2,
		["AgentHeight"] = 5,
		["AgentCanJump"] = true
	})
	local h = npc.Humanoid
	local hr = npc.HumanoidRootPart
	local offset = pathconfig.offset
	local sectionsize = pathconfig.section_size
	local nodes = {}
	print("GenNodes: ", hr.Position.X..","..hr.Position.Z , " , " , target.X..","..target.Z)
	path:ComputeAsync(hr.Position,target)
	if path.Status == Enum.PathStatus.NoPath then warn("No path found for " .. npc.Name .. " try spawning the npc at a diffrent position by adding using the force spawn argument as true.")  wait(2) npc:Destroy() return false,false end
	local waypoints = path:GetWaypoints()
	module.createparts(waypoints,Color3.new(0, 0, 0.498039))
	original = waypoints
	for i, waypoint in pairs(waypoints) do
		if(math.floor(i/ sectionsize) == i/ sectionsize) then
			nodes[i/ sectionsize] = {}
			if(i ==  sectionsize) then
				path:ComputeAsync(hr.Position,waypoint.Position)
			else
				path:ComputeAsync(waypoints[i- sectionsize].Position,waypoint.Position)
			end
			nodes[i/ sectionsize][1] = path:GetWaypoints()
			module.createparts(nodes[i/ sectionsize][1],Color3.new(0, 0, 0))

			if(i ==  sectionsize) then
				path:ComputeAsync(hr.Position,waypoint.Position)
			else
				path:ComputeAsync(waypoints[i- sectionsize].Position-Vector3.new(offset,0,offset),waypoint.Position)
			end
			nodes[i/ sectionsize][2] = path:GetWaypoints()
			module.createparts(nodes[i/ sectionsize][2],Color3.new(0, 1, 1))

			if(i ==  sectionsize) then
				path:ComputeAsync(hr.Position,waypoint.Position)
			else
				path:ComputeAsync(waypoints[i- sectionsize].Position+Vector3.new(offset,0,offset),waypoint.Position)
			end
			nodes[i/ sectionsize][3] = path:GetWaypoints()
			module.createparts(nodes[i/ sectionsize][3],Color3.new(0, 1, 0))
		end
	end
	if(#nodes>1 and #module.original~=#nodes* sectionsize and true==false) then
		path:ComputeAsync(nodes[#nodes][1][#nodes[nodes][1]].Position,target)
		local ws = path:GetWaypoints()
		local index = #nodes+1
		nodes[index]	={1,2,3}
		nodes[index][1] = ws
		nodes[index][2] = ws
		nodes[index][3] = ws
	end
	return nodes,original
end

function module.gengps(target,npc,pathconfig,nodes)
	local gps = {}
	for i,s in pairs(nodes) do
		gps[i] = module.selectsection(i,npc,pathconfig,nodes)
	end
	local temp = {}
	for wpn,gpswaypoint in pairs(gps)do
		for wpn2,point in pairs(gpswaypoint) do
		table.insert(temp,point)
	end
	end
	gps = temp
	for i,p in pairs(gps) do
		local pi = Instance.new("Vector3Value",npc.OnBoard.GPS)
		pi.Value = p.Position
		pi.Name = i
	end
	return gps
end
function module.selectsection(sn,npc,pathconfig,nodes)
	local h = npc.Humanoid
	local hr = npc.HumanoidRootPart
	local roffset = pathconfig.wps_raycast_offset
	

	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Blacklist
	params.FilterDescendantsInstances = {hr.Parent,workspace.Waypoints3}
	
	local winner = 1
	local c1 = 0
	local c2 = 0
	local c3 = 0
	local ray = ""
	for a,way in pairs(nodes[sn][1]) do
		if(a == 1) then
			ray = workspace:Raycast(hr.Position, way.Position, params)
		else
			ray = workspace:Raycast(nodes[sn][1][a-1].Position+Vector3.new(0,roffset,0), way.Position+Vector3.new(0,roffset,0), params)
		end

		if ray and ray.Instance then
			c1 = c1+1
		end
	end

	for a,way in pairs(nodes[sn][2]) do
		if(a == 1) then
			ray = workspace:Raycast(hr.Position, way.Position, params)
		else
			ray = workspace:Raycast(nodes[sn][2][a-1].Position+Vector3.new(0,roffset,0), way.Position+Vector3.new(0,roffset,0), params)
		end

		if ray and ray.Instance then
			c2 = c2+1
		end
	end


	for a,way in pairs(nodes[sn][3]) do
		if(a == 1) then
			ray = workspace:Raycast(hr.Position, way.Position, params)
		else
			ray = workspace:Raycast(nodes[sn][3][a-1].Position +Vector3.new(0,roffset,0), way.Position+Vector3.new(0,roffset,0), params)
		end

		if ray and ray.Instance then
			c3 = c3+1
		end
	end
	local min = math.min(c1,c2,c3)
	if(c1 == min) then
		winner = 1
	elseif(c2 == min) then
		winner = 2
	else
		winner = 3
	end
	return	nodes[sn][winner]
end
function module.followgps(gps,npc,target,pathconfig)
	local raysize = pathconfig.ray_size
	local rayoffset = pathconfig.ray_offset
	local tomagn = pathconfig.timeout_magnitude
	local totime = pathconfig.timeout_ticks
	
	local h = npc.Humanoid
	local hr = npc.HumanoidRootPart
	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Blacklist
	params.FilterDescendantsInstances = {hr.Parent,workspace.Waypoints3}
	local cwps  = npc.CWP.Value
	for cwps,point in pairs(gps) do
		wait()
		if(npc:FindFirstChild("Paused")) then
		if(npc.Paused.Value ==true) then
		return
		end
			if(point.Action == "Jump") then
				h.Jump = true
			end
			local ray = workspace:Raycast(hr.Position-Vector3.new(0,1,0), point.Position, params)
			local ray2= workspace:Raycast(hr.Position+Vector3.new(raysize,rayoffset,0), hr.Position-Vector3.new(raysize,rayoffset,0), params)
			if ray2 and ray2.Instance then
				--print(ray2.Instance)
				h.Jump = true
			end
			local ray2= workspace:Raycast(hr.Position+Vector3.new(0,rayoffset,raysize), hr.Position-Vector3.new(0,rayoffset,raysize), params)
			if ray2 and ray2.Instance then
				--print(ray2.Instance)
				h.Jump = true
			end
			local ray2= workspace:Raycast(hr.Position+Vector3.new(-1*raysize,rayoffset,0), hr.Position-Vector3.new(-1*raysize,rayoffset,0), params)
			if ray2 and ray2.Instance then
				--print(ray2.Instance)
				h.Jump = true
			end
			local ray2= workspace:Raycast(hr.Position+Vector3.new(0,rayoffset,-1*raysize), hr.Position-Vector3.new(0,rayoffset,-1*raysize), params)
			if ray2 and ray2.Instance then
				--print(ray2.Instance)
				h.Jump = true
			end
			if ray and ray.Instance then
				h.Jump = true
			end
			if(npc:FindFirstChild("Humanoid")) then
			h:MoveTo(point.Position)
			end
			if(npc:FindFirstChild("Humanoid")) then
			if(npc.Humanoid.Health <= 0)then
				return
			end
			else
			return
			end
			local next = false
			local to = 1
			while (npc.HumanoidRootPart.Position-point.Position).magnitude > tomagn do
				wait()
				to = to+1
				if(to == totime) then 
					h.Jump = true
					next = true
					--print("Next to")
					break 
			end
			
			if(next == true or (npc.HumanoidRootPart.Position-point.Position).magnitude > tomagn) then
			npc.CWP.Value = npc.CWP.Value +1
			end
			end
	
		end
	end
end
function module.reset()
	module.gps = {}
	module.nodes = {}
	module.original = {}
	module.config = {}

end
function module.stayaround(npc)
	local sizeX, sizeZ = 5, 5
	local randomDisplacement = Vector3.new(math.random(-sizeX, sizeX), 0, math.random(-sizeZ, sizeZ))
	if(npc:FindFirstChild("Humanoid")) then
	npc.Humanoid:MoveTo(npc.HumanoidRootPart.CFrame:vectorToWorldSpace(randomDisplacement) + npc.HumanoidRootPart.Position)
	end
	if(npc:FindFirstChild("Humanoid")) then
		if(npc.Humanoid.Health <= 0)then
			return
		end
	else
		return
	end
end
function module.giveForcefield(character)
	if character then
		local forceField = Instance.new("ForceField")
		forceField.Visible = true
		forceField.Parent = character
		return forceField
	end
end
function module.createpath(target,npc,pathconfig)
module.reset()
local ff = module.giveForcefield(npc)
local nodes,original =	module.gennodes(target,npc,pathconfig)
if(nodes == false )then return false end
local gps =	module.gengps(target,npc,pathconfig,nodes)
ff:Destroy()
	return gps
end
function module.walk(gps,npc,target,pathconfig)
	npc.GunControl.Disabled = false
	module.followgps(gps,npc,target,pathconfig)
	module.stayaround(npc)
end
return module
