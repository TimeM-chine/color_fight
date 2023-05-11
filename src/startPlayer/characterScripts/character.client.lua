

---- classes ----


---- events ----
local remoteEvents = game.ReplicatedStorage.RemoteEvents

---- variables ----
local toolModelsFolder = workspace.toolModels

---- modules ----
local uiController = require(script.Parent.uiScripts.uiController)
local KeyboardRecall = require(game.ReplicatedStorage.modules.KeyboardRecall)



for _, toolModel in toolModelsFolder:GetChildren() do
    toolModel.ProximityPrompt.Enabled = true
    toolModel.CanCollide = true
    toolModel.Transparency = 0
end

-- KeyboardRecall.SetClientRecall(Enum.KeyCode.Space, function()
--     local t = {"top", "middle", "bottom"}
--     uiController.SetNotification("wuhu yeah babe", t[math.random(1, 3)])
-- end)


remoteEvents.hideToolEvent.OnClientEvent:Connect(function(toolModel:Part)
    toolModel.Transparency = 1
    toolModel.ProximityPrompt.Enabled = false
    toolModel.CanCollide = false
end)

-- game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = 20
