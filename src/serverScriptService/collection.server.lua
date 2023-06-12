
---- classes ----
local WallServerClass = require(game.ServerScriptService.classes.WallServerClass)
local CollectionCls = require(game.ServerScriptService.classes.CollectionClass)
local BucketModelServerClass = require(game.ServerScriptService.classes.BucketModelServerClass)
local ToolModelServerClass = require(game.ServerScriptService.classes.ToolModelServerClass)
local PlayerServerClass = require(game.ServerScriptService.classes.PlayerServerClass)

---- services ----
local CS = game:GetService("CollectionService")
local ServerStorage = game:GetService("ServerStorage")

---- modules ----
local CreateModule = require(game.ReplicatedStorage.modules.CreateModule)
local BillboardManager = require(game.ServerScriptService.modules.BillboardManager)

---- enums ----
local colorEnum = require(game.ReplicatedStorage.enums.colorEnum)
local colorList = colorEnum.ColorList
local colorValue = colorEnum.ColorValue
local dataKey = require(game.ReplicatedStorage.enums.dataKey)
local rankListConfig = require(game.ReplicatedStorage.configs.RankList)

---- events ----
local remoteEvents = game.ReplicatedStorage.RemoteEvents
local teleportBindEvent = game.ReplicatedStorage.BindableEvents.teleportBindEvent
local hideToolDoorEvent = game.ReplicatedStorage.RemoteEvents.hideToolDoorEvent

---- variables ----
local playerStartTime = {}


teleportBindEvent.Event:Connect(function(player, levelInd)
    if not playerStartTime[player] then
        playerStartTime[player] = {}
    end
    playerStartTime[player][levelInd] = os.time()
end)


CollectionCls.new(WallServerClass)
CollectionCls.new(BucketModelServerClass)
CollectionCls.new(ToolModelServerClass)

---- random wall color ----
local wallsFolder = workspace.walls

for _, wallModel in wallsFolder:GetChildren() do
    CS:AddTag(wallModel.wall, WallServerClass.tagName)
end

---- bucket models ----
local bucketModelsFolder = workspace.bucketModels
for _, bucket in bucketModelsFolder:GetChildren() do
    CS:AddTag(bucket, BucketModelServerClass.tagName)
end


---- tool models ----
local toolModelsFolder = workspace.toolModels

for _, toolModel in toolModelsFolder:GetChildren() do
    CS:AddTag(toolModel, ToolModelServerClass.tagName)
end

---- tool doors ----
local toolDoorsFolder = workspace.toolDoors
for _, toolDoor in toolDoorsFolder:GetChildren() do
    toolDoor.ClickDetector.MouseClick:Connect(function(player)
        local hasTool = player.Character:FindFirstChild(toolDoor.require.Value)
        -- print(player, hasTool, toolDoor.require.Value)
        if hasTool then
            hasTool:Destroy()
            hideToolDoorEvent:FireClient(player, toolDoor)
        else
            -- print("wrong tool")
        end
        task.delay(0.5, function()
            local checkTool = player.Character:FindFirstChild(toolDoor.require.Value)
            if checkTool then
                checkTool:Destroy()
            end
        end)
    end)
end

---- monsters ----
local monsters = game.ServerStorage.monsters

for _, monster in monsters:GetChildren() do
    if monster.Name ~= "monster1" then continue end
    local part = workspace.pathPoints:FindFirstChild(monster.Name):FindFirstChild("Part1")
    monster:PivotTo(part.CFrame)
    monster.Parent = workspace

    local aiScript = game.ServerStorage.monsterAi
    aiScript:Clone().Parent = monster
end

