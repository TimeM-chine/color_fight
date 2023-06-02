

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
local ToolDoorModule = require(game.StarterPlayer.StarterPlayerScripts.modules.ToolDoorModule)

---- functions ----
local BindableFunctions = game.ReplicatedStorage.BindableFunctions

---- variables ----
local touchSafeArea = false
local toolModelsFolder = workspace.toolModels
local bucketModelsFolder = workspace.bucketModels
local toolDoorsFolder = workspace.toolDoors
local colorDoorsFolder = workspace.colorDoors
local keysFolder = workspace.keys
local LocalPlayer = game.Players.LocalPlayer
local PlayerGui = LocalPlayer.PlayerGui
local hudBgFrame = PlayerGui:WaitForChild("hudScreen").bgFrame
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

---- sounds -----
game.SoundService.pickUp:Clone().Parent = LocalPlayer.Character.HumanoidRootPart
game.SoundService.pickUpBucket:Clone().Parent = LocalPlayer.Character.HumanoidRootPart
game.SoundService.playerDie:Clone().Parent = LocalPlayer.Character.HumanoidRootPart
game.SoundService.clickUI:Clone().Parent = LocalPlayer.Character.HumanoidRootPart


remoteEvents.putonShoeEvent:FireServer(chosenShoe[1], chosenShoe[2])
LocalPlayer.Character:WaitForChild("Humanoid").WalkSpeed = playerModule.GetPlayerSpeed()


KeyboardRecall.SetClientRecall(Enum.KeyCode.Equals, function()
    -- playerModule.Set2DCamera()
    playerModule.TurnOnTopLight()
end)

KeyboardRecall.SetClientRecall(Enum.KeyCode.Minus, function()
    -- playerModule.Cancel2DCamera()
    playerModule.TurnOffTopLight()

end)

function DieRest()
    for _, toolModel in toolModelsFolder:GetChildren() do
        toolModel.ProximityPrompt.Enabled = true
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
        ToolDoorModule.Reset(toolDoor)
    end

    ----- keys ----
    for _, key:Part in keysFolder:GetChildren() do
        key.Transparency = 0
        key.ProximityPrompt.Enabled = true
    end
end

function ResetLevel()
    DieRest()
    ----- last doors ----
    for _, lastDoor in workspace.lastDoors:GetChildren() do
        lastDoor.CanCollide = true
    end
end

DieRest()


LocalPlayer.Character.Humanoid.Died:Once(function()
    SkillModule.CancelAllSkill()
end)

BindableEvents.resetLevelEvent.Event:Connect(ResetLevel)


for _, part:Part in workspace.safeAreas:GetChildren() do
    part.Touched:Connect(function(otherPart)
        if otherPart:IsDescendantOf(LocalPlayer.Character) and (not touchSafeArea) then
            game.Lighting.Atmosphere.Density = 0.6
            hudBgFrame.inLobby.Visible = true
            hudBgFrame.inGame.Visible = false

            touchSafeArea = true
        end
    end)

    part.TouchEnded:Connect(function(otherPart)
        if otherPart:IsDescendantOf(LocalPlayer.Character) and touchSafeArea then
            touchSafeArea = false
            -- local ind = BindableFunctions.getLevelInd:Invoke()
            game.Lighting.Atmosphere.Density = 0.7
            hudBgFrame.inLobby.Visible = false
            hudBgFrame.inGame.Visible = true

        end
    end)
end


-- local character = script.Parent

-- local filter = workspace.walls:GetDescendants()
-- for _, part in workspace.safeAreas:GetChildren() do
--     table.insert(filter, part)
-- end

-- param = OverlapParams.new()
-- param.FilterDescendantsInstances = filter
-- param.FilterType = Enum.RaycastFilterType.Include

-- character:WaitForChild("Highlight")

-- local function checkHide()
--     local cf, size = script.Parent:GetBoundingBox()
--     local playerContact = workspace:GetPartBoundsInBox(cf, size, param)
--     for _, conPart in playerContact do
--         if conPart.Parent.Name == "safeAreas" then
--             return true
--         end
--         if conPart.colorString.Value == character.colorString.Value then
--             return true
--         end
--     end
--     return false
-- end

-- while task.wait(0.05) do
--     if checkHide() then
--         character.Highlight.Enabled = true
--     else
--         character.Highlight.Enabled = false
--     end
-- end
