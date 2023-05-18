local Workspace = game:GetService("Workspace")

---- classes ----
local SystemClass = require(script.Parent:WaitForChild("classes").ClientSystemClass)
local ColorDoorClientClass = require(script.Parent.classes.ColorDoorClientClass)

---- modules ----
local KeyboardRecall = require(game.ReplicatedStorage.modules.KeyboardRecall)
local modelModule = require(game.ReplicatedStorage.modules.ModelModule)
local CreateModule = require(game.ReplicatedStorage.modules.CreateModule)

---- events ----
local RemoteEvents = game.ReplicatedStorage.RemoteEvents

---- enums ----
local keyCode = Enum.KeyCode
local argsEnum = require(game.ReplicatedStorage.enums.argsEnum)

---- variables ----
local clientSys = SystemClass.new()
local wallsFolder = game.Workspace.walls
local lastColor = nil
local palletNum = 0
local LocalPlayer = game.Players.LocalPlayer
local PlayerGui = LocalPlayer.PlayerGui
local nowLevel
local hudBgFrame = PlayerGui:WaitForChild("hudScreen").bgFrame


clientSys:ListenForEvent(RemoteEvents.changeColorEvent, function(args)
    local color = args.color

    for _, wall:Part in wallsFolder:GetDescendants() do

        if (not wall:IsA("Part")) or (wall.Name ~= "Part") then
            continue
        end
        -- handle with last color first
        if wall.colorString.Value == lastColor then
            wall.Material = Enum.Material.Glass
            wall.CanCollide = true
        end

        if wall.colorString.Value == color then
            wall.Material = Enum.Material.Neon
            wall.CanCollide = false
        end
    end

    lastColor = color
end)


KeyboardRecall.SetClientRecall(keyCode.Backspace)

---- event recalls ----
RemoteEvents.destroyEvent.OnClientEvent:Connect(function(ins:Instance)
    ins:Destroy()
end)

RemoteEvents.hideToolEvent.OnClientEvent:Connect(function(toolModel:Part)
    for _, child in toolModel:GetDescendants() do
        if child:IsA("BasePart") then
            child.Transparency = 1
        end
    end
    toolModel.ProximityPrompt.Enabled = false
    toolModel.CanCollide = false
end)


RemoteEvents.hideBucketEvent.OnClientEvent:Connect(function(toolModel:Part)
    toolModel.Transparency = 1
    toolModel.ProximityPrompt.Enabled = false
    toolModel.CanCollide = false
end)

RemoteEvents.hideToolDoorEvent.OnClientEvent:Connect(function(door)
    if door:IsA("Part") or door:IsA("UnionOperation") then
        if not door:FindFirstChild("originalCf") then
            CreateModule.CreateValue("CFrameValue", "originalCf", door.CFrame, door)
        end
        door.CFrame = door.CFrame - Vector3.new(0, 100, 0)
    elseif door:IsA("Model") then
        if not door:FindFirstChild("originalCf") then
            CreateModule.CreateValue("CFrameValue", "originalCf", door:GetPivot(), door)
        end
        door:PivotTo(door:GetPivot() - Vector3.new(0, 100, 0))
    end

    if door.Name == "ladder" then
        for _, part:Part in door.ladder:GetChildren() do
			part.Transparency = 0
			part.CanCollide = true
		end
    end
end)


RemoteEvents.teleportEvent.OnClientEvent:Connect(function(ind)
    if ind > 0 then
        hudBgFrame.inLobby.Visible = false
        hudBgFrame.inGame.Visible = true

        hudBgFrame.inGame.pallet.TextLabel.Text = "0/"..#workspace.pallets['level'..ind]:GetChildren()
    else
        hudBgFrame.inLobby.Visible = true
        hudBgFrame.inGame.Visible = false
    end
end)

---- init things ----
for _, part in workspace.airLands:GetChildren() do
    part.CanCollide = false
end

for _, part in workspace.safeAreas:GetChildren() do
    part.CanCollide = false
end

for _, colorDoor in workspace.colorDoors:GetDescendants() do
    if colorDoor:IsA("Part") then
        ColorDoorClientClass.new(colorDoor)
    end
end

for _, pallet in workspace.pallets:GetDescendants() do
    if pallet:IsA("Model") then
        pallet.plate.ProximityPrompt.Triggered:Connect(function(playerWhoTriggered)
            pallet:Destroy()
            palletNum += 1
            hudBgFrame.inGame.pallet.TextLabel.Text = palletNum.."/18"
        end)
    end
end

-- workspace.SpawnLocation.CFrame = Workspace.level1SpawnPoint.CFrame
-- LocalPlayer.CharacterAdded:Wait()

task.wait(5)
LocalPlayer.Character:PivotTo(workspace.mainCityLocation.CFrame)

hudBgFrame.inLobby.Visible = true
