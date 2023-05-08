-- ================================================================================
-- player cls --> server side, universal player cls
-- ================================================================================

---- classes ----
local GamePlayerClass = require(script.Parent.GamePlayerClass)

---- modules ----
local DataMgr = require(game.ServerScriptService.modules.DataManager)

---- variables ----
local playerInsList = {}

---- main ----
local PlayerServerClass = setmetatable({}, GamePlayerClass)
PlayerServerClass.__index = PlayerServerClass
PlayerServerClass.player = nil

function PlayerServerClass.new(player:Player)
    local playerIns = setmetatable({}, PlayerServerClass)
    playerIns.player = player

    playerIns:InitPlayer()
    table.insert(playerInsList, playerIns)
    return playerIns
end

-- default: create instance
function PlayerServerClass.GetIns(player, createIfNil)
    createIfNil = createIfNil or true

    for _, ins in playerInsList do
        if ins.player == player then
            return ins
        end
    end
    warn(`Didn't find {player.name} ins`)
    if createIfNil then
        print(`  --> Created {player.name} ins`)
        return PlayerServerClass.new(player)
    end
    warn(`Didn't create {player.name} ins`)
end

function PlayerServerClass:SetPos(pos:Vector3)
    self.player.Character:MoveTo(pos)
end

function PlayerServerClass:GetPos()
    return self.player.Character.HumanoidRootPart.CFrame.Position
end

function PlayerServerClass:GetOneData(key)
    return DataMgr:GetPlayerOneData(self.player, key)
end

function PlayerServerClass:SetOneData(key, value)
    return DataMgr:SetPlayerOneData(self.player, key, value)
end

function PlayerServerClass:UpdatedOneData(key, num)
    local oldValue = self:GetOneData(key)
    self:SetOneData(key, oldValue + num)
end

function PlayerServerClass:NotifyToClient(event:RemoteEvent, args)
    event:FireClient(self.player, args)
end

function PlayerServerClass:AddItem(itemId, itemNum)
    
end

return PlayerServerClass
