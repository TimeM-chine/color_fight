local StarterGui = game:GetService("StarterGui")


---- modules ----
local KeyboardRecall = require(game.ReplicatedStorage.modules.KeyboardRecall)
local SystemClass = require(script.Parent:WaitForChild("classes").ClientSystemClass)

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

    for _, wall:Part in wallsFolder:GetChildren() do
        if wall.colorString.Value == color then
            wall.Material = Enum.Material.Neon
            wall.CanCollide = false
        end

        if wall.colorString.Value == lastColor then
            wall.Material = Enum.Material.Plastic
            wall.CanCollide = true
        end
    end

    lastColor = color
end)


KeyboardRecall.SetClientRecall(keyCode.Backspace)


