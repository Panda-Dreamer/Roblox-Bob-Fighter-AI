local module = {}
pms = require(script.Parent.Pathfinding)
module.pathconfig  = {
	["offset"] = 8,
	["section_size"] = 8,
	["wps_raycast_offset"] = 2,
	["ray_size"] = 1,
	["ray_offset"] = 3,
	["timeout_magnitude"] = 4,
	["timeout_ticks"] = 25,
}



module.target = {
	[0] = Vector3.new(-72.021, 42.624, 125.03),
	[1] = Vector3.new(-72.021, 42.624, 125.03),
	[2] = Vector3.new(-458.323, 40.892, -262.881)
}

function module.takecare(bob,name,config,target,team,appearance)
--	print("AI")
	local died = false
	local bob2 = bob
	local died = false
	bob2.Humanoid.Died:Connect(function() 
		died = true
	end)
	local key = Instance.new("StringValue",game.ServerScriptService.AI.Index)
	key.Value = name
		local currentpoint = game.ReplicatedStorage.TermValues.Stage
		if(currentpoint == 0 or currentpoint == nil) then currentpoint = 1 end
		--if(currentpoint >2) then currentpoint = 2 end
		local coro = coroutine.create(function()
			local gps = pms.createpath(target,bob2,module.pathconfig)
		if(gps == false)then
			warn("Process stopped for ".. bob.Name .. " , reason: Path not found")
		end
			pms.walk(gps,bob2,target,module.pathconfig)

		end)
		coroutine.resume(coro)
		while died == false do
		wait()
	--	print("alive")
		end
	key:Destroy()
	bob2:Destroy()
		print("ded")
end
function module.create(config,name,team,appearance,spawnpos)
	local currentpoint = game.ReplicatedStorage.TermValues.Stage.Value
	if(tonumber(currentpoint) <= 0) then currentpoint = 1 end
	if(tonumber(currentpoint) >2) then currentpoint = 2 end
	config.Team = team
	local bob  = pms.spawn(spawnpos,name,config)
	if(appearance ~= nil) then
		bob.Humanoid:ApplyDescription(game.Players:GetHumanoidDescriptionFromUserId(appearance))
	end
	module.takecare(bob,name,config,module.target[currentpoint],team,appearance)
end

return module
