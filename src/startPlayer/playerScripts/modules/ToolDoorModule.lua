---- services ----
local TS = game:GetService("TweenService")
local UIS = game:GetService("UserInputService")
local IsPhone = UIS.TouchEnabled

---- modules ----
local CreateModule = require(game.ReplicatedStorage.modules.CreateModule)
local PlayerModule = require(game.Players.LocalPlayer.PlayerScripts.modules.PlayerClientModule)

---- variables ----
local localPlayer = game.Players.LocalPlayer
local oldIcon = "rbxassetid://13634776411"
local xboxCon

---- events -----
local BindableEvents = game.ReplicatedStorage.BindableEvents

---- main ----

local ToolDoorModule  ={}

function ToolDoorModule.Set(toolDoor)
    toolDoor.ClickDetector.MaxActivationDistance = 0
    if IsPhone and toolDoor:FindFirstChild("BillboardGui") then
        toolDoor.BillboardGui.Enabled = false
    end
    local music:Sound = localPlayer.Character.HumanoidRootPart:FindFirstChild(toolDoor.Name)
    if music then
        music:Play()
	end

    if toolDoor.Name == "xbox" then
        toolDoor.ClickDetector.MaxActivationDistance = 32
        toolDoor.ClickDetector.CursorIcon = ""
		xboxCon = toolDoor.ClickDetector.MouseClick:Connect(function()
            local destination = toolDoor.destination.Value
            local density = toolDoor.density.Value
            BindableEvents.densityEvent:Fire(density)
            localPlayer.Character.PrimaryPart.CFrame = destination.CFrame + Vector3.new(0, 10, 0)
            PlayerModule.Set2DCamera()
		end)

        local destination = toolDoor.destination.Value
        local density = toolDoor.density.Value
        BindableEvents.densityEvent:Fire(density)
        localPlayer.Character.PrimaryPart.CFrame = destination.CFrame + Vector3.new(0, 10, 0)
        PlayerModule.Set2DCamera()
        return
    elseif toolDoor.Name == "door" then
        local axis = toolDoor.axis
        local teleport = toolDoor.teleportPart
        teleport.CanTouch = true

		if not axis:FindFirstChild("originalCf") then
            CreateModule.CreateValue("CFrameValue", "originalCf", axis.CFrame, axis)
        end

		if not axis:FindFirstChild("endCf") then
            CreateModule.CreateValue("CFrameValue", "endCf", axis.CFrame * CFrame.Angles(0, math.rad(90) , 0), axis)
        end
        local tweenInfo = TweenInfo.new(1)
        local final = {
            CFrame = axis.endCf.Value
        }
        local tween = TS:Create(axis, tweenInfo, final)
        tween:Play()
        return
    elseif toolDoor.Name == "piano" then
        local door = workspace.Room.room2.pianoDoor
        door.Part.CanTouch = true
        local tweenInfo = TweenInfo.new(2)
        local final = {
            Transparency = 0
        }
        for _, part in door:GetChildren() do
            part.CanCollide = true
            local tween = TS:Create(part, tweenInfo, final)
            tween:Play()
        end
        return
    end
    for _, child:BasePart in toolDoor:GetDescendants() do
        if child:IsA("BasePart") then
            child.Transparency = 1
            child.CanCollide = false
        end
    end
end

function ToolDoorModule.Reset(tDoor)
    tDoor.ClickDetector.MaxActivationDistance = 32
    if IsPhone and tDoor:FindFirstChild("BillboardGui") then
        tDoor.BillboardGui.Enabled = true
	end
    if tDoor.Name == "xbox" then
		tDoor.ClickDetector.CursorIcon = oldIcon
        if xboxCon then
			xboxCon:Disconnect()
        end
        return
    elseif tDoor.Name == "door" then
        local axis = tDoor.axis
        local teleport = tDoor.teleportPart
        teleport.CanTouch = false
		if not axis:FindFirstChild("originalCf") then
            CreateModule.CreateValue("CFrameValue", "originalCf", axis.CFrame, axis)
        else
            axis.CFrame = axis.originalCf.Value
        end
        return
    elseif tDoor.Name == "piano" then
        local door = workspace.Room.room2.pianoDoor
        door.Part.CanTouch = false
        for _, part in door:GetChildren() do
            part.Transparency = 1
            part.CanCollide = false
        end
        return
    end
    for _, child in tDoor:GetDescendants() do
        if child:IsA("BasePart") then
            child.Transparency = 0
            child.CanCollide = true
        end
    end
end


return ToolDoorModule
