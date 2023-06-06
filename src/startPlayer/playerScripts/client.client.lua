local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")
local Workspace = game:GetService("Workspace")

---- services ----
local MarketplaceService = game:GetService"MarketplaceService"
local ContentProvider = game:GetService("ContentProvider")
local TS = game:GetService("TweenService")
local Debris = game:GetService"Debris"
local UIS = game:GetService("UserInputService")
local IsPhone = UIS.TouchEnabled

---- classes ----
local SystemClass = require(script.Parent:WaitForChild("classes").ClientSystemClass)
local ColorDoorClientClass = require(script.Parent.classes.ColorDoorClientClass)

---- modules ----
local CreateModule = require(game.ReplicatedStorage.modules.CreateModule)
local playerModule = require(script.Parent.modules.PlayerClientModule)
local SkillModule = require(script.Parent.modules.SkillModule)
local ToolDoorModule = require(script.Parent.modules.ToolDoorModule)

---- events ----
local RemoteEvents = game.ReplicatedStorage.RemoteEvents
local BindableEvents = game.ReplicatedStorage.BindableEvents
local BindableFunctions = game.ReplicatedStorage.BindableFunctions

---- enums ----
local keyCode = Enum.KeyCode
local dataKey = require(game.ReplicatedStorage.enums.dataKey)
local argsEnum = require(game.ReplicatedStorage.enums.argsEnum)
local colorEnum = require(game.ReplicatedStorage.enums.colorEnum)
local productIdEnum = require(game.ReplicatedStorage.enums.productIdEnum)
local TextureIds = require(game.ReplicatedStorage.configs.TextureIds)
local tipsConfig = require(game.ReplicatedStorage.configs.TipsConfig)

---- variables ----
local clientSys = SystemClass.new()
local wallsFolder = game.Workspace.walls
local lastColor = nil
local palletNum = 0
local LocalPlayer = game.Players.LocalPlayer
local PlayerGui = LocalPlayer.PlayerGui
local nowLevel = 1 --- TODO still don't know how to change
local hudBgFrame = PlayerGui:WaitForChild("hudScreen").bgFrame

---- settings ----

clientSys:ListenForEvent(RemoteEvents.changeColorEvent, function(args)
    local color = args.color

    if color == "black" then
        local music:Sound = LocalPlayer.Character.HumanoidRootPart:FindFirstChild("win")
        if music then
            music:Play()
        end
        game.Lighting.Atmosphere.Density = 0
        local door = workspace.colorWorld.getBackDoor
        door.Part.CanTouch = true
        local tweenInfo = TweenInfo.new(2)
        local final = {
            Transparency = 0
        }
        for _, part in door:GetChildren() do
            part.CanCollide = true
            local tween = TS:Create(part, tweenInfo, final)
            tween:Play()
        end

        for _, part:Part in workspace.colorWorld:GetDescendants() do
            if not part:IsA("BasePart") then continue end
            final = {
                Color = part.originalColor.Value
            }
            local tween = TS:Create(part, tweenInfo, final)
            tween:Play()
        end
        BindableEvents.perTipEvent:Fire(tipsConfig.Win)
        BindableEvents.resetLevelEvent:Fire()
        palletNum = 0
        hudBgFrame.inGame.pallet.TextLabel.Text = "0/"..#workspace.pallets['level'..nowLevel]:GetChildren()
        return
    end

    if color == "purple" then
        BindableEvents.perTipEvent:Fire(tipsConfig.beforeFirstColorDoor)
    end

    for _, wallModel in wallsFolder:GetChildren() do
        local wall:Part = wallModel.wall
        if not wall:FindFirstChild("colorString") then continue end
        -- handle with last color first
        if wall.colorString.Value == lastColor then
            wall.CanCollide = true
            wall.Transparency = 0
        end

        if wall.colorString.Value == color then
            wall.Color = colorEnum.ColorValue[wall.colorString.Value]
            wall.CanCollide = false
            wall.Transparency = 0.2
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
end)


RemoteEvents.hideBucketEvent.OnClientEvent:Connect(function(toolModel:Part)
    toolModel.Transparency = 1
    toolModel.ProximityPrompt.Enabled = false
    toolModel.CanCollide = false

    local music:Sound = LocalPlayer.Character.HumanoidRootPart:FindFirstChild("pickUpBucket")
    if music then
        music:Play()
    end
end)

RemoteEvents.hideToolDoorEvent.OnClientEvent:Connect(function(door)
    ToolDoorModule.Set(door)
end)

