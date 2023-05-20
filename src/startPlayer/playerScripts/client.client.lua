local Workspace = game:GetService("Workspace")

---- services ----
local MarketplaceService = game:GetService"MarketplaceService"

---- classes ----
local SystemClass = require(script.Parent:WaitForChild("classes").ClientSystemClass)
local ColorDoorClientClass = require(script.Parent.classes.ColorDoorClientClass)

---- modules ----
local KeyboardRecall = require(game.ReplicatedStorage.modules.KeyboardRecall)
local modelModule = require(game.ReplicatedStorage.modules.ModelModule)
local CreateModule = require(game.ReplicatedStorage.modules.CreateModule)

---- events ----
local RemoteEvents = game.ReplicatedStorage.RemoteEvents
local BindableEvents = game.ReplicatedStorage.BindableEvents
local BindableFunctions = game.ReplicatedStorage.BindableFunctions

---- enums ----
local keyCode = Enum.KeyCode
local argsEnum = require(game.ReplicatedStorage.enums.argsEnum)
local productIdEnum = require(game.ReplicatedStorage.enums.productIdEnum)

---- variables ----
local clientSys = SystemClass.new()
local wallsFolder = game.Workspace.walls
local lastColor = nil
local palletNum = 0
local LocalPlayer = game.Players.LocalPlayer
local PlayerGui = LocalPlayer.PlayerGui
local nowLevel = 0
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
    local module = require(door.clientSet)
    module.Set()
end)


RemoteEvents.teleportEvent.OnClientEvent:Connect(function(ind)
    if ind > 0 then
        hudBgFrame.inLobby.Visible = false
        hudBgFrame.inGame.Visible = true
        palletNum = 0
        hudBgFrame.inGame.pallet.TextLabel.Text = "0/"..#workspace.pallets['level'..ind]:GetChildren()
        BindableEvents.resetLevelEvent:Fire()
        ---- reset every thing ----
        for _, pallet in workspace.pallets:GetDescendants() do
            if pallet:IsA("Model") then
                if not pallet:FindFirstChild("originalCf") then
                    CreateModule.CreateValue("CFrameValue", "originalCf", pallet:GetPivot(), pallet)
                end
                pallet:PivotTo(pallet.originalCf.value)
            end
        end
    else
        hudBgFrame.inLobby.Visible = true
        hudBgFrame.inGame.Visible = false

        for _, tool in workspace.toolModels:GetChildren() do
            local name = tool.Name
            if LocalPlayer.Character:FindFirstChild(name) then
                LocalPlayer.Character[name]:Destroy()
            end
        end

        RemoteEvents.changeColorEvent:FireServer("empty")
    end
    nowLevel = ind
end)

BindableFunctions.getLevelInd.OnInvoke = function()
    return nowLevel
end

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
            -- CreateModule.CreateValue("CFrameVA")
            if not pallet:FindFirstChild("originalCf") then
                CreateModule.CreateValue("CFrameValue", "originalCf", pallet:GetPivot(), pallet)
            end
            pallet:PivotTo(pallet:GetPivot() - Vector3.new(0, 200, 0))
            palletNum += 1
            hudBgFrame.inGame.pallet.TextLabel.Text = palletNum.."/18"
        end)
    end
end

for _, heart in workspace.heartSeller:GetChildren() do
    heart.ProximityPrompt.Triggered:Connect(function()
        MarketplaceService:PromptProductPurchase(LocalPlayer, productIdEnum.heart)
    end)
end

-- workspace.SpawnLocation.CFrame = Workspace.level1SpawnPoint.CFrame
-- LocalPlayer.CharacterAdded:Wait()
LocalPlayer.Character:WaitForChild("HumanoidRootPart")
LocalPlayer.Character:PivotTo(workspace.mainCityLocation.CFrame)

hudBgFrame.inLobby.Visible = true
