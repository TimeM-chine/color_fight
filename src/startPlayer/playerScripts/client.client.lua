local StarterGui = game:GetService("StarterGui")


---- classes ----
local SystemClass = require(script.Parent:WaitForChild("classes").ClientSystemClass)
local ColorDoorClientClass = require(script.Parent.classes.ColorDoorClientClass)

---- modules ----
local KeyboardRecall = require(game.ReplicatedStorage.modules.KeyboardRecall)

---- events ----
local RemoteEvents = game.ReplicatedStorage.RemoteEvents

---- enums ----
local keyCode = Enum.KeyCode
local argsEnum = require(game.ReplicatedStorage.enums.argsEnum)

---- variables ----
local clientSys = SystemClass.new()
local wallsFolder = game.Workspace.walls
local lastColor = nil


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


for _, colorDoor in workspace.colorDoors:GetChildren() do
    ColorDoorClientClass.new(colorDoor)
end

RemoteEvents.destroyEvent.OnClientEvent:Connect(function(ins:Instance)
    ins:Destroy()
end)


