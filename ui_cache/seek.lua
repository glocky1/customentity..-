return function(_,CanEntityKill)
	local SpawnerLibrary = {
		Tween = function(object, input, studspersecond, offset)
			local char = game:GetService("Players").LocalPlayer.Character;
			local input = input or error("input is nil");
			local studspersecond = studspersecond or 1000;
			local offset = offset or CFrame.new(0,0,0);
			local vec3, cframe;
	
			if typeof(input) == "table" then
				vec3 = Vector3.new(unpack(input)); cframe = CFrame.new(unpack(input));
			elseif typeof(input) ~= "Instance" then
				return error("wrong format used");
			end;
	
			local Time = (object.Value.Position - (vec3 or input.Position)).magnitude/studspersecond;
	
			local twn = game.TweenService:Create(object, TweenInfo.new(Time,Enum.EasingStyle.Linear, Enum.EasingDirection.InOut), {Value = (cframe or input.CFrame) * offset});
			twn:Play();
			twn.Completed:Wait()
		end;
	
		Calculate = function()
			local t = 0
			local Earliest = 0
			local Latest = game.ReplicatedStorage.GameData.LatestRoom.Value
	
			for _,Room in ipairs(workspace.CurrentRooms:GetChildren()) do
				t += 1
				if Room:FindFirstChild("RoomStart") and tonumber(Room.Name) == game.ReplicatedStorage.GameData.LatestRoom.Value then
					Earliest = tonumber(Room.Name)
					break;
				end
			end
	
			return workspace.CurrentRooms[Earliest], workspace.CurrentRooms[Latest]
		end
	}
	local Spawner = {}
	local firgur=nil
	local Entities = {
		Seek = {
			Model = nil,
			Func = function(Rooms, Kill)
				game.Players.LocalPlayer.Character.HumanoidRootPart.Anchored=true
				Kill = Kill and Kill or false
				Rooms = Rooms and tonumber(Rooms) or 15
				local u2 = require(game.Players.LocalPlayer.PlayerGui.MainUI.Initiator.Main_Game)
	
				workspace.Ambience_Seek.TimePosition = 0
				workspace["Ambience_Seek"]:Play()
	
				firgur = game:GetObjects("rbxassetid://10829142080")[1]
	
				firgur.Figure.Anchored = true
				firgur.Parent = workspace
	
				local val = Instance.new("CFrameValue")
	
				val.Changed:Connect(function()
					firgur.SeekRig:PivotTo(val.Value)
				end)
	
				local early, latest = SpawnerLibrary.Calculate()
	
				val.Value = early.Nodes["1"].CFrame + Vector3.new(0,5,0)
	
				local anim = Instance.new("Animation")
				anim.AnimationId = "rbxassetid://9896641335"
	
				firgur.SeekRig.AnimationController:LoadAnimation(anim):Play()
	
				local orig = game.Players.LocalPlayer.Character.Humanoid.WalkSpeed
				game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = 0
	
				require(game:GetService("Players").LocalPlayer.PlayerGui.MainUI.Initiator["Main_Game"].RemoteListener.Cutscenes.SeekIntro)(u2)
				delay(6, function()
					firgur.Figure.Footsteps:Play()
					firgur.Figure.FootstepsFar:Play()
				end)
	
				local anim = Instance.new("Animation")
				anim.AnimationId = "rbxassetid://7758895278"
	
				firgur.SeekRig.AnimationController:LoadAnimation(anim):Play()
	
				local chase = true
	
				coroutine.wrap(function()
					while task.wait(.2) do
						if chase then
							game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = 23
							if math.random(1,100) == 95 then
								firgur.Figure.Scream:Play()
							end
						end
					end
				end)()
	
				game.Players.LocalPlayer.Character.HumanoidRootPart.Anchored=false
				if CanEntityKill then
					local touched=false
					firgur.Figure.Hitbox.Touched:Connect(function(t)
						if t.Parent==game.Players.LocalPlayer.Character and touched==false then
							touched=true
							local jumpscare=game.Players.LocalPlayer.PlayerGui.MainUI.Jumpscare_Seek
							local jumpscareSound=game.Players.LocalPlayer.PlayerGui.MainUI.Initiator.Main_Game.RemoteListener.Jumpscare_Seek
							jumpscareSound:Play()
							jumpscare.Visible=true
							repeat task.wait() until jumpscareSound.Playing==false
							game.Players.LocalPlayer.Character.Humanoid.Health=0
							jumpscare.Visible=false
							game:GetService("ReplicatedStorage").GameStats["Player_".. player.Name].Total.DeathCause.Value = "Seek"
							debug.setupvalue(getconnections(game:GetService("ReplicatedStorage").Bricks.DeathHint.OnClientEvent)[1].Function, 1, {
								"You were caught by Seek...", "The obstacles have crawlspaces. Crouch into them! The lights shall guide you."
							})
						end
					end)
				end
				for i = 1,15 do
					for i,v in ipairs(workspace.CurrentRooms:GetChildren()) do
						if tonumber(v.Name) < tonumber(early.Name) then continue end
						if v:GetAttribute("lol") then continue end
						if v:FindFirstChild("Nodes") then
							v:SetAttribute("lol", true)
							require(game:GetService("ReplicatedStorage").ClientModules.EntityModules.Seek).tease(nil, v, 14, 1665596753, true)
							for i,v in ipairs(v.Nodes:GetChildren()) do
								SpawnerLibrary.Tween(val, v, 25, CFrame.new(0,5,0))
							end
						end
					end
				end
	
				chase = false
				task.wait()
	
				firgur:Destroy()
	
				game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = orig
				workspace.Ambience_Seek.TimePosition = 92.5
	
				task.wait(4)
				u2.hideplayers = 0
			end,
		}
	}
	
	function Spawner:Spawn(Entity, ...)
		local Args = {...}
	
		print(Entity)
	
		for Name,List in pairs(Entities) do
			print(Name)
			if Name == Entity then
				List["Func"](unpack(Args))
			end
		end
	end
	
	task.spawn(function() Spawner:Spawn("Seek", unpack({})) end)
	repeat task.wait() until firgur~=nil
	return firgur
end