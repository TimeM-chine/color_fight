local ReplicatedStorage = game:GetService("ReplicatedStorage")

---- modules ----
local SystemClass = require(game.ServerScriptService.classes.ServerSystemClass)
local KeyboardRecall = require(game.ReplicatedStorage.modules.KeyboardRecall)
local PlayerServerClass = require(game.ServerScriptService.classes.PlayerServerClass)
local ModelModule = require(game.ReplicatedStorage.modules.ModelModule)

---- enums ----
local colorEnum = require(game.ReplicatedStorage.enums.colorEnum)
local colorName = colorEnum.ColorName
local colorList = colorEnum.ColorList
local colorValue = colorEnum.ColorValue
local keyCode = Enum.KeyCode
local dataKey = require(game.ReplicatedStorage.enums.dataKey)
local TextureIds = require(game.ReplicatedStorage.configs.TextureIds)
local universalEnum = require(game.ReplicatedStorage.enums.universalEnum)

---- events ----
local RemoteEvents = game.ReplicatedStorage.RemoteEvents
local changeColorEvent = game.ReplicatedStorage.RemoteEvents.changeColorEvent
local getLoginRewardEvent = game.ReplicatedStorage.RemoteEvents.getLoginRewardEvent
local playerHideSkill = game.ReplicatedStorage.RemoteEvents.playerHideSkill

---- services ----
local PS = game:GetService("Players")
local PhysicsService = game:GetService("PhysicsService")


PhysicsService:RegisterCollisionGroup("player")
PhysicsService:CollisionGroupSetCollidable("player", "player", false)

function CheckLoginReward(player)
    local playerIns = PlayerServerClass.GetIns(player)
    local tempSpeedStart = playerIns:GetOneData(dataKey.tempSpeedStart)
    local tempSpeedInfo = playerIns:GetOneData(dataKey.tempSpeedInfo)
    local tempSkStart = playerIns:GetOneData(dataKey.tempSkStart)
    local tempSkInfo = playerIns:GetOneData(dataKey.tempSkInfo)

    if os.time() - tempSkStart > tempSkInfo[2] then
        tempSkInfo = {0, 0}
        if playerIns:GetOneData(dataKey.chosenSkInd) == 1 then
            playerIns:SetOneData(dataKey.chosenSkInd, 0)
        end
    end

    if os.time() - tempSpeedStart > tempSpeedInfo[2] then
        tempSpeedInfo = {0, 0}
    end

    RemoteEvents.tempRewardEvent:FireClient(player, tempSpeedInfo, tempSkInfo)
end


PS.PlayerAdded:Connect(function(player)
    local pIns = PlayerServerClass.GetIns(player)
    local nowDay = math.floor(os.time()/universalEnum.oneDay)
    local lastLoginTimeStamp = pIns:GetOneData(dataKey.lastLoginTimeStamp)
    while not lastLoginTimeStamp do
        task.wait(0.1)
        lastLoginTimeStamp = pIns:GetOneData(dataKey.lastLoginTimeStamp)
    end
    local lastDay = math.floor(lastLoginTimeStamp/universalEnum.oneDay)
    if nowDay ~= lastDay then
        pIns:SetOneData(dataKey.dailyOnlineTime, 0)
        pIns:SetOneData(dataKey.lastLoginTimeStamp, os.time())
    end
end)


changeColorEvent.OnServerEvent:Connect(function(player, color)
    local pIns = PlayerServerClass.GetIns(player)
    pIns:SetColor(color)
end)

getLoginRewardEvent.OnServerEvent:Connect(function(player, day)
    local loginState = PlayerServerClass.GetIns(player):GetOneData(dataKey.loginState)
    loginState[day] = true
    local playerIns = PlayerServerClass.GetIns(player)
    if day == 1 then
        playerIns:AddHealth()
    elseif day == 2 then
        playerIns:SetOneData(dataKey.tempSpeedStart, os.time())
        playerIns:SetOneData(dataKey.tempSpeedInfo, {5, universalEnum.oneMinute * 5})
    elseif day == 3 then
        playerIns:AddHealth()
    elseif day == 4 then
        playerIns:SetOneData(dataKey.tempSpeedStart, os.time())
        playerIns:SetOneData(dataKey.tempSpeedInfo, {5, universalEnum.oneMinute * 15})
    elseif day == 5 then
        playerIns:AddHealth()
    elseif day == 6 then
        playerIns:SetOneData(dataKey.tempSpeedStart, os.time())
        playerIns:SetOneData(dataKey.tempSpeedInfo, {15, universalEnum.oneMinute * 10})
    elseif day == 7 then
        if not playerIns:GetOneData(dataKey.career)[1] then
            playerIns:SetOneData(dataKey.tempSkStart, os.time())
            playerIns:SetOneData(dataKey.tempSkInfo, {1, universalEnum.oneMinute * 30})
        end

    end
    local tempSpeedInfo = playerIns:GetOneData(dataKey.tempSpeedInfo)
    local tempSkInfo = playerIns:GetOneData(dataKey.tempSkInfo)
    RemoteEvents.tempRewardEvent:FireClient(player, tempSpeedInfo, tempSkInfo)
end)

