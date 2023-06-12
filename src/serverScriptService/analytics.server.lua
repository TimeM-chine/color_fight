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
-- GAModule:initServer("fb39761579712621c22791879c1d0dc8", "2f7c6b9f0aac440631ae2add01399e98d82ef72d")

myDesignEvent.OnServerEvent:Connect(function(player, param)
    GAModule:addDesignEvent(player.UserId, param)
end)
