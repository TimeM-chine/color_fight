

---- classes ----


---- events ----
local remoteEvents = game.ReplicatedStorage.RemoteEvents

---- variables ----
local toolModelsFolder = workspace.toolModels
local bucketModelsFolder = workspace.bucketModels
local LocalPlayer = game.Players.LocalPlayer

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

-- LocalPlayer.Character.Humanoid.WalkSpeed = 16


uiController.SetPersistentTip("Pick up the purple paint")
local colorString:StringValue = LocalPlayer.Character:WaitForChild("colorString")
colorString.Changed:Once(function(value)
    uiController.SetPersistentTip("Find the door that requires purple paint")
end)