RemoteEvents.getOnlineRewardEvent.OnServerEvent:Connect(function(player, ind)
    local playerIns = PlayerServerClass.GetIns(player)
    if ind >=3 then
        playerIns:AddHealth()
    elseif ind == 1 then
        playerIns:SetOneData(dataKey.tempSpeedStart, os.time())
        playerIns:SetOneData(dataKey.tempSpeedInfo, {5, universalEnum.oneMinute * 5})

        local tempSpeedInfo = playerIns:GetOneData(dataKey.tempSpeedInfo)
        local tempSkInfo = playerIns:GetOneData(dataKey.tempSkInfo)
        RemoteEvents.tempRewardEvent:FireClient(player, tempSpeedInfo, tempSkInfo)
    else
        playerIns:SetOneData(dataKey.tempSpeedStart, os.time())
        playerIns:SetOneData(dataKey.tempSpeedInfo, {5, universalEnum.oneMinute * 10})

        local tempSpeedInfo = playerIns:GetOneData(dataKey.tempSpeedInfo)
        local tempSkInfo = playerIns:GetOneData(dataKey.tempSkInfo)
        RemoteEvents.tempRewardEvent:FireClient(player, tempSpeedInfo, tempSkInfo)
    end
end)

playerHideSkill.OnServerEvent:Connect(function(player)
    local field = Instance.new("ForceField")
    field.Parent = player.Character
    local whiteList = player.Character.paintCan:GetChildren()
    table.insert(whiteList, player.Character.HumanoidRootPart)
    ModelModule.SetModelTransparency(player.Character, 0.5, whiteList)
    task.wait(10)
    field:Destroy()
    ModelModule.SetModelTransparency(player.Character, 0, whiteList)
end)


RemoteEvents.addHealthEvent.OnServerEvent:Connect(function(player)
    local playerIns = PlayerServerClass.GetIns(player)
    playerIns:AddHealth()
end)


RemoteEvents.chooseSkillEvent.OnServerEvent:Connect(function(player, ind)
    local playerIns = PlayerServerClass.GetIns(player)
    playerIns:SetOneData(dataKey.chosenSkInd, ind)
end)


RemoteEvents.putonShoeEvent.OnServerEvent:Connect(function(player, lv, ind)
    if lv == 0 then
        return
    end
    local playerIns = PlayerServerClass.GetIns(player)
    playerIns:SetOneData(dataKey.chosenShoeInd, {lv, ind})

    local Character = player.Character
    if Character:FindFirstChild("left") then
        Character.left:Destroy()
    end
    if Character:FindFirstChild("right") then
        Character.right:Destroy()
    end

    local shoeLeft:Accessory = game.ServerStorage.shoes[tostring(lv)].left:Clone()
    local shoeRight:Accessory = game.ServerStorage.shoes[tostring(lv)].right:Clone()
    for _, handle in shoeLeft:GetChildren() do
        handle.Mesh.TextureId = TextureIds.shoeMeshTexture[lv][ind]
    end
    for _, handle in shoeRight:GetChildren() do
        handle.Mesh.TextureId = TextureIds.shoeMeshTexture[lv][ind]
    end

    shoeRight.Parent = Character
    shoeLeft.Parent = Character
end)

RemoteEvents.friendInEvent.OnServerEvent:Connect(function(player, friendId)
    local playerIns = PlayerServerClass.GetIns(player)
    local friendsInvited = playerIns:GetOneData(dataKey.friendsInvited)
    if not table.find(friendsInvited, friendId) then
        table.insert(friendsInvited, friendId)
        playerIns:UpdatedOneData(dataKey.friendsInvitedNum, 1)
        -- local num = playerIns:GetOneData(dataKey.friendsInvited)
        -- if num == 1 then
        --     playerIns:AddHealth()
        -- elseif num == 3 then
        --     playerIns:AddHealth()
        -- elseif num == 3 then
        --     playerIns:AddHealth()
        -- end
    end
end)
