---- modules ----
local GAModule = require(game.ReplicatedStorage.modules.GAModule)

---- classes ----
local PlayerServerClass = require(game.ServerScriptService.classes.PlayerServerClass)

---- events ----
local myDesignEvent = game.ReplicatedStorage.RemoteEvents.myDesignEvent

---- enums ----
local dataKey = require(game.ReplicatedStorage.enums.dataKey)

GAModule:configureBuild("0.1.0")

GAModule:setEnabledDebugLog(false)
GAModule:setEnabledInfoLog(false)

GAModule:initServer("36a5757f8622bb6c190cb08a9504bf85", "6662d954bfe48a6b143288c22deee5c24de5c969")

game.Players.PlayerAdded:Connect(function(player)
    GAModule:addDesignEvent(player.UserId, {
        eventId = "loginIn",
        value = os.time()
    })
end)


game.Players.PlayerRemoving:Connect(function(player)
    GAModule:addDesignEvent(player.UserId, {
        eventId = "loginOut",
        value = os.time()
    })

    local levelUnlock = PlayerServerClass.GetIns(player):GetOneData(dataKey.levelUnlock)
    if levelUnlock then
        local value = 0
        if levelUnlock[2] then
            value = 1
        end
        GAModule:addDesignEvent(player.UserId, {
            eventId = `levelCheck:level2:{player.UserId}`,
            value = value
        })
    else
        warn("leaving without finding data.")
    end

end)


myDesignEvent.OnServerEvent:Connect(function(player, param)
    GAModule:addDesignEvent(player.UserId, param)
end)