RemoteEvents.teleportEvent.OnClientEvent:Connect(function(ind)
    if ind > 0 then
        -- hudBgFrame.inLobby.Visible = false
        -- hudBgFrame.inGame.Visible = true
        palletNum = 0
        hudBgFrame.inGame.pallet.TextLabel.Text = "0/"..#workspace.pallets['level'..ind]:GetChildren()
        BindableEvents.resetLevelEvent:Fire()

        BindableEvents.perTipEvent:Fire("Pick up the purple paint")
        local colorString:StringValue = LocalPlayer.Character:WaitForChild("colorString")
        colorString.Changed:Once(function(value)
            BindableEvents.perTipEvent:Fire("Find the door that requires purple paint")
        end)
    else
        task.wait(0.1)
        BindableEvents.perTipEvent:Fire()
        game.Lighting.Atmosphere.Density = 0.6
  
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

for _, part:Part in workspace.safeAreas:GetChildren() do
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
            LocalPlayer.Character.HumanoidRootPart.pickUp:Play()
            if not pallet:FindFirstChild("originalCf") then
                CreateModule.CreateValue("CFrameValue", "originalCf", pallet:GetPivot(), pallet)
            end
            pallet:PivotTo(pallet:GetPivot() - Vector3.new(0, 200, 0))
            palletNum += 1
            local ind = BindableFunctions.getLevelInd:Invoke()
            local targetNum = #workspace.pallets['level'..ind]:GetChildren()
            hudBgFrame.inGame.pallet.TextLabel.Text = palletNum.."/"..targetNum

            if tipsConfig.pallets[palletNum] then
                BindableEvents.notifyEvent:Fire(tipsConfig.pallets[palletNum])
            end

            if palletNum == targetNum then
                workspace.lastDoors['level'..ind].CanCollide = false
                workspace.lastDoors['level'..ind].Transparency = 1
            end
        end)
    end
end

for _, heart in workspace.heartSeller:GetChildren() do
    heart.ProximityPrompt.Triggered:Connect(function()
        MarketplaceService:PromptProductPurchase(LocalPlayer, productIdEnum.heart)
    end)
end

for _, part:Part in workspace.colorWorld:GetDescendants() do
    if not part:IsA("BasePart") then continue end
    CreateModule.CreateValue("Color3Value", "originalColor", part.Color, part)
    if math.random(0, 1) > 0 then
        part.Color = colorEnum.white
    else
        part.Color = colorEnum.black
    end
end

for _, model in workspace.toolDoors:GetChildren() do
    model.ClickDetector.CursorIcon = TextureIds.toolDoorCursor[model.Name]
    if IsPhone then
        model.BillboardGui.Enabled = true
    end
end

RemoteEvents.tempRewardEvent.OnClientEvent:Connect(function(tempSpeedInfo, tempSkInfo)
    if tempSpeedInfo[1] ~= 0 then
        playerModule.SetRewardSpeed(tempSpeedInfo[1])
        task.wait(tempSpeedInfo[2])
        playerModule.SetRewardSpeed(0)
    end
end)

LocalPlayer.Character:WaitForChild("HumanoidRootPart")
-- LocalPlayer.Character:PivotTo(workspace.spawn.mainCityLocation.CFrame)
-- game.Lighting.Atmosphere.Density = 0.6

hudBgFrame.inLobby.Visible = true
hudBgFrame.inGame.Visible = true
palletNum = 0
hudBgFrame.inGame.pallet.TextLabel.Text = "0/"..#workspace.pallets['level'..nowLevel]:GetChildren()

---- lobby music -----
local lobbyBGM = SoundService.lobby:Clone()
lobbyBGM.Parent = workspace.spawn.mainCityLocation
lobbyBGM:Play()


local ScaredImg = require(game.ReplicatedStorage.configs.ScaredImg)
local imgs = {}
for _, img in TextureIds.wallPaints do
    table.insert(imgs, img)
end

for _, img in TextureIds.cursor do
    table.insert(imgs, img)
end

for _, img in ScaredImg.scared do
    table.insert(imgs, img)
end

for _, img in ScaredImg.died do
    table.insert(imgs, img)
end


ContentProvider:PreloadAsync(imgs)
print("Images loading finished.")

---- handle with parts ----
local clsFolder = game.StarterPlayer.StarterPlayerScripts.classes
local partsClsNames = {
    "KillingPart", "SizeChangePart", "TeleportPart", "TransChangePart", "MovingPart"
}

for _, folder in workspace:GetDescendants() do
	if not folder:IsA("Folder") then continue end

    for _, name in partsClsNames do
        if folder.Name == name then
            local cls = require(clsFolder[name])
            cls.new(folder.Parent)
        end
    end
end

---- monster foot print -----
local agent:Model = workspace:WaitForChild("monster1")
local footprint = ReplicatedStorage:WaitForChild("footprint")

while task.wait(0.3) do
    if game.StarterGui:GetCoreGuiEnabled(Enum.CoreGuiType.Health) then
        game.StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Health, false)
    end
    local agentRootCf:CFrame = agent.HumanoidRootPart.CFrame
    local footCopy = footprint:Clone()
    agentRootCf = agentRootCf - Vector3.new(0, agentRootCf.Y - 1.6, 0)
    footCopy.CFrame = agentRootCf + agentRootCf.RightVector * math.random(5, 10)/10 + agentRootCf.LookVector * math.random(-5, 5)
    footCopy.SurfaceGui.ImageLabel.Image = TextureIds.footprint[math.random(1, #TextureIds.footprint)]
    footCopy.Parent = workspace
    Debris:AddItem(footCopy, 5)

    footCopy = footprint:Clone()
    footCopy.CFrame = agentRootCf - agentRootCf.RightVector * math.random(5, 10)/10 + agentRootCf.LookVector * math.random(-5, 5)
    footCopy.SurfaceGui.ImageLabel.Image = TextureIds.footprint[math.random(1, #TextureIds.footprint)]
    footCopy.Parent = workspace
    Debris:AddItem(footCopy, 5)
end
