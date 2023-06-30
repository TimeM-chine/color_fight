-- ================================================================================
-- wall cls --> server side, control global color or something
-- ================================================================================

---- classes ----
local PlayerServerClass = require(game.ServerScriptService.classes.PlayerServerClass)

---- modules ----
local CreateModule = require(game.ReplicatedStorage.modules.CreateModule)
local BillboardManager = require(game.ServerScriptService.modules.BillboardManager)
local GAModule = require(game.ReplicatedStorage.modules.GAModule)

---- variables ----
local bucketModelInsList = {}
local playerLevelTime = {}

---- enums ----
local colorEnum = require(game.ReplicatedStorage.enums.colorEnum)
local colorList = colorEnum.ColorList
local colorValue = colorEnum.ColorValue
local dataKey = require(game.ReplicatedStorage.enums.dataKey)
local rankListConfig = require(game.ReplicatedStorage.configs.RankList)
local gameConfig = require(game.ReplicatedStorage.configs.GameConfig)

---- events -----
local hideBucketEvent = game.ReplicatedStorage.RemoteEvents.hideBucketEvent
local serverNotifyEvent = game.ReplicatedStorage.RemoteEvents.serverNotifyEvent

local BucketModelServerClass = {}
BucketModelServerClass.__index = BucketModelServerClass
BucketModelServerClass.tagName = "BucketModel"
BucketModelServerClass.toolModel = nil
BucketModelServerClass.interactCon  = nil

function BucketModelServerClass.new(toolM:Part)
	local self = setmetatable({}, BucketModelServerClass)
	self.toolModel = toolM

    local ppt:ProximityPrompt = toolM.ProximityPrompt
    self.interactCon = ppt.Triggered:Connect(function(playerWhoTriggered)
        local playerIns = PlayerServerClass.GetIns(playerWhoTriggered)
        playerIns:SetColor(self.toolModel.colorString.Value)
        hideBucketEvent:FireClient(playerWhoTriggered, self.toolModel)
        GAModule:addDesignEvent(playerWhoTriggered.UserId, {
            eventId = `pickUpBucket:{playerWhoTriggered.UserId}:{self.toolModel.colorString.Value}`
        })
        if self.toolModel.colorString.Value == "black" then
            serverNotifyEvent:FireClient(playerWhoTriggered, "Return to the main city and unlock the next level", "bottom")
            playerIns:UpdatedOneData(dataKey.lv1Wins, 1)
            playerIns:UpdatedOneData(dataKey.totalWins, 1)
            playerIns:UpdatedOneData(dataKey.wins, 1)

            if playerIns:GetOneData(dataKey.totalWins) == 1 then
                playerIns:AwardBadge(gameConfig.badges.firstWinLv1)
            end

            local lv1Time = os.time() - playerLevelTime[playerWhoTriggered]
            if lv1Time < playerIns:GetOneData(dataKey.lv1Time) then
                if lv1Time <= 240 then
                    lv1Time = 2400
                end
                playerIns:SetOneData(dataKey.lv1Time, lv1Time)
                BillboardManager.savePlayerRankData(playerWhoTriggered.UserId, playerIns:GetOneData(dataKey.lv1Time), rankListConfig.listNames.lv1Time)
            end
            print(`{playerWhoTriggered.Name} passed in {lv1Time}`)
            BillboardManager.savePlayerRankData(playerWhoTriggered.UserId, playerIns:GetOneData(dataKey.lv1Wins), rankListConfig.listNames.lv1Win)

            playerWhoTriggered.leaderstats.Wins.Value = playerIns:GetOneData(dataKey.totalWins)
            playerWhoTriggered.leaderstats.Pallets.Value = 0

            playerIns:SetColor("white")
            playerLevelTime[playerWhoTriggered] = os.time()
        elseif self.toolModel.colorString.Value == "purple" then
            playerIns:AwardBadge(gameConfig.badges.firstBucket)
        end
    end)
	return self
end

function BucketModelServerClass.OnRemoved(toolM)
    local toolMIns = bucketModelInsList[toolM]
    for key, _ in toolMIns do
        toolMIns[key] = nil
    end

    if toolMIns.interactCon then
        toolMIns.interactCon:Disconnect()
    end

    bucketModelInsList[toolM] = nil
end

function BucketModelServerClass.OnAdded(toolModel:Part)
    local toolM = BucketModelServerClass.new(toolModel)

    bucketModelInsList[toolM] = toolM
end


function SetPlayerStartTime(player)
    playerLevelTime[player] = os.time()
end

for _, player in game.Players:GetPlayers() do
    SetPlayerStartTime(player)
end

game.Players.PlayerAdded:Connect(function(player)
    playerLevelTime[player] = os.time()
end)


return BucketModelServerClass
