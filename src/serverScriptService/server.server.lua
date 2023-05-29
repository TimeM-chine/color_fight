local ReplicatedStorage = game:GetService("ReplicatedStorage")

---- modules ----
local SystemClass = require(game.ServerScriptService.classes.ServerSystemClass)
local KeyboardRecall = require(game.ReplicatedStorage.modules.KeyboardRecall)
local PlayerServerClass = require(game.ServerScriptService.classes.PlayerServerClass)
local ModelModule = require(game.ReplicatedStorage.modules.ModelModule)
local BillboardManager = require(game.ServerScriptService.modules.BillboardManager)

---- enums ----
local colorEnum = require(game.ReplicatedStorage.enums.colorEnum)
local colorName = colorEnum.ColorName
local colorList = colorEnum.ColorList
local colorValue = colorEnum.ColorValue
local keyCode = Enum.KeyCode
local dataKey = require(game.ReplicatedStorage.enums.dataKey)
local TextureIds = require(game.ReplicatedStorage.configs.TextureIds)
local universalEnum = require(game.ReplicatedStorage.enums.universalEnum)
local gameConfig = require(game.ReplicatedStorage.configs.GameConfig)

---- events ----
local RemoteEvents = game.ReplicatedStorage.RemoteEvents
local changeColorEvent = game.ReplicatedStorage.RemoteEvents.changeColorEvent
local getLoginRewardEvent = game.ReplicatedStorage.RemoteEvents.getLoginRewardEvent
local playerHideSkill = game.ReplicatedStorage.RemoteEvents.playerHideSkill

local remoteFunctions = game.ReplicatedStorage.RemoteFunctions

---- services ----
local PS = game:GetService("Players")
local PhysicsService = game:GetService("PhysicsService")


PhysicsService:RegisterCollisionGroup("player")
PhysicsService:CollisionGroupSetCollidable("player", "player", false)

function CheckTempReward(player)
    local playerIns = PlayerServerClass.GetIns(player)
    local tempSpeedStart = playerIns:GetOneData(dataKey.tempSpeedStart)
    local tempSpeedInfo = playerIns:GetOneData(dataKey.tempSpeedInfo)
    local tempSkStart = playerIns:GetOneData(dataKey.tempSkStart)
    local tempSkInfo = playerIns:GetOneData(dataKey.tempSkInfo)

    if os.time() - tempSkStart > tempSkInfo[2] then
        tempSkInfo = {0, 0}
        if playerIns:GetOneData(dataKey.chosenSkInd) == tempSkInfo[1] then
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

    local leaderstats = Instance.new("Folder")
    leaderstats.Name = "leaderstats"
    leaderstats.Parent = player

    local wins = Instance.new("IntValue")
    wins.Name = "Wins"
    wins.Value = pIns:GetOneData(dataKey.totalWins)
    wins.Parent = leaderstats
    local NowWins = Instance.new("IntValue")
    NowWins.Name = "NowWins"
    NowWins.Value = pIns:GetOneData(dataKey.wins)
    NowWins.Parent = leaderstats
end)


changeColorEvent.OnServerEvent:Connect(function(player, color)
    local pIns = PlayerServerClass.GetIns(player)
    pIns:SetColor(color)
end)

getLoginRewardEvent.OnServerEvent:Connect(function(player, day, isResign)
    local loginState = PlayerServerClass.GetIns(player):GetOneData(dataKey.loginState)
    loginState[day] = true
    local playerIns = PlayerServerClass.GetIns(player)
    if isResign then
        playerIns:UpdatedOneData(dataKey.wins, -gameConfig.resignCost)
        player.leaderstats.NowWins.Value = playerIns:GetOneData(dataKey.wins)
    end
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
    end
end)

RemoteEvents.getFriendRewards.OnServerEvent:Connect(function(player, ind)
    local playerIns = PlayerServerClass.GetIns(player)
    if ind == 1 or ind == 2 then
        playerIns:AddHealth()
    elseif ind == 3 then
        playerIns:SetOneData(dataKey.tempSpeedStart, os.time())
        playerIns:SetOneData(dataKey.tempSpeedInfo, {15, universalEnum.oneMinute * 10})
    elseif ind == 4 then
        playerIns:SetOneData(dataKey.tempSpeedStart, os.time())
        playerIns:SetOneData(dataKey.tempSpeedInfo, {15, universalEnum.oneMinute * 15})
    elseif ind == 5 then
        playerIns:SetOneData(dataKey.tempSpeedStart, os.time())
        playerIns:SetOneData(dataKey.tempSpeedInfo, {15, universalEnum.oneMinute * 20})
    elseif ind == 6 then
        if not playerIns:GetOneData(dataKey.career)[1] then
            playerIns:SetOneData(dataKey.tempSkStart, os.time())
            playerIns:SetOneData(dataKey.tempSkInfo, {1, universalEnum.oneMinute * 30})
        end
    else
        if not playerIns:GetOneData(dataKey.career)[1] then
            playerIns:SetOneData(dataKey.tempSkStart, os.time())
            playerIns:SetOneData(dataKey.tempSkInfo, {1, universalEnum.oneHour * 2})
        end
    end
    local tempSpeedInfo = playerIns:GetOneData(dataKey.tempSpeedInfo)
    local tempSkInfo = playerIns:GetOneData(dataKey.tempSkInfo)
    RemoteEvents.tempRewardEvent:FireClient(player, tempSpeedInfo, tempSkInfo)
end)


function remoteFunctions.Redeem.OnServerInvoke(player, key)
    local playerIns = PlayerServerClass.GetIns(player)

    local cdKeyUsed = playerIns:GetOneData(dataKey.cdKeyUsed)
    if table.find(cdKeyUsed, key) then
        return "used"
    else
        table.insert(cdKeyUsed, key)
        if key == "KoiStudio" then
            if not playerIns:GetOneData(dataKey.career)[3] then
                playerIns:SetOneData(dataKey.tempSkStart, os.time())
                playerIns:SetOneData(dataKey.tempSkInfo, {3, universalEnum.oneMinute * 5})
            end
            local tempSpeedInfo = playerIns:GetOneData(dataKey.tempSpeedInfo)
            local tempSkInfo = playerIns:GetOneData(dataKey.tempSkInfo)
            RemoteEvents.tempRewardEvent:FireClient(player, tempSpeedInfo, tempSkInfo)
            return "success", TextureIds.skillImg[3][1], "Experience ParkourMan for 5 minutes!"
        else
            return "wrong key"
        end
    end
end


while task.wait(60) do
    BillboardManager.initBillboard()
    for _, player in game.Players:GetPlayers() do
        CheckTempReward(player)
    end
end
