

---- classes ----


---- events ----
local remoteEvents = game.ReplicatedStorage.RemoteEvents

---- variables ----
local toolModelsFolder = workspace.toolModels
local bucketModelsFolder = workspace.bucketModels

---- modules ----
local uiController = require(script.Parent.uiScripts.uiController)
local KeyboardRecall = require(game.ReplicatedStorage.modules.KeyboardRecall)



for _, toolModel in toolModelsFolder:GetChildren() do
    toolModel.ProximityPrompt.Enabled = true
    toolModel.CanCollide = true
    for _, child in toolModel:GetChildren() do
        if child:IsA("BasePart") then
            child.Transparency = 0
        end
    end
end

for _, bucketPart:Part in bucketModelsFolder:GetChildren() do
    bucketPart.ProximityPrompt.Enabled = true
    bucketPart.CanCollide = true
    bucketPart.Transparency = 0
end

remoteEvents.hideToolEvent.OnClientEvent:Connect(function(toolModel:Part)
    for _, child in toolModel:GetDescendants() do
        if child:IsA("BasePart") then
            child.Transparency = 1
        end
    end
    toolModel.ProximityPrompt.Enabled = false
    toolModel.CanCollide = false
end)


remoteEvents.hideBucketEvent.OnClientEvent:Connect(function(toolModel:Part)
    toolModel.Transparency = 1
    toolModel.ProximityPrompt.Enabled = false
    toolModel.CanCollide = false
end)

-- game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = 20
