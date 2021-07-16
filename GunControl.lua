
config = game:GetService("HttpService"):JSONDecode(script.Parent.OnBoard.CONFIG.Value)
pathconfig = game:GetService("HttpService"):JSONDecode(script.Parent.OnBoard.PATHCONFIG.Value)
gps = {}
for i,p in pairs(script.Parent.OnBoard.GPS:GetChildren()) do
	table.insert(gps,p.Name,p.Value)
end
function terminator()
	local npc = script.Parent
	while wait(config.shoot_delay) do
		--local success, response = pcall(function()
			for i,p in pairs(game.Players:GetChildren()) do
				shoot(npc,p)
			end
			for i,b in pairs(game.ServerScriptService.AI.Index:GetChildren()) do
				local char = workspace:FindFirstChild(b.Value)
				if(b.Value ~= script.Parent.Name) then
				if(char.Humanoid and char.Player.Value == true) then
				local c = {["Character"]=char}
				shoot(npc,c)
			end
			end
			end
		--end)
	end
end
function shoot(npc,p)
		
		if(p and p.Character) then
			if(p.Character.Head and p.Character.Humanoid) then
				if(script.Parent.OnBoard.Allow_Shoot.Value == true) then
					local direction =  (npc.Head.Position - p.Character.Head.Position).Unit * 1000

					local rData = RaycastParams.new()
					rData.FilterDescendantsInstances = {npc,workspace.GameCore}
					rData.FilterType = Enum.RaycastFilterType.Blacklist


					local Distance = (npc.Head.Position-p.Character.Head.Position).Magnitude
					local MinSpread, MaxSpread = -(config.spread) * Distance, (config.spread) * Distance
					local FinalAim = Vector3.new(
						(p.Character.Head.Position.X) + (math.random(MinSpread, MaxSpread)/100),
						(p.Character.Head.Position.Y) + (math.random(MinSpread, MaxSpread)/100),
						(p.Character.Head.Position.Z) + (math.random(MinSpread, MaxSpread)/100)
					)
					local FinalAim2 = Vector3.new(p.Character.Head.Position.X,p.Character.Head.Position.Y,p.Character.Head.Position.Z)
					local direction2 = (FinalAim2-npc.Head.Position).Unit * 1000
					local direction = (FinalAim-npc.Head.Position).Unit * 1000
					local finalPosition = direction
					local raycast = workspace:Raycast(npc.Head.Position,finalPosition,rData)
					local raycast2 = workspace:Raycast(npc.Head.Position,direction2,rData)
					local hitpart2,shooting

					if(raycast2) then
						if(raycast2.Instance.Parent and raycast2.Instance.Parent:FindFirstChild("Humanoid")) then
							shooting = true
						else
							shooting = false
						end
					end 
					if(shooting == true) then
						local hitPart,hitPosition,distance
						if raycast then
							hitPart = raycast.Instance
							hitPosition = raycast.Position
							script.Parent.Humanoid.WalkSpeed = 16
							--print(hitPart.Name)
							--fireBullet(npc.HumanoidRootPart.Position,hitPosition,hitPart,npc)
						else
							hitPosition = direction+npc.Head.Position
							script.Parent.Humanoid.WalkSpeed = config.run_speed
						end
						distance = (hitPosition-npc.HumanoidRootPart.Position).Magnitude
						fireBullet(npc.HumanoidRootPart.Position,hitPosition,hitPart,npc)
					end
				end 
			end
	end
