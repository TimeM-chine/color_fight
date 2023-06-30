

---- classes ----


---- events ----
local remoteEvents = game.ReplicatedStorage.RemoteEvents
local BindableEvents = game.ReplicatedStorage.BindableEvents

---- enums ----
local universalEnum = require(game.ReplicatedStorage.enums.universalEnum)
local dataKey = require(game.ReplicatedStorage.enums.dataKey)
local tipsConfig = require(game.ReplicatedStorage.configs.TipsConfig)

---- modules ----
local uiController = require(script.Parent.uiScripts.uiController)
local KeyboardRecall = require(game.ReplicatedStorage.modules.KeyboardRecall)
local CreateModule = require(game.ReplicatedStorage.modules.CreateModule)
local playerModule = require(game.Players.LocalPlayer.PlayerScripts.modules.PlayerClientModule)
local SkillModule = require(game.Players.LocalPlayer.PlayerScripts.modules.SkillModule)
local ToolDoorModule = require(game.Players.LocalPlayer.PlayerScripts.modules.ToolDoorModule)

---- functions ----
local BindableFunctions = game.ReplicatedStorage.BindableFunctions

---- variables ----
local touchSafeArea = false
local toolModelsFolder = workspace.toolModels
local bucketModelsFolder = workspace.bucketModels
local toolDoorsFolder = workspace.toolDoors
local colorDoorsFolder = workspace.colorDoors
local LocalPlayer = game.Players.LocalPlayer
local PlayerGui = LocalPlayer.PlayerGui
local hudBgFrame = PlayerGui:WaitForChild("hudScreen").bgFrame
local density
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

game.SoundService.teleport:Clone().Parent = LocalPlayer.Character.HumanoidRootPart
game.SoundService.mound:Clone().Parent = LocalPlayer.Character.HumanoidRootPart
game.SoundService.door:Clone().Parent = LocalPlayer.Character.HumanoidRootPart
game.SoundService.fence:Clone().Parent = LocalPlayer.Character.HumanoidRootPart
game.SoundService.xbox:Clone().Parent = LocalPlayer.Character.HumanoidRootPart
game.SoundService.baffle:Clone().Parent = LocalPlayer.Character.HumanoidRootPart
game.SoundService.win:Clone().Parent = LocalPlayer.Character.HumanoidRootPart


remoteEvents.putonShoeEvent:FireServer(chosenShoe[1], chosenShoe[2])
LocalPlayer.Character:WaitForChild("Humanoid").WalkSpeed = playerModule.GetPlayerSpeed()
playerModule.Cancel2DCamera()
workspace.CurrentCamera.CameraSubject = LocalPlayer.Character.Humanoid


BindableEvents.densityEvent.Event:Connect(function(value)
    if value == "sk4" then
        density = 0.6
        task.delay(30, function()
            if density == 0.6 then
                density = 0.9
            end
        end)
    else
        density = value
    end
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

    for _, bucketPart:Part in bucketModelsFolder:GetChildren() do
        bucketPart.ProximityPrompt.Enabled = true
        bucketPart.CanCollide = true
        bucketPart.Transparency = 0
    end

    for _, toolDoor in toolDoorsFolder:GetChildren() do
        ToolDoorModule.Reset(toolDoor)
    end

end

function ResetLevel()
    DieRest()
    ----- last doors ----
    for _, lastDoor in workspace.lastDoors:GetChildren() do
        lastDoor.CanCollide = true
        lastDoor.Transparency = 0.35
    end

    ---- pallets ----
    for _, pallet in workspace.pallets:GetDescendants() do
        if pallet:IsA("Model") then
            if not pallet:FindFirstChild("originalCf") then
                CreateModule.CreateValue("CFrameValue", "originalCf", pallet:GetPivot(), pallet)
            end
            pallet:PivotTo(pallet.originalCf.value)
        end
    end

end

DieRest()


LocalPlayer.Character.Humanoid.Died:Once(function()
	SkillModule.CancelAllSkill()
	DieRest()
end)

BindableEvents.resetLevelEvent.Event:Connect(ResetLevel)


local chosenTail = playerModule.GetPlayerOneData(dataKey.chosenTail)
if chosenTail > 0 then
    remoteEvents.operateTail:FireServer("Equip", chosenTail)
end
-- for _, part:Part in workspace.safeAreas:GetChildren() do
--     part.CanTouch = true
--     part.Touched:Connect(function(otherPart)
--         if otherPart:IsDescendantOf(LocalPlayer.Character) and (not touchSafeArea) then
--             game.Lighting.Atmosphere.Density = 0.6
--             -- hudBgFrame.inLobby.Visible = true
--             -- hudBgFrame.inGame.Visible = false

--             touchSafeArea = true
--         end
--     end)

--     part.TouchEnded:Connect(function(otherPart)
--         if otherPart:IsDescendantOf(LocalPlayer.Character) and touchSafeArea then
--             touchSafeArea = false
--             -- local ind = BindableFunctions.getLevelInd:Invoke()
--             game.Lighting.Atmosphere.Density = 0.7
--             -- hudBgFrame.inLobby.Visible = false
--             -- hudBgFrame.inGame.Visible = true
--         end
--     end)
-- end

uiController.SetPersistentTip(tipsConfig.mainCity)

script.Parent:WaitForChild("HumanoidRootPart")
local checkPart:Part = workspace.spawn.checkPart
local filter = script.Parent:GetChildren()

local param = OverlapParams.new()
param.FilterDescendantsInstances = filter
param.FilterType = Enum.RaycastFilterType.Include
while task.wait(0.5) do
    local cf, size = checkPart.CFrame, checkPart.Size
    local playerContact = workspace:GetPartBoundsInBox(cf, size, param)
    if playerContact[1] then
        game.Lighting.Atmosphere.Density = 0
    else
        if density then
            game.Lighting.Atmosphere.Density = density
        else
            game.Lighting.Atmosphere.Density = 0.9
        end
    end
end

