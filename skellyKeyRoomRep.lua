-- Services

local Players = game:GetService("Players")
local TS = game:GetService("TweenService")
local ReSt = game:GetService("ReplicatedStorage")

-- Variables

local Plr = Players.LocalPlayer
local Char = Plr.Character or Plr.CharacterAdded:Wait()
local Hum = Char:WaitForChild("Humanoid")
local Root = Char:WaitForChild("HumanoidRootPart")

local SelfModules = {
    Functions = loadstring(game:HttpGet("https://raw.githubusercontent.com/RegularVynixu/Utilities/main/Functions.lua"))(),
}

local Assets = {
    Door = LoadCustomInstance("https://github.com/RegularVynixu/Utilities/blob/main/Doors/Door%20Replication/Door.rbxm?raw=true"),
}

local DoorReplication = {}

-- Misc Functions

local function openDoor(doorTable)
    doorTable.Debug.OnDoorPreOpened()
    doorTable.Model:SetAttribute("Opened", true)

    if doorTable.Model:FindFirstChild("Lock") then
        -- Unlock visual

        doorTable.Model.Lock.UnlockPrompt.Enabled = false
        doorTable.Model.Lock.M_Thing.C0 = doorTable.Model.Lock.M_Thing.C0 * CFrame.Angles(0, math.rad(-45), 0)
        doorTable.Model.Hinge.Lock:Destroy()
        doorTable.Model.Lock.UnlockPrompt:Destroy()
    end

    -- Door opening visual

    if doorTable.Model:FindFirstChild("Light") then
        doorTable.Model.Light.Light.Color = Color3.fromRGB(197, 113, 88)
        doorTable.Model.Light.Light.Attachment.PointLight.Enabled = true
        doorTable.Model.Light.Light.Hit:Play()
    end
    
    doorTable.Model.Door.CanCollide = false
    doorTable.Model.Door.Open:Play()
    doorTable.Model.Hidden:Destroy()

    task.spawn(function()
        local knobC1 = doorTable.Model.Hinge.Knob.C1

        TS:Create(doorTable.Model.Hinge.Knob, TweenInfo.new(0.15, Enum.EasingStyle.Quad), {C1 = knobC1 * CFrame.Angles(0, 0, math.rad(-35))}):Play()
        task.wait(0.15)
        TS:Create(doorTable.Model.Hinge.Knob, TweenInfo.new(0.15, Enum.EasingStyle.Quad), {C1 = knobC1}):Play()
    end)

    TS:Create(doorTable.Model.Hinge, TweenInfo.new(doorTable.Config.FastOpen and 0.15 or 0.75, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {CFrame = doorTable.Model.Hinge.CFrame * CFrame.Angles(0, math.rad(-90), 0)}):Play()

    -- Next room preparations

    local nextRoom = workspace.CurrentRooms:FindFirstChild(tonumber(doorTable.Model.Parent.Name) + 1)

    if nextRoom then
        for _, v in next, {"Assets", "Light_Fixtures"} do
            if nextRoom:FindFirstChild(v) then
                for _, v2 in next, nextRoom[v]:GetDescendants() do
                    if string.find(v2.ClassName, "Light") and not v2.Enabled then
                        v2.Enabled = true
                    end
                end
            end
        end
    end

    doorTable.Debug.OnDoorOpened()
end

-- Functions

DoorReplication.CreateDoor = function(config)
    -- Configs setup

    for _, v in next, {"Key", "Lockpick"} do
        if not table.find(config.CustomKeyNames, v) then
            table.insert(config.CustomKeyNames, v)
        end
    end

    -- Model

    local model = Assets.Door:Clone()
    model.Door.MaterialVariant = "PlywoodALT"
    model.Sign.MaterialVariant = "Plywood"

    if not config.Barricaded then
        model.Boards:Destroy()
        
        if not config.Locked then
            model.Lock:Destroy()
        end

        if config.Sign == false then
            model.Sign:Destroy()
            model.Gui:Destroy()
        else
            task.spawn(function()
                repeat task.wait() until model.Parent and tonumber(model.Parent.Name)
                
                local signText = ""
                
                for i = #tostring(model.Parent.Name + 1), 3 do
                    signText = signText.. "0"
                end

                signText = signText.. model.Parent.Name + 1

                for _, v in next, model.Gui:GetDescendants() do
                    if v.ClassName == "TextLabel" then
                        v.Text = signText
                    end
                end
            end)
        end

        if config.Light == false then
            model.Light:Destroy()
        end
    else
        model.Lock:Destroy()
        model.Sign:Destroy()
        model.Gui:Destroy()
    end
    
    return {
        Model = model,
        Config = config,
        Debug = {
            OnDoorPreOpened = function() end,
            OnDoorOpened = function() end,
        },
    }
end

DoorReplication.ReplicateDoor = function(doorTable)
    -- Pre-check

    if not doorTable.Model.Parent then
        warn("Failure - Parent the door before replicating it")
        return
    
    elseif doorTable.Config.Barricaded then
        warn("Failure - Attempt to replicate a barricaded door")
        return
    end

    -- Guiding light

    if doorTable.Config.GuidingLight ~= false and doorTable.Model.Parent:GetAttribute("IsDark") then
        task.spawn(function()
            if not doorTable.Model.Door.LightAttach.HelpLight.Enabled then
                task.wait(15)
            end

            if doorTable.Model.Parent and not doorTable.Model:GetAttribute("Opened") then
                doorTable.Model.Door.LightAttach.HelpLight.Enabled = true
                doorTable.Model.Door.LightAttach.HelpParticle.Enabled = true

                TS:Create(doorTable.Model.Door.LightAttach.HelpLight, TweenInfo.new(2), {Brightness = 0.5}):Play()
            end
        end)
    end

    -- Connections

    local connections = {}

    if doorTable.Model:FindFirstChild("Lock") then
        connections.unlockBegan = doorTable.Model.Lock.UnlockPrompt.PromptButtonHoldBegan:Connect(function()
            for _, v in next, doorTable.Config.CustomKeyNames do
                local key = Char:FindFirstChild(v)

                if key and key:FindFirstChild("Animations") and key.Animations:FindFirstChild("use") then
                    Hum:LoadAnimation(key.Animations.use):Play()
                    return
                end
            end

            firesignal(ReSt.Bricks.Caption.OnClientEvent, "You need a key!", true)
        end)

        connections.unlockTriggered = doorTable.Model.Lock.UnlockPrompt.Triggered:Connect(function()
            for _, v in next, doorTable.Config.CustomKeyNames do
                local key = Char:FindFirstChild(v)

                if key then
                    for _, v in next, connections do
                        v:Disconnect()
                    end
                    if key:GetAttribute("uses") then key:SetAttribute("uses", key:GetAttribute("uses")-1) end
                    if not key:GetAttribute("uses") and doorTable.Config.DestroyKey ~= false or key:GetAttribute("uses")==0 then
                        key:Destroy()
                        if key:FindFirstChild("Handle"):FindFIrstChild("Curse") then key.Handle.Curse:Play() end
                    end

                    openDoor(doorTable)

                    break
                end
            end
        end)
    else
        task.spawn(function()
            while doorTable.Model.Parent and Root do
                if (Root.Position - doorTable.Model.PrimaryPart.Position).Magnitude <= 15 then
                    openDoor(doorTable)
    
                    break
                end
    
                task.wait()
            end
        end)
    end
end

-- Scripts

return DoorReplication