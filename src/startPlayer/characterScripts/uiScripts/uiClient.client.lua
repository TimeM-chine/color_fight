-- ================================================================================
-- ui client
-- ================================================================================
---- services ----
local Debris = game:GetService("Debris")
local Lighting = game:GetService("Lighting")
local MarketplaceService = game:GetService"MarketplaceService"

---- variables ----
local LocalPlayer = game.Players.LocalPlayer
local PlayerGui = LocalPlayer.PlayerGui
local hudBgFrame = PlayerGui.hudScreen.bgFrame
local shopBtn = hudBgFrame.inLobby.shopBtn
local onlineBtn = hudBgFrame.inLobby.onlineBtn
local buyHeartBtn = hudBgFrame.hpFrame.buyHeartBtn
local unitsFolder = PlayerGui.units
local hpFrame = hudBgFrame.hpFrame
local speedFrame = hudBgFrame.speedFrame
local friendFrame = hudBgFrame.friendFrame
local inviteBtn = speedFrame.inviteBtn
local friendNum = 0
local cdKeyBtn = hudBgFrame.cdKeyFrame.btn
local donateBtn = hudBgFrame.donateFrame.btn
local touching
--- navigation ---
local navTimeLeft = 999
local visionTime = 15
local NavCD = 90
local cd = 0
local free = true
local co

---- events ----
local RemoteEvents = game.ReplicatedStorage.RemoteEvents
local notifyEvent = game.ReplicatedStorage.BindableEvents.notifyEvent
local perTipEvent = game.ReplicatedStorage.BindableEvents.perTipEvent
-- local addHealthEvent = game.ReplicatedStorage.RemoteEvents.addHealthEvent
local serverNotifyEvent = game.ReplicatedStorage.RemoteEvents.serverNotifyEvent

---- enums ----
local screenEnum = require(game.ReplicatedStorage.enums.screenEnum)
local productIdEnum = require(game.ReplicatedStorage.enums.productIdEnum)
-- local gameConfig = require(game.ReplicatedStorage.configs.GameConfig)

---- modules ----
local uiController = require(script.Parent.uiController)
local SkillModule = require(game.Players.LocalPlayer.PlayerScripts.modules.SkillModule)
local GAModule = require(game.ReplicatedStorage.modules.GAModule)

---------------------- events -------------------------
notifyEvent.Event:Connect(function(msg, noteType)
    noteType = noteType or "middle"
    uiController.SetNotification(msg, noteType)
end)

serverNotifyEvent.OnClientEvent:Connect(function(msg, noteType)
    noteType = noteType or "middle"
    uiController.SetNotification(msg, noteType)
end)

perTipEvent.Event:Connect(function(msg)
    uiController.SetPersistentTip(msg)
end)

---------------------- buttons -------------------------
cdKeyBtn.MouseButton1Click:Connect(function()
    uiController.PushScreen(screenEnum.cdKeyFrame)
end)

donateBtn.MouseButton1Click:Connect(function()
    uiController.PushScreen(screenEnum.donateFrame)
end)

-- if os.time() > gameConfig.onlineRewardsEnd then
--     onlineBtn.Visible = false
-- else
onlineBtn.MouseButton1Click:Connect(function()
    uiController.PushScreen(screenEnum.onlineRewardsFrame)
    GAModule:addDesignEvent({
        eventId = `pageCheck:onlineRewardsPage:{LocalPlayer.UserId}`
    })
end)
-- end


shopBtn.MouseButton1Click:Connect(function()
    LocalPlayer.Character.HumanoidRootPart.clickUI:Play()
    uiController.PushScreen(screenEnum.shopFrame)
end)

buyHeartBtn.MouseButton1Click:Connect(function()
    LocalPlayer.Character.HumanoidRootPart.clickUI:Play()
    print("player buy heart")
    -- addHealthEvent:FireServer()
    MarketplaceService:PromptProductPurchase(LocalPlayer, productIdEnum.heart)
end)

hudBgFrame.inGame.skillBtn.MouseButton1Click:Connect(function()
    LocalPlayer.Character.HumanoidRootPart.clickUI:Play()

    SkillModule.UseSkill()
end)


--[[---- navigation btn ----]]--
local toolAndDoor = {
    keys = workspace.toolDoors.door,
    shovel = workspace.toolDoors.mound,
    crowbar = workspace.toolDoors.fence,
    cassette = workspace.toolDoors.xbox,
    musicScore = workspace.toolDoors.piano,
    spanner = workspace.toolDoors.baffle
}

local cdImg = hudBgFrame.inGame.navigationBtn.cdImage
cdImg.Visible = false
function runCd()
    if cd == 0 then
        cd = NavCD
    end
    while cd >= 1 do
        -- print("cd", cd)
        cd -= 1
        cdImg.TextLabel.Text = tostring(cd)
        if cd == 0 then
            cdImg.Visible = false
        end
        task.wait(1)
    end
end

function IntoCd()
    cdImg.Visible = true
    if co then
        coroutine.close(co)
    end
    co = coroutine.create(runCd)
    coroutine.resume(co)
end

function CheckFree()
    if free then
        GAModule:addDesignEvent({
            eventId = `useSkill:findDoor:free`
        })
    else
        GAModule:addDesignEvent({
            eventId = `useSkill:findDoor:payed`
        })
    end
end


hudBgFrame.inGame.navigationBtn.MouseButton1Click:Connect(function()
    if cd > 0 then
        uiController.SetNotification("Skill is in CD.")
        return
    end

    if Lighting.Atmosphere.Density == 0 then
        uiController.SetNotification("Can not use here.")
        return
    end

    if navTimeLeft <= 0 then
        MarketplaceService:PromptProductPurchase(LocalPlayer, productIdEnum.navigation)
        return
    end

    local lastDoor = workspace.lastDoors.level1
    if lastDoor.CanCollide == false then
        IntoCd()
        navTimeLeft -= 1
        CheckFree()

        local hl = Instance.new("Highlight")
        lastDoor.Transparency = 0
        task.delay(visionTime, function()
            lastDoor.Transparency = 1
        end)
        hl.Parent = lastDoor
        Debris:AddItem(hl, visionTime)
    end

    local colorString = LocalPlayer.Character:WaitForChild("colorString")
    local char = LocalPlayer.Character
    local tool = false
    if colorString.Value == "empty" then
        for toolName, door in toolAndDoor do
            if char:FindFirstChild(toolName) then
                tool = true
                local hl = Instance.new("Highlight")
                hl.Parent = door
                Debris:AddItem(hl, visionTime)

                IntoCd()
                navTimeLeft -= 1
                CheckFree()
                break
            end
        end

        if not tool then
            uiController.SetNotification("Find a bucket or a tool first.")
        end
    else

        IntoCd()
        navTimeLeft -= 1
        CheckFree()

        local hl = Instance.new("Highlight")
        local cDoor:Part = workspace.colorDoors[colorString.Value.."Door"]
        cDoor.Transparency = 0
        task.delay(visionTime, function()
            cDoor.Transparency = 0.45
        end)
        hl.Parent = workspace.colorDoors[colorString.Value.."Door"]
        Debris:AddItem(hl, visionTime)
    end


end)


RemoteEvents.buyNavigation.OnClientEvent:Connect(function()
    navTimeLeft = 1
    free = false
end)
------ navigation btn ------

inviteBtn.MouseButton1Click:Connect(function()
    LocalPlayer.Character.HumanoidRootPart.clickUI:Play()
    GAModule:addDesignEvent({
        eventId = `buttonCheck:inviteBtn:{LocalPlayer.UserId}`
    })
    uiController.PushScreen(screenEnum.friendsRewards)

end)

workspace.spawn.roleSeller.Hologram.Base.Touched:Connect(function(part:Part)
    if part:IsDescendantOf(LocalPlayer.Character) and not touching and (not PlayerGui.pushScreen.Enabled) then
        touching = true
        uiController.PushScreen(screenEnum.shopFrame)
        task.delay(2, function()
            touching = false
        end)
    end
end)

workspace.spawn.shoeShop.showPart.Touched:Connect(function(part:Part)
    if part:IsDescendantOf(LocalPlayer.Character) and not touching and (not PlayerGui.pushScreen.Enabled) then
        touching = true
        local frameIns = uiController.PushScreen(screenEnum.shopFrame)
        frameIns:CheckShoes()
        frameIns:OpenShoeShop()
        task.delay(2, function()
            touching = false
        end)
    end
end)

workspace.spawn.signBox.touchPart.Touched:Connect(function(part:Part)
    if part:IsDescendantOf(LocalPlayer.Character) and not touching and (not PlayerGui.pushScreen.Enabled) then
        touching = true
        uiController.PushScreen(screenEnum.loginRewardsFrame)
        task.delay(2, function()
            touching = false
        end)
    end

end)

workspace.spawn.piggy.touchPart.Touched:Connect(function(part:Part)
    if part:IsDescendantOf(LocalPlayer.Character) and not touching and (not PlayerGui.pushScreen.Enabled) then
        touching = true
        uiController.PushScreen(screenEnum.donateFrame)
        task.delay(2, function()
            touching = false
        end)
    end

end)
---------------------- hp -------------------------

local hp = LocalPlayer.Character.Humanoid.Health

if hp ~= 100 then
    for i=1, hp do
        hpFrame['hp'..i].full.Visible = true
    end

    for i= hp + 1, 6 do
        hpFrame['hp'..i].full.Visible = false
    end
end


LocalPlayer.Character.Humanoid.HealthChanged:Connect(function(health)
    for i=1, health do
        hpFrame['hp'..i].full.Visible = true
    end

    for i= health + 1, 6 do
        hpFrame['hp'..i].full.Visible = false
    end

    if health < 6 then
        hpFrame.buyHeartBtn.Visible = true
    else
        hpFrame.buyHeartBtn.Visible = false
    end
end)

---------------------- friends -------------------------
local function onPlayerAdded(player:Player)
	if LocalPlayer:IsFriendsWith(player.UserId) then
        friendNum += 1
        GAModule:addDesignEvent({
            eventId = `inviteSuccess:{LocalPlayer.UserId}:{player.UserId}`
        })
        RemoteEvents.friendInEvent:FireServer(player.UserId)
    end
    friendFrame.TextLabel.Text = `friend num: {friendNum}`
    speedFrame.TextLabel.Text = `Speed buff: {math.min(15, friendNum*5)}%`
end

for _, player in pairs(game.Players:GetPlayers()) do
	onPlayerAdded(player)
end
game.Players.PlayerAdded:Connect(onPlayerAdded)
game.Players.PlayerRemoving:Connect(function(player)
    if LocalPlayer:IsFriendsWith(player.UserId) then
        friendNum -= 1
    end
    -- if player add friends in game, something would happen
    if friendNum < 0 then
        return
    end
    friendFrame.TextLabel.Text = `friend num: {friendNum}`
    speedFrame.TextLabel.Text = `Speed buff: {math.min(15, friendNum*5)}%`
end)
