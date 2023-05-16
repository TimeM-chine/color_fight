local ReplicatedStorage = game:GetService("ReplicatedStorage")

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
local dataKey = require(game.ReplicatedStorage.enums.dataKey)

---- events ----
local changeColorEvent = game.ReplicatedStorage.RemoteEvents.changeColorEvent
local getLoginRewardEvent = game.ReplicatedStorage.RemoteEvents.getLoginRewardEvent

---- services ----
local PS = game:GetService("Players")
local PhysicsService = game:GetService("PhysicsService")

---- events ----
local RemoteEvents = game.ReplicatedStorage.RemoteEvents


PhysicsService:RegisterCollisionGroup("player")
PhysicsService:CollisionGroupSetCollidable("player", "player", false)

PS.PlayerAdded:Connect(function(player)
    local pIns = PlayerServerClass.GetIns(player)
    -- pIns:SetCollisionGroup("player")
end)


KeyboardRecall.SetServerRecall(keyCode.Backspace, function(player)
    local pIns = PlayerServerClass.GetIns(player)
    pIns:SetColor(colorList[math.random(1, 7)])
end)

changeColorEvent.OnServerEvent:Connect(function(player, color)
    local pIns = PlayerServerClass.GetIns(player)
    pIns:SetColor(color)
end)

getLoginRewardEvent.OnServerEvent:Connect(function(player, day)
    local loginState = PlayerServerClass.GetIns(player):GetOneData(dataKey.loginState)
    loginState[day] = true
    -- todo 发放奖励
    
end)
