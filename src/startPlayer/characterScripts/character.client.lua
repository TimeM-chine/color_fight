

---- classes ----


---- events ----
local remoteEvents = game.ReplicatedStorage.RemoteEvents
local BindableEvents = game.ReplicatedStorage.BindableEvents

---- enums ----
local universalEnum = require(game.ReplicatedStorage.enums.universalEnum)
local dataKey = require(game.ReplicatedStorage.enums.dataKey)

---- modules ----
local uiController = require(script.Parent.uiScripts.uiController)
local KeyboardRecall = require(game.ReplicatedStorage.modules.KeyboardRecall)
local CreateModule = require(game.ReplicatedStorage.modules.CreateModule)
local playerModule = require(game.StarterPlayer.StarterPlayerScripts.modules.PlayerClientModule)
local SkillModule = require(game.StarterPlayer.StarterPlayerScripts.modules.SkillModule)

---- variables ----
local toolModelsFolder = workspace.toolModels
local bucketModelsFolder = workspace.bucketModels
local toolDoorsFolder = workspace.toolDoors
local colorDoorsFolder = workspace.colorDoors
local keysFolder = workspace.keys
local LocalPlayer = game.Players.LocalPlayer
local chosenSkInd = playerModule.GetPlayerOneData(dataKey.chosenSkInd)
SkillModule.SetSkillId(chosenSkInd)

local chosenShoe = playerModule.GetPlayerOneData(dataKey.chosenShoeInd)
while not chosenShoe do
    chosenShoe = playerModule.GetPlayerOneData(dataKey.chosenShoeInd)
    task.wait(1)
end

local cd = SkillModule.GetCd()
if cd >= 1 then
    SkillModule.IntoCd()
end


remoteEvents.putonShoeEvent:FireServer(chosenShoe[1], chosenShoe[2])
LocalPlayer.Character:WaitForChild("Humanoid").WalkSpeed = playerModule.GetPlayerSpeed()

function ResetLevel()
    for _, toolModel in toolModelsFolder:GetChildren() do
        toolModel.ProximityPrompt.Enabled = true
        toolModel.CanCollide = true
        for _, child in toolModel:GetChildren() do
            if child:IsA("BasePart") then
                child.Transparency = 0
            end
        end
    end

    for _, bucketPart:Part in bucketModelsFolder:GetDescendants() do
        if bucketPart:IsA("Part") then
            bucketPart.ProximityPrompt.Enabled = true
            bucketPart.CanCollide = true
            bucketPart.Transparency = 0
        end

    end

    for _, toolDoor in toolDoorsFolder:GetChildren() do
        local module = require(toolDoor.clientSet)
        module.Reset()
    end

    ----- keys ----
    for _, key:Part in keysFolder:GetChildren() do
        key.Transparency = 0
        key.ProximityPrompt.Enabled = true
    end

    ----- last doors ----
    for _, lastDoor in workspace.lastDoors:GetChildren() do
        lastDoor.CanCollide = true
    end
end

ResetLevel()

BindableEvents.resetLevelEvent.Event:Connect(ResetLevel)
