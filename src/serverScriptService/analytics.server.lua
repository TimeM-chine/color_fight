---- modules ----
local GAModule = require(game.ReplicatedStorage.modules.GAModule)

---- events ----
local myDesignEvent = game.ReplicatedStorage.RemoteEvents.myDesignEvent


GAModule:configureBuild("0.1.0")

GAModule:setEnabledDebugLog(false)
GAModule:setEnabledInfoLog(false)

GAModule:initServer("fb39761579712621c22791879c1d0dc8", "2f7c6b9f0aac440631ae2add01399e98d82ef72d")

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
end)


myDesignEvent.OnServerEvent:Connect(function(player, param)
    GAModule:addDesignEvent(player.UserId, param)
end)
