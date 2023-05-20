local ReplicatedStorage = game:GetService("ReplicatedStorage")

---- modules ----
local SystemClass = require(game.ServerScriptService.classes.ServerSystemClass)
local KeyboardRecall = require(game.ReplicatedStorage.modules.KeyboardRecall)
local PlayerServerClass = require(game.ServerScriptService.classes.PlayerServerClass)
local ModelModule = require(game.ReplicatedStorage.modules.ModelModule)

---- enums ----
local colorEnum = require(game.ReplicatedStorage.enums.colorEnum)
local colorName = colorEnum.ColorName
local colorList = colorEnum.ColorList
local colorValue = colorEnum.ColorValue
local keyCode = Enum.KeyCode
local dataKey = require(game.ReplicatedStorage.enums.dataKey)

---- events ----
local RemoteEvents = game.ReplicatedStorage.RemoteEvents
local changeColorEvent = game.ReplicatedStorage.RemoteEvents.changeColorEvent
local getLoginRewardEvent = game.ReplicatedStorage.RemoteEvents.getLoginRewardEvent
local playerHideSkill = game.ReplicatedStorage.RemoteEvents.playerHideSkill

---- services ----
local PS = game:GetService("Players")
local PhysicsService = game:GetService("PhysicsService")


PhysicsService:RegisterCollisionGroup("player")
PhysicsService:CollisionGroupSetCollidable("player", "player", false)

PS.PlayerAdded:Connect(function(player)
    local pIns = PlayerServerClass.GetIns(player)
    -- pIns:SetCollisionGroup("player")
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

playerHideSkill.OnServerEvent:Connect(function(player)
    local field = Instance.new("ForceField")
    field.Parent = player.Character
    local whiteList = player.Character.paintCan:GetChildren()
    table.insert(whiteList, player.Character.HumanoidRootPart)
    ModelModule.SetModelTransparency(player.Character, 0.5, whiteList)
    task.wait(3)
    field:Destroy()
    ModelModule.SetModelTransparency(player.Character, 0, whiteList)
end)


RemoteEvents.addHealthEvent.OnServerEvent:Connect(function(player)
    local playerIns = PlayerServerClass.GetIns(player)
    playerIns:AddHealth()
end)


RemoteEvents.chooseSkillEvent.OnServerEvent:Connect(function(player, ind)
    local playerIns = PlayerServerClass.GetIns(player)
    print("chooseSkillEvent", ind)
    playerIns:SetOneData(dataKey.chosenSkInd, ind)
    local skillTable = playerIns:GetOneData(dataKey.career)
    skillTable[ind] = true
end)
