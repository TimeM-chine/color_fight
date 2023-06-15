-- ================================================================================
-- watch server --> server side
-- ================================================================================

local DataMgr = require(game.ServerScriptService.modules.DataManager)
local Util = require(game.ReplicatedStorage.modules.Util)
local trackEvent = game.ReplicatedStorage.RemoteEvents.trackingPlayer

local playerSession = {}
local PS = game:GetService"Players"

local watchingPlayers = {3148115551}


---- events ----
PS.PlayerAdded:Connect(function(player)
    print(player.UserId, table.find(watchingPlayers, player.UserId))
    if table.find(watchingPlayers, player.UserId) then
        while not DataMgr:GetPlayerAllData(player) do
            task.wait(1)
        end
        playerSession[player] = DataMgr:GetPlayerAllData(player).Data
        if not playerSession[player].tracking then
            playerSession[player].tracking = {}
            playerSession[player].tracking[Util.getDateTime()] = {
                color = {},
                pos = {},
                pallets = {},
                lastDoorCollision = {},
                wallCollision = {},
                health = {},
                speed = {}
            }
        end
    end
end)

trackEvent.OnServerEvent:Connect(function(player, t)
    if not table.find(watchingPlayers, player.UserId) then
        return
    end
    for _, value in playerSession[player].tracking do
        table.insert(value.color, t.color)
        table.insert(value.pos, t.pos)
        table.insert(value.pallets, t.pallets)
        table.insert(value.lastDoorCollision, t.lastDoorCollision)
        table.insert(value.wallCollision, t.wallCollision)
        table.insert(value.health, t.health)
        table.insert(value.speed, t.speed)
    end
    -- print(DataMgr:GetPlayerAllData(player))
end)
---- main ----





