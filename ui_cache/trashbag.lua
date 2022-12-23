return function(_,CanEntityKill,_,_,Creator)
	local L_1_ = Creator.createEntity({
		CustomName = "Trashbag", -- Custom name of your entity
		Model = "rbxassetid://11623808411", -- Can be GitHub file or rbxassetid
		Speed = 200, -- Percentage, 100 = default Rush speed
		DelayTime = 0, -- Time before starting cycles (seconds)
		HeightOffset = 0,
		CanKill = CanEntityKill,
		KillRange = 100,
		BreakLights = true,
		BackwardsMovement = false,
		FlickerLights = {
			true, -- Enabled/Disabled
			2.5, -- Time (seconds)
		},
		Cycles = {
			Min = 1,
			Max = 5,
			WaitTime = 0.05,
		},
		CamShake = {
			false, -- Enabled/Disabled
			{
				3.5,
				20,
				0.1,
				1
			}, -- Shake values (don't change if you don't know)
			100, -- Shake start distance (from Entity to you)
		},
		Jumpscare = {
			false, -- Enabled/Disabled
			{
				Image1 = "rbxassetid://10154713810", -- Image1 url
				Image2 = "rbxassetid://10154713810", -- Image2 url
				Shake = false,
				Sound1 = {
					8389041427, -- SoundId
					{
						Volume = 0
					}, -- Sound properties
				},
				Sound2 = {
					8389041427, -- SoundId
					{
						Volume = 0
					}, -- Sound properties
				},
				Flashing = {
					false, -- Enabled/Disabled
					Color3.fromRGB(255, 255, 255), -- Color
				},
				Tease = {
					true, -- Enabled/Disabled
					Min = 1,
					Max = 4,
				},
			},
		},
		CustomDialog = {
			"nice try fatty",
			"Now lemme gobble dem balls"
		}, -- Custom death message
	})
	
	-- Run the created entity
	task.spawn(function() Creator.runEntity(L_1_) end)
	return L_1_.Model
end