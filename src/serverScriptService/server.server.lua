
---- modules ----
local SystemClass = require(game.ServerScriptService.classes.ServerSystemClass)
local KeyboardRecall = require(game.ReplicatedStorage.modules.KeyboardRecall)
local PlayerServerClass = require(game.ServerScriptService.classes.PlayerServerClass)


---- enums ----
local keyCode = Enum.KeyCode

---- services ----
local PS = game:GetService("Players")

---- events ----
local RemoteEvents = game.ReplicatedStorage.RemoteEvents


------------- daily rewards -------------
PS.PlayerAdded:Connect(function(player)
    PlayerServerClass.GetIns(player)
end)