end
function fireBullet(startpos,endpos,part,npc)
	local _playerService = require(game.ServerStorage.ServerModules.PlayerModule)
	local WeaponSystemRemotes = game.ReplicatedStorage.Remotes.Events.WeaponSystem
	local color = game.Teams:FindFirstChild(script.Parent.Team.Value).TeamColor.Color
	local data = {
		Color = color,
		StartPosition = startpos,
		EndPosition = endpos,
		Barrel = false,
		HitPart = part,
		Distance = (startpos-endpos).Magnitude
	}
	local hitPlayer = game.Players:GetPlayerFromCharacter(part.Parent)
	--local playerData = _playerService.GetPlayerData(hitPlayer)
	if(part.Parent and part.Parent:FindFirstChild("Humanoid")) then
	local humanoid = part.Parent.Humanoid
	if humanoid.Health <= 0 then return end
	if(hitPlayer ~= nil) then
	if hitPlayer.Character:GetAttribute("dead") then return end
	if hitPlayer.Character:FindFirstChildOfClass("ForceField") then return end
	 damage = config.shoot_damage
	if hitPlayer.Team.Name == config.Team then damage = -5  else damage = config.shoot_damage end
	else
	if(part.Parent:FindFirstChild("Player")) then
	if(part.Parent.Player.Value == true) then
		if part.Parent:FindFirstChildOfClass("ForceField") then return end
		if part.Parent.Team.Value == config.Team then damage = -5  else damage = config.shoot_damage end
	else
	return
	end
	end
	end
	local hs = false
		if(damage < 0 ) then 
		data.Color = Color3.new(0, 1, 0) 
		if(part.Parent.Humanoid.Health >= 50) then
		return
		end
		end
		WeaponSystemRemotes.Render:FireAllClients(data)
		if(part.Name == "Head") then
			hs = true
			humanoid:TakeDamage(damage*2)
		else
			hs = false
			humanoid:TakeDamage(damage)
		end
	local data2
	if humanoid.Health <= 0 then
			if(part.Parent:FindFirstChild("Player")) then
				data2 = {
					Killer = npc.Name,
					KColor = color,
					VColor = game.Teams:FindFirstChild(part.Parent.Team.Value).TeamColor.Color,
					Victim = part.Parent.Name,
					Weapon = "X9R",
					Headshot = hs
				}
			else
				hitPlayer.Character:SetAttribute("dead",true)
			data2 = {
				Killer = npc.Name,
				KColor = color,
				VColor = hitPlayer.Team.TeamColor.Color,
				Victim = hitPlayer.Name,
				Weapon = "X9R",
				Headshot = hs
			}
			end
		game.ReplicatedStorage.Remotes.Events.Feed:FireAllClients("NewFeed",data2)
	end
	end
end


function ti()
if(script.Parent.OnBoard.Allow_Shoot.Value == true) then
		terminator()
	end
end

function spot(opt)
	local npc = script.Parent
local rData = RaycastParams.new()
rData.FilterDescendantsInstances = {npc,workspace.GameCore}
rData.FilterType = Enum.RaycastFilterType.Blacklist

while wait() do
	for i,p in pairs(game.Players:GetChildren()) do
		if(p.Team.Name ~= config.Team) then
	local FinalAim2 = Vector3.new(p.Character.Head.Position.X,p.Character.Head.Position.Y,p.Character.Head.Position.Z)
	local direction2 = (FinalAim2-npc.Head.Position).Unit * 1000
	local raycast2 = workspace:Raycast(npc.Head.Position,direction2,rData)
	if(raycast2) then
	if(raycast2.Instance.Parent and raycast2.Instance.Parent:FindFirstChild("Humanoid")) then
	local sm =coroutine.create(shootmode)
	coroutine.resume(sm,p)
	return
	end
	end
end
end
end
end
function ft()
	local mag = 1000
	local pl = nil
	local char = nil
	while pl ==  nil do
	for i,p in pairs(game.Players:GetChildren()) do
		if(p.Character) then
			if(p.Character:FindFirstChild("Humanoid")) then
				if(p.Team.Name ~= config.Team) then
					if(p.Character.HumanoidRootPart.Position - script.Parent.HumanoidRootPart.Position).Magnitude < mag then
						mag = (p.Character.HumanoidRootPart.Position - script.Parent.HumanoidRootPart.Position).Magnitude
						pl = p
						char = p.Character
					end
				end
			end
		end
	end
end
	shootmode(pl)
end
function shootmode(player)
	takedown = false
	script.Parent.Paused.Value = true
	--print("HUNTING " .. player.Name)
	local AIModule,AIService = require(script.AI),require(script.AI).AIService
	local agent = AIService.new(script.Parent)
	agent:SetTarget({Target=game.Players[player.Name].Character.PrimaryPart})
	if(player.Character) then
		local h = player.Character:FindFirstChild("Humanoid")
	if(h~=nil) then
		h.Died:Connect(function()
			takedown = true
			local s =coroutine.create(ft)
		--	print("Killed target: " .. player.Name)
			wait(game.Players.RespawnTime+2)
			coroutine.resume(s)
			return
		end)
i = 0
			while takedown == false do
				wait(1)
				i = i+1
				if(i >= 5) then
					local s =coroutine.create(ft)
			--		print("Abandonned: " .. player.Name)
					coroutine.resume(s)
					return
				end
			end
	end
end
	
	
end

s = coroutine.create(spot)
tc = coroutine.create(ti)

wait(1)
coroutine.resume(tc)
coroutine.resume(s)
