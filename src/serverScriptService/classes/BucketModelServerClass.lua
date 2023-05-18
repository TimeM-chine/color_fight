-- ================================================================================
-- wall cls --> server side, control global color or something
-- ================================================================================

---- classes ----
local PlayerServerClass = require(game.ServerScriptService.classes.PlayerServerClass)

---- modules ----
local CreateModule = require(game.ReplicatedStorage.modules.CreateModule)

---- variables ----
local bucketModelInsList = {}

---- enums ----
local colorEnum = require(game.ReplicatedStorage.enums.colorEnum)
local colorList = colorEnum.ColorList
local colorValue = colorEnum.ColorValue

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
        -- destroyEvent:FireClient(playerWhoTriggered, self.toolModel)
        if self.toolModel.colorString.Value == colorEnum.ColorName.white then
            serverNotifyEvent:FireClient(playerWhoTriggered, "Return to the main city and unlock the next level", "bottom")
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


return BucketModelServerClass
