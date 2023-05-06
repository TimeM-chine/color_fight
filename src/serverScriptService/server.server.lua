
---- modules ----
local SystemClass = require(game.ServerScriptService.classes.ServerSystemClass)
local KeyboardRecall = require(game.ReplicatedStorage.modules.KeyboardRecall)
local PlayerServerClass = require(game.ServerScriptService.classes.PlayerServerClass)

---- enums ----
local colorEnum = require(game.ReplicatedStorage.enums.colorEnum)
local colorName = colorEnum.ColorName
local colorList = colorEnum.ColorList
local colorValue = colorEnum.ColorValue
local keyCode = Enum.KeyCode

---- services ----
local PS = game:GetService("Players")
local PhysicsService = game:GetService("PhysicsService")

---- events ----
local RemoteEvents = game.ReplicatedStorage.RemoteEvents


PhysicsService:RegisterCollisionGroup("player")
PhysicsService:CollisionGroupSetCollidable("player", "player", false)

PS.PlayerAdded:Connect(function(player)
    local pIns = PlayerServerClass.GetIns(player)
    pIns:SetCollisionGroup("player")
end)


KeyboardRecall.SetServerRecall(keyCode.Backspace, function(player)
    local pIns = PlayerServerClass.GetIns(player)
    pIns:SetColor(colorList[math.random(1, 7)])
end)
