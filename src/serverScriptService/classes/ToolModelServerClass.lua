-- ================================================================================
-- wall cls --> server side, control global color or something
-- ================================================================================

---- classes ----
local PlayerServerClass = require(game.ServerScriptService.classes.PlayerServerClass)

---- modules ----
local CreateModule = require(game.ReplicatedStorage.modules.CreateModule)

---- variables ----
local toolModelInsList = {}

---- enums ----
local colorEnum = require(game.ReplicatedStorage.enums.colorEnum)
local colorList = colorEnum.ColorList
local colorValue = colorEnum.ColorValue
local tipsConfig = require(game.ReplicatedStorage.configs.TipsConfig)

---- events -----
local hideToolEvent = game.ReplicatedStorage.RemoteEvents.hideToolEvent
local serverNotifyEvent = game.ReplicatedStorage.RemoteEvents.serverNotifyEvent


local ToolModelServerClass = {}
ToolModelServerClass.__index = ToolModelServerClass
ToolModelServerClass.tagName = "ToolModel"
ToolModelServerClass.toolModel = nil
ToolModelServerClass.interactCon  = nil

function ToolModelServerClass.new(toolM:Part)
	local self = setmetatable({}, ToolModelServerClass)
	self.toolModel = toolM

    local ppt:ProximityPrompt = toolM.ProximityPrompt
    self.interactCon = ppt.Triggered:Connect(function(playerWhoTriggered)
        local playerIns = PlayerServerClass.GetIns(playerWhoTriggered)
        playerIns:EquipFakeTool(self.toolModel.Name)
        hideToolEvent:FireClient(playerWhoTriggered, self.toolModel)
        -- destroyEvent:FireClient(playerWhoTriggered, self.toolModel)
        serverNotifyEvent:FireClient(playerWhoTriggered, tipsConfig.getTool[self.toolModel.Name], "bottom")
    end)
	return self
end

function ToolModelServerClass.OnRemoved(toolM)
    local toolMIns = toolModelInsList[toolM]
    for key, _ in toolMIns do
        toolMIns[key] = nil
    end

    if toolMIns.interactCon then
        toolMIns.interactCon:Disconnect()
    end

    toolModelInsList[toolM] = nil
end

function ToolModelServerClass.OnAdded(toolModel:Part)
    local toolM = ToolModelServerClass.new(toolModel)

    toolModelInsList[toolM] = toolM
end


return ToolModelServerClass
