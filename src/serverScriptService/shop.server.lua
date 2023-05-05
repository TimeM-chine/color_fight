-- ================================================================================
-- lottery server --> server side
-- ================================================================================

---- modules -----
local ServerSystemClass = require(game.ServerScriptService.classes.ServerSystemClass)
local PlayerServerClass = require(game.ServerScriptService.classes.PlayerServerClass)

---- events ----
local RemoteEvents = game.ReplicatedStorage.RemoteEvents

---- enums ----
local argsEnum = require(game.ReplicatedStorage.enums.argsEnum)
local dataKey = require(game.ReplicatedStorage.enums.dataKey)

local shopServer = ServerSystemClass.new()


function shoppingEventRecall(player, args)
    local itemId = args.itemId
    local itemNum = args.itemNum
    local price = 100

    local playerIns = PlayerServerClass.GetIns(player)
    local money = playerIns:GetPlayerOneData(dataKey.money)
    if money >= price then
        playerIns:UpdatedOneData(dataKey.money, -price)
        playerIns:AddItem(itemId, itemNum)
    else
        
    end

end

shopServer:ListenForEvent(RemoteEvents.shoppingEvent, shoppingEventRecall)
